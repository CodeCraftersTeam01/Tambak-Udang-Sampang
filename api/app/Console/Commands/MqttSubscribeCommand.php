<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class MqttSubscribeCommand extends Command
{
    protected $signature = 'mqtt:subscribe';
    protected $description = 'Subscribe to MQTT topics and write sensor readings to database';

    public function handle()
    {
        $this->info("Starting MQTT listener...");

        // Save current process PID
        try {
            $pidFile = storage_path('logs/mqtt_subscribe.pid');
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

        // Path mosquitto_sub
        $mosquittoPath = is_file('/opt/homebrew/bin/mosquitto_sub') 
            ? '/opt/homebrew/bin/mosquitto_sub' 
            : 'mosquitto_sub';

        $command = sprintf(
            '%s -h %s -p %d -u %s -P %s -t "pkm2026/#" -v',
            $mosquittoPath,
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
            // Topics do not contain space, so we split by the first space
            $spacePos = strpos($line, ' ');
            if ($spacePos === false) {
                continue;
            }

            $topic = substr($line, 0, $spacePos);
            $message = substr($line, $spacePos + 1);

            $this->info("Topic: " . $topic);
            $this->info("Message: " . $message);

            $segments = explode('/', $topic);
            // Segments: pkm2026, {device_code}, {sensor_code}
            if (count($segments) < 3 || $segments[0] !== 'pkm2026') {
                continue;
            }

            $deviceCode = $segments[1];
            $sensorKey = $segments[2]; // e.g. suhu, ph, tds, do, status

            // Cari device berdasarkan device_code
            $device = DB::table('devices')->where('device_code', $deviceCode)->first();
            if (!$device) {
                $this->warn("No device registered with device code: " . $deviceCode);
                continue;
            }

            // Update last_seen_at
            DB::table('devices')->where('id', $device->id)->update([
                'last_seen_at' => date('Y-m-d H:i:s')
            ]);

            // Jika itu status online/offline
            if ($sensorKey === 'status') {
                $this->info("Device {$deviceCode} is " . $message);
                continue;
            }

            // Jika itu topik kalibrasi (pkm2026/{device_code}/calibration/...)
            if ($sensorKey === 'calibration') {
                $subSegment = $segments[3] ?? null;
                if ($subSegment === 'state') {
                    $payloadData = json_decode($message, true);
                    if (is_array($payloadData)) {
                        $revision = $payloadData['revision'] ?? 1;
                        
                        // Periksa apakah revisi ini sudah ada di DB
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
                            // Nonaktifkan konfigurasi aktif lainnya
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

            // Jika itu topik aerator (pkm2026/{device_code}/aerator/...)
            if (strpos($sensorKey, 'aerator') === 0) {
                $subSegment = $segments[3] ?? null;
                $this->info("Aerator Event - Device: {$deviceCode}, Aerator: {$sensorKey}, Type: {$subSegment}, Value: {$message}");
                continue;
            }

            // Mapping dari key MQTT ke sensor type code di database
            $typeMapping = [
                'suhu' => 'temperature',
                'ph' => 'ph',
                'tds' => 'tds',
                'do' => 'do',
                'level' => 'water_level',
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

            // Cari sensor
            $sensor = DB::table('sensors')
                ->join('sensor_types', 'sensor_types.id', '=', 'sensors.sensor_type_id')
                ->where('sensors.device_id', $device->id)
                ->where('sensor_types.code', $sensorTypeCode)
                ->select('sensors.id', 'sensor_types.unit')
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
            } else {
                $this->warn("No sensor found for device {$deviceCode} with sensor type: " . $sensorTypeCode);
            }
        }

        pclose($process);
        return 0;
    }
}
