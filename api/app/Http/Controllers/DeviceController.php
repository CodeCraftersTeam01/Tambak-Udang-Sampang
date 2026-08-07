<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DeviceController extends Controller
{
    public function index()
    {
        $devices = DB::table('devices')
            ->leftJoin('kolams', 'kolams.id', '=', 'devices.pond_id')
            ->select(
                'devices.id',
                'devices.pond_id',
                'kolams.nama_kolam as pond_name',
                DB::raw('CONCAT("KOLAM-", kolams.id) as pond_code'),
                'devices.device_code',
                'devices.name',
                'devices.device_type',
                'devices.brand',
                'devices.model',
                'devices.serial_number',
                'devices.mqtt_topic',
                'devices.ip_address',
                'devices.location_note',
                'devices.status as status_raw',
                'devices.last_seen_at',
                'devices.installed_at',
                'devices.created_at',
                'devices.updated_at'
            )
            ->orderBy('devices.id')
            ->get()
            ->map(function ($device) {
                $device->status = $this->resolveDeviceStatus(
                    $device->status_raw,
                    $device->last_seen_at
                );

                return $device;
            });

        return response()->json([
            'success' => true,
            'data' => $devices,
        ]);
    }

    private function resolveDeviceStatus(?string $statusRaw, ?string $lastSeenAt): string
    {
        if ($statusRaw === 'inactive') {
            return 'inactive';
        }

        if ($statusRaw === 'maintenance') {
            return 'maintenance';
        }

        if (!$lastSeenAt) {
            return 'offline';
        }

        $lastSeenTimestamp = strtotime($lastSeenAt);

        if (!$lastSeenTimestamp) {
            return 'offline';
        }

        $diffSeconds = time() - $lastSeenTimestamp;

        if ($diffSeconds > 120) {
            return 'offline';
        }

        return 'online';
    }

    public function show(string $id)
    {
        $device = DB::table('devices')
            ->leftJoin('kolams', 'kolams.id', '=', 'devices.pond_id')
            ->select(
                'devices.*',
                'kolams.nama_kolam as pond_name',
                DB::raw('CONCAT("KOLAM-", kolams.id) as pond_code')
            )
            ->where('devices.id', $id)
            ->first();

        if (!$device) {
            return response()->json([
                'success' => false,
                'message' => 'Device not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $device,
        ]);
    }

    public function sensors(string $id)
    {
        $device = DB::table('devices')->where('id', $id)->first();

        if (!$device) {
            return response()->json([
                'success' => false,
                'message' => 'Device not found',
            ], 404);
        }

        $sensors = DB::table('sensors')
            ->join('sensor_types', 'sensor_types.id', '=', 'sensors.sensor_type_id')
            ->select(
                'sensors.id',
                'sensors.device_id',
                'sensors.sensor_type_id',
                'sensors.sensor_code',
                'sensors.name',
                'sensor_types.code as type_code',
                'sensor_types.name as type_name',
                'sensor_types.unit',
                'sensor_types.normal_min',
                'sensor_types.normal_max',
                'sensors.calibration_date',
                'sensors.calibration_note',
                'sensors.status',
                'sensors.created_at',
                'sensors.updated_at'
            )
            ->where('sensors.device_id', $id)
            ->orderBy('sensors.id')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $sensors,
        ]);
    }

    public function calibration(string $id)
    {
        $device = DB::table('devices')
            ->where('id', $id)
            ->orWhere('pond_id', $id)
            ->first();

        if (!$device) {
            return response()->json([
                'success' => false,
                'message' => 'Device not found',
            ], 404);
        }

        $config = DB::table('device_calibration_configs')
            ->where('device_id', $device->id)
            ->where('is_active', 1)
            ->orderByDesc('id')
            ->first();

        if (!$config) {
            $config = [
                'device_id' => (int) $device->id,
                'pond_id' => $device->pond_id,
                'ph_slope' => 3.5,
                'ph_offset' => 1.9,
                'do_scale' => 0.5,
                'do_offset' => 0,
                'tds_scale' => 1,
                'tds_offset' => 0,
                'suhu_offset' => 0,
                'revision' => 1,
                'is_active' => 1,
            ];
        } else {
            $config = (array) $config;
        }

        $sensors = DB::table('sensors')
            ->where('device_id', $device->id)
            ->get();

        return response()->json([
            'success' => true,
            'data' => array_merge($config, [
                'device' => $device,
                'sensors' => $sensors,
            ]),
        ]);
    }

    public function updateCalibration(Request $request, string $id)
    {
        $device = DB::table('devices')
            ->where('id', $id)
            ->orWhere('pond_id', $id)
            ->first();

        if (!$device) {
            return response()->json([
                'success' => false,
                'message' => 'Device not found',
            ], 404);
        }

        if ($device->device_type !== 'sensor_node') {
            return response()->json([
                'success' => false,
                'message' => 'Calibration is only allowed for sensor_node devices',
            ], 422);
        }

        $payload = [
            'ph_slope' => (float) $request->input('ph_slope'),
            'ph_offset' => (float) $request->input('ph_offset'),
            'do_scale' => (float) $request->input('do_scale'),
            'do_offset' => (float) $request->input('do_offset'),
            'tds_scale' => (float) $request->input('tds_scale'),
            'tds_offset' => (float) $request->input('tds_offset'),
            'suhu_offset' => (float) $request->input('suhu_offset'),
        ];

        $validationMessage = $this->validateCalibration($payload);

        if ($validationMessage !== null) {
            return response()->json([
                'success' => false,
                'message' => $validationMessage,
            ], 422);
        }

        $current = DB::table('device_calibration_configs')
            ->where('device_id', $id)
            ->where('is_active', 1)
            ->orderByDesc('id')
            ->first();

        $revision = $current ? ((int) $current->revision + 1) : 1;

        if ($current) {
            DB::table('device_calibration_configs')
                ->where('id', $current->id)
                ->update([
                    'ph_slope' => $payload['ph_slope'],
                    'ph_offset' => $payload['ph_offset'],
                    'do_scale' => $payload['do_scale'],
                    'do_offset' => $payload['do_offset'],
                    'tds_scale' => $payload['tds_scale'],
                    'tds_offset' => $payload['tds_offset'],
                    'suhu_offset' => $payload['suhu_offset'],
                    'revision' => $revision,
                    'updated_at' => date('Y-m-d H:i:s'),
                ]);

            $configId = $current->id;
        } else {
            $configId = DB::table('device_calibration_configs')->insertGetId([
                'device_id' => $id,
                'pond_id' => $device->pond_id,
                'ph_slope' => $payload['ph_slope'],
                'ph_offset' => $payload['ph_offset'],
                'do_scale' => $payload['do_scale'],
                'do_offset' => $payload['do_offset'],
                'tds_scale' => $payload['tds_scale'],
                'tds_offset' => $payload['tds_offset'],
                'suhu_offset' => $payload['suhu_offset'],
                'revision' => $revision,
                'is_active' => 1,
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ]);
        }

        $mqttPayload = array_merge($payload, [
            'revision' => $revision,
        ]);

        $mqttTopic = $device->mqtt_topic
            ? $device->mqtt_topic . '/calibration/set'
            : null;

        $mqttPublished = false;
        $mqttError = null;

        if ($mqttTopic) {
            try {
                $mqttPublished = $this->publishCalibrationToMqtt($mqttTopic, $mqttPayload);
            } catch (\Throwable $e) {
                $mqttPublished = false;
                $mqttError = $e->getMessage();
            }
        }

        $updated = DB::table('device_calibration_configs')
            ->where('id', $configId)
            ->first();

        return response()->json([
            'success' => true,
            'message' => 'Calibration updated',
            'data' => $updated,
            'mqtt' => [
                'topic' => $mqttTopic,
                'payload' => $mqttPayload,
                'published' => $mqttPublished,
                'error' => $mqttError,
            ],
        ]);
    }

    private function validateCalibration(array $payload)
    {
        if (abs($payload['ph_slope']) < 0.0001 || $payload['ph_slope'] < -20 || $payload['ph_slope'] > 20) {
            return 'Invalid ph_slope';
        }

        if ($payload['ph_offset'] < -20 || $payload['ph_offset'] > 20) {
            return 'Invalid ph_offset';
        }

        if ($payload['do_scale'] <= 0 || $payload['do_scale'] > 10) {
            return 'Invalid do_scale';
        }

        if ($payload['do_offset'] < -20 || $payload['do_offset'] > 20) {
            return 'Invalid do_offset';
        }

        if ($payload['tds_scale'] <= 0 || $payload['tds_scale'] > 10) {
            return 'Invalid tds_scale';
        }

        if ($payload['tds_offset'] < -5000 || $payload['tds_offset'] > 5000) {
            return 'Invalid tds_offset';
        }

        if ($payload['suhu_offset'] < -10 || $payload['suhu_offset'] > 10) {
            return 'Invalid suhu_offset';
        }

        return null;
    }

    private function publishCalibrationToMqtt(string $topic, array $payload): bool
    {
        $host = env('MQTT_HOST', 'm-tech.fun');
        $port = env('MQTT_PORT', 1883);
        $user = env('MQTT_USER', 'mhs1');
        $pass = env('MQTT_PASS', 'mhs123');

        $jsonPayload = json_encode($payload);

        $command = sprintf(
            'mosquitto_pub -h %s -p %d -u %s -P %s -t %s -m %s',
            escapeshellarg($host),
            (int) $port,
            escapeshellarg($user),
            escapeshellarg($pass),
            escapeshellarg($topic),
            escapeshellarg($jsonPayload)
        );

        exec($command, $output, $exitCode);

        return $exitCode === 0;
    }
}
