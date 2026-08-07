<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class MqttSubscribeCommand extends Command
{
    protected $signature = 'mqtt:subscribe';
    protected $description = 'Subscribe to MQTT topics and write sensor readings to database';

    public function handle()
    {
        $this->info("Starting MQTT listener...");

        // Kill previous running instance
        $pidFile = storage_path('logs/mqtt_subscribe.pid');
        if (file_exists($pidFile)) {
            $oldPid = (int) file_get_contents($pidFile);
            if ($oldPid > 0 && $oldPid !== getmypid()) {
                $isWindows = defined('PHP_OS_FAMILY') ? PHP_OS_FAMILY === 'Windows' : (strncasecmp(PHP_OS, 'WIN', 3) === 0);
                if ($isWindows) {
                    exec("taskkill /F /PID $oldPid 2>&1");
                } else {
                    if (function_exists('posix_kill')) {
                        posix_kill($oldPid, 9);
                    } else {
                        exec("kill -9 $oldPid 2>&1");
                    }
                }
            }
        }

        // Save current process PID
        try {
            $dir = dirname($pidFile);
            if (!is_dir($dir)) {
                mkdir($dir, 0755, true);
            }
            file_put_contents($pidFile, getmypid());
        } catch (\Throwable $e) {
            $this->warn("Could not save PID file: " . $e->getMessage());
        }

        $host = env('MQTT_HOST', 'm-tech.fun');
        $port = env('MQTT_PORT', 1883);
        $user = env('MQTT_USER', 'mhs1');
        $pass = env('MQTT_PASS', 'mhs123');

        // Resolve dynamic mosquitto_sub binary path based on OS family
        $mosquittoPath = null;
        $isWindows = defined('PHP_OS_FAMILY') ? PHP_OS_FAMILY === 'Windows' : (strncasecmp(PHP_OS, 'WIN', 3) === 0);
        if ($isWindows) {
            $paths = [
                'C:\\Program Files\\mosquitto\\mosquitto_sub.exe',
                'C:\\Program Files (x86)\\mosquitto\\mosquitto_sub.exe',
            ];
            foreach ($paths as $path) {
                if (is_file($path)) {
                    $mosquittoPath = $path;
                    break;
                }
            }
            if (!$mosquittoPath) {
                @exec('where mosquitto_sub.exe 2>&1', $output, $returnVar);
                if ($returnVar === 0 && !empty($output)) {
                    $mosquittoPath = trim($output[0]);
                }
            }
        } else {
            $paths = [
                '/usr/bin/mosquitto_sub',
                '/usr/local/bin/mosquitto_sub',
                '/opt/homebrew/bin/mosquitto_sub',
            ];
            foreach ($paths as $path) {
                if (is_file($path)) {
                    $mosquittoPath = $path;
                    break;
                }
            }
            if (!$mosquittoPath) {
                @exec('which mosquitto_sub 2>&1', $output, $returnVar);
                if ($returnVar === 0 && !empty($output)) {
                    $mosquittoPath = trim($output[0]);
                }
            }
        }

        // Fallback to plain binary if not found in specific paths
        if (!$mosquittoPath) {
            $this->warn("mosquitto_sub binary was not found in common installation paths. Attempting to run via system PATH...");
            $mosquittoPath = 'mosquitto_sub';
        }

        $escapedMosquittoPath = '"' . trim($mosquittoPath, '"') . '"';

        $command = sprintf(
            '%s -h %s -p %d -u %s -P %s -t "pkm2026/#" -v',
            $escapedMosquittoPath,
            escapeshellarg($host),
            (int) $port,
            escapeshellarg($user),
            escapeshellarg($pass)
        );

        $this->info("Running command: " . $command);

        $process = popen($command, 'r');
        if (!$process) {
            $this->error("Failed to run mosquitto_sub process.");
            return 1;
        }

        while (!feof($process)) {
            $line = fgets($process);
            if ($line === false) {
                continue;
            }

            $line = trim($line);
            if (empty($line)) {
                continue;
            }

            $this->info("Received line: " . $line);

            // Format mosquitto_sub -v is: topic payload
            $spacePos = strpos($line, ' ');
            if ($spacePos === false) {
                continue;
            }

            $topic = substr($line, 0, $spacePos);
            $message = substr($line, $spacePos + 1);

            $this->info("Topic: " . $topic);
            $this->info("Message: " . $message);

            $segments = explode('/', $topic);
            if (count($segments) < 3 || $segments[0] !== 'pkm2026') {
                continue;
            }

            $deviceCode = $segments[1];
            $sensorKey = $segments[2];

            // Find device by device_code
            $device = DB::table('devices')->where('device_code', $deviceCode)->first();
            if (!$device) {
                $this->warn("No device registered with device code: " . $deviceCode);
                continue;
            }

            // Update last_seen_at
            DB::table('devices')->where('id', $device->id)->update([
                'last_seen_at' => date('Y-m-d H:i:s')
            ]);

            // Status message
            if ($sensorKey === 'status') {
                $this->info("Device {$deviceCode} is " . $message);
                continue;
            }

            // Calibration config sync
            if ($sensorKey === 'calibration') {
                $subSegment = $segments[3] ?? null;
                if ($subSegment === 'state') {
                    $payloadData = json_decode($message, true);
                    if (is_array($payloadData)) {
                        $revision = $payloadData['revision'] ?? 1;
                        
                        $exists = DB::table('device_calibration_configs')
                            ->where('device_id', $device->id)
                            ->where('revision', $revision)
                            ->exists();
                            
                        if ($exists) {
                            DB::table('device_calibration_configs')
                                ->where('device_id', $device->id)
                                ->where('revision', $revision)
                                ->update([
                                    'ph_slope' => $payloadData['ph_slope'] ?? 1.0,
                                    'ph_offset' => $payloadData['ph_offset'] ?? 0.0,
                                    'do_scale' => $payloadData['do_scale'] ?? 1.0,
                                    'do_offset' => $payloadData['do_offset'] ?? 0.0,
                                    'tds_scale' => $payloadData['tds_scale'] ?? 1.0,
                                    'tds_offset' => $payloadData['tds_offset'] ?? 0.0,
                                    'suhu_offset' => $payloadData['suhu_offset'] ?? 0.0,
                                    'updated_at' => date('Y-m-d H:i:s')
                                ]);
                        } else {
                            DB::table('device_calibration_configs')
                                ->where('device_id', $device->id)
                                ->update(['is_active' => 0]);
                                
                            DB::table('device_calibration_configs')->insert([
                                'device_id' => $device->id,
                                'pond_id' => $device->pond_id,
                                'ph_slope' => $payloadData['ph_slope'] ?? 1.0,
                                'ph_offset' => $payloadData['ph_offset'] ?? 0.0,
                                'do_scale' => $payloadData['do_scale'] ?? 1.0,
                                'do_offset' => $payloadData['do_offset'] ?? 0.0,
                                'tds_scale' => $payloadData['tds_scale'] ?? 1.0,
                                'tds_offset' => $payloadData['tds_offset'] ?? 0.0,
                                'suhu_offset' => $payloadData['suhu_offset'] ?? 0.0,
                                'revision' => $revision,
                                'is_active' => 1,
                                'created_at' => date('Y-m-d H:i:s'),
                                'updated_at' => date('Y-m-d H:i:s')
                            ]);
                        }
                        $this->info("Updated device {$deviceCode} calibration state to revision {$revision} from MQTT.");
                    }
                }
                continue;
            }

            // Aerator/Relay sync
            if (strpos($sensorKey, 'aerator') === 0) {
                $subSegment = $segments[3] ?? null;
                $this->info("Aerator Event - Device: {$deviceCode}, Aerator: {$sensorKey}, Type: {$subSegment}, Value: {$message}");
                continue;
            }

            // Mappings
            $typeMapping = [
                'suhu' => 'temperature',
                'temp' => 'temperature',
                'temperature' => 'temperature',
                'ph' => 'ph',
                'tds' => 'tds',
                'do' => 'do',
                'level' => 'water_level',
                'water_level' => 'water_level',
            ];

            if (!isset($typeMapping[$sensorKey])) {
                $this->warn("Unknown sensor key: " . $sensorKey);
                continue;
            }

            $sensorTypeCode = $typeMapping[$sensorKey];
            $value = trim($message);

            if ($value === '' || !is_numeric($value)) {
                $this->warn("Value is not numeric: " . $value);
                continue;
            }

            // Find sensor
            $sensor = DB::table('sensors')
                ->join('sensor_types', 'sensor_types.id', '=', 'sensors.sensor_type_id')
                ->where('sensors.device_id', $device->id)
                ->where('sensor_types.code', $sensorTypeCode)
                ->select('sensors.id', 'sensors.name', 'sensor_types.id as sensor_type_id', 'sensor_types.unit')
                ->first();

            if ($sensor) {
                DB::table('sensor_readings')->insert([
                    'sensor_id' => $sensor->id,
                    'pond_id' => $device->pond_id,
                    'value' => (float) $value,
                    'unit' => $sensor->unit,
                    'recorded_at' => date('Y-m-d H:i:s'),
                    'created_at' => date('Y-m-d H:i:s'),
                    'updated_at' => date('Y-m-d H:i:s')
                ]);
                $this->info("Inserted reading for device {$deviceCode}, sensor type {$sensorTypeCode}: {$value}");

                // Independent Threshold & Notification Engine
                try {
                    $doubleValue = (float) $value;
                    $pondId = $device->pond_id;
                    $sensorTypeId = $sensor->sensor_type_id;

                    // Lightly cache the threshold database query for 30 seconds
                    $threshold = Cache::remember(
                        "sensor_threshold_{$pondId}_{$sensorTypeId}",
                        30,
                        function () use ($pondId, $sensorTypeId) {
                            return DB::table('sensor_thresholds')
                                ->where('pond_id', $pondId)
                                ->where('sensor_type_id', $sensorTypeId)
                                ->where('is_active', 1)
                                ->first();
                        }
                    );

                    $shouldWarn = false;
                    $breachedLimit = '';
                    $minVal = null;
                    $maxVal = null;

                    if ($threshold) {
                        if ($threshold->min_value !== null) {
                            $minVal = (float) $threshold->min_value;
                        }
                        if ($threshold->max_value !== null) {
                            $maxVal = (float) $threshold->max_value;
                        }
                    } else {
                        // Log warning and fallback to default type normal min/max
                        Log::warning("Thresholds are missing for pond {$pondId} and sensor type {$sensorTypeCode}. Using fallback values from sensor_types table.");
                        
                        $sensorTypeObj = DB::table('sensor_types')->where('code', $sensorTypeCode)->first();
                        if ($sensorTypeObj) {
                            if ($sensorTypeObj->normal_min !== null) {
                                $minVal = (float) $sensorTypeObj->normal_min;
                            }
                            if ($sensorTypeObj->normal_max !== null) {
                                $maxVal = (float) $sensorTypeObj->normal_max;
                            }
                        }
                    }

                    // Strict Condition Check
                    if ($minVal !== null && $doubleValue < $minVal) {
                        $shouldWarn = true;
                        $breachedLimit = 'TERLALU RENDAH';
                    } elseif ($maxVal !== null && $doubleValue > $maxVal) {
                        $shouldWarn = true;
                        $breachedLimit = 'TERLALU TINGGI';
                    }

                    // Cooldown Cache Check (60 seconds)
                    if ($shouldWarn) {
                        $cacheKey = "mqtt_cooldown_{$pondId}_{$sensorTypeCode}";
                        if (!Cache::has($cacheKey)) {
                            $sensorName = $sensor->name ?? ucfirst($sensorKey);
                            $notificationString = "BAHAYA: {$sensorName} Kolam {$breachedLimit} ({$doubleValue})";

                            $pushService = new \App\Services\FirebasePushService();
                            $pushService->sendWarningNotification($notificationString, $notificationString);
                            $this->info("Push Notification sent: {$notificationString}");
                            Cache::put($cacheKey, true, 60);
                        } else {
                            $this->warn("Throttled: {$sensorTypeCode} is on 60s cooldown.");
                        }
                    }
                } catch (\Throwable $e) {
                    Log::error('Firebase Notification Failed: ' . $e->getMessage());
                    $this->error('Firebase Notification Failed: ' . $e->getMessage());
                }
            } else {
                $this->warn("No sensor found for device {$deviceCode} with sensor type: " . $sensorTypeCode);
            }
        }

        pclose($process);
        return 0;
    }
}
