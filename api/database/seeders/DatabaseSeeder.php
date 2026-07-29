<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Role;
use App\Models\User;
use App\Models\Kolam;
use App\Models\Produksi;
use App\Models\Pakan;
use App\Models\Panen;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // ─── Roles ───
        $roleSuperAdmin = Role::create(['name' => 'super_admin']);
        $roleAdmin = Role::create(['name' => 'admin']);
        $rolePetambak = Role::create(['name' => 'petambak']);

        // ─── Users ───
        User::create([
            'role_id' => $roleSuperAdmin->id,
            'name' => 'Budi Super Admin',
            'email' => 'admin@tambak.com',
            'password' => Hash::make('password123'),
        ]);

        User::create([
            'role_id' => $roleAdmin->id,
            'name' => 'Siti Admin',
            'email' => 'siti@tambak.com',
            'password' => Hash::make('password123'),
        ]);

        User::create([
            'role_id' => $rolePetambak->id,
            'name' => 'Joko Petambak',
            'email' => 'joko@tambak.com',
            'password' => Hash::make('password123'),
        ]);

        // ─── Kolam ───
        $kolam1 = Kolam::create([
            'nama_kolam' => 'Kolam Alpha',
            'pemilik'    => 1,
            'lat'        => -7.123456,
            'long'       => 112.123456,
            'status'     => 1,
        ]);

        $kolam2 = Kolam::create([
            'nama_kolam' => 'Kolam Beta',
            'pemilik'    => 1,
            'lat'        => -7.124456,
            'long'       => 112.124456,
            'status'     => 1,
        ]);

        $kolam3 = Kolam::create([
            'nama_kolam' => 'Kolam Gamma',
            'pemilik'    => 1,
            'lat'        => -7.125456,
            'long'       => 112.125456,
            'status'     => 0,
        ]);

        // ─── Produksi ───
        Produksi::create([
            'kolam_id'                 => $kolam1->id,
            'tanggal_pemasangan_benor' => Carbon::now()->subDays(45)->toDateString(),
            'ukuran_benor'             => 'PL-10',
        ]);
        Produksi::create([
            'kolam_id'                 => $kolam2->id,
            'tanggal_pemasangan_benor' => Carbon::now()->subDays(12)->toDateString(),
            'ukuran_benor'             => 'PL-12',
        ]);

        // ─── Pakan ───
        Pakan::create(['kolam_id' => $kolam1->id, 'nama_pakan' => 'Irawan Grow', 'jumlah_perminggu_kg' => 120.5]);
        Pakan::create(['kolam_id' => $kolam1->id, 'nama_pakan' => 'Vitamin Aqua', 'jumlah_perminggu_kg' => 10.0]);
        Pakan::create(['kolam_id' => $kolam2->id, 'nama_pakan' => 'Irawan Starter', 'jumlah_perminggu_kg' => 45.0]);
        Pakan::create(['kolam_id' => $kolam3->id, 'nama_pakan' => 'Sisa Pakan', 'jumlah_perminggu_kg' => 5.5]);

        // ─── Panen ───
        $bulanLalu = Carbon::now()->subMonths(1);
        $duaBulanLalu = Carbon::now()->subMonths(2);
        $tigaBulanLalu = Carbon::now()->subMonths(3);

        Panen::create([
            'kolam_id'        => $kolam1->id,
            'tanggal_panen'   => $tigaBulanLalu->toDateString(),
            'jumlah_panen_kg' => 500,
            'jenis_panen'     => 'parsial',
        ]);
        Panen::create([
            'kolam_id'        => $kolam1->id,
            'tanggal_panen'   => $duaBulanLalu->toDateString(),
            'jumlah_panen_kg' => 1500,
            'jenis_panen'     => 'total',
        ]);
        Panen::create([
            'kolam_id'        => $kolam2->id,
            'tanggal_panen'   => $bulanLalu->toDateString(),
            'jumlah_panen_kg' => 450,
            'jenis_panen'     => 'parsial',
        ]);
        Panen::create([
            'kolam_id'        => $kolam3->id,
            'tanggal_panen'   => $duaBulanLalu->subDays(15)->toDateString(),
            'jumlah_panen_kg' => 1200,
            'jenis_panen'     => 'total',
        ]);

        // ─── Sensor Types ───
        $sensorTypes = [
            ['code' => 'ph', 'name' => 'pH', 'unit' => 'pH', 'normal_min' => 6.5, 'normal_max' => 8.5],
            ['code' => 'tds', 'name' => 'TDS', 'unit' => 'ppm', 'normal_min' => 500.0, 'normal_max' => 1500.0],
            ['code' => 'do', 'name' => 'Dissolved Oxygen', 'unit' => 'mg/L', 'normal_min' => 4.0, 'normal_max' => 8.0],
            ['code' => 'temperature', 'name' => 'Suhu Air', 'unit' => '°C', 'normal_min' => 26.0, 'normal_max' => 32.0],
            ['code' => 'water_level', 'name' => 'Ketinggian Air', 'unit' => 'cm', 'normal_min' => 80.0, 'normal_max' => 150.0]
        ];

        $typeIds = [];
        foreach ($sensorTypes as $type) {
            $typeIds[$type['code']] = \Illuminate\Support\Facades\DB::table('sensor_types')->insertGetId(array_merge($type, [
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ]));
        }

        // ─── Devices (linked to $kolam1->id) ───
        $deviceNodeId = \Illuminate\Support\Facades\DB::table('devices')->insertGetId([
            'pond_id' => $kolam1->id,
            'device_code' => 't01',
            'name' => 'Sensor Node Kolam Alpha',
            'device_type' => 'sensor_node',
            'brand' => 'Espressif',
            'model' => 'ESP32-Aquaculture-v1',
            'serial_number' => 'ESP32987654321',
            'mqtt_topic' => 'pkm2026/t01',
            'ip_address' => '192.168.1.101',
            'location_note' => 'Dipasang di pelampung tengah kolam.',
            'status' => 'active',
            'last_seen_at' => date('Y-m-d H:i:s'),
            'installed_at' => date('Y-m-d H:i:s'),
            'created_at' => date('Y-m-d H:i:s'),
            'updated_at' => date('Y-m-d H:i:s')
        ]);

        $deviceGatewayId = \Illuminate\Support\Facades\DB::table('devices')->insertGetId([
            'pond_id' => $kolam1->id,
            'device_code' => 'DEV-GTW-001',
            'name' => 'Gateway Kolam Alpha',
            'device_type' => 'gateway',
            'brand' => 'Raspberry Pi',
            'model' => 'Pi 4 Model B',
            'serial_number' => 'RPI4B123456789',
            'mqtt_topic' => 'pkm2026/t01/gateway',
            'ip_address' => '192.168.1.100',
            'location_note' => 'Dipasang di tiang dekat pos pemantauan.',
            'status' => 'active',
            'last_seen_at' => date('Y-m-d H:i:s'),
            'installed_at' => date('Y-m-d H:i:s'),
            'created_at' => date('Y-m-d H:i:s'),
            'updated_at' => date('Y-m-d H:i:s')
        ]);

        // ─── Sensors ───
        $sensors = [
            ['device_id' => $deviceNodeId, 'sensor_type_id' => $typeIds['ph'], 'sensor_code' => 'SN-PH-001', 'name' => 'pH Sensor Alpha', 'calibration_date' => date('Y-m-d')],
            ['device_id' => $deviceNodeId, 'sensor_type_id' => $typeIds['tds'], 'sensor_code' => 'SN-TDS-001', 'name' => 'TDS Sensor Alpha', 'calibration_date' => date('Y-m-d')],
            ['device_id' => $deviceNodeId, 'sensor_type_id' => $typeIds['do'], 'sensor_code' => 'SN-DO-001', 'name' => 'DO Sensor Alpha', 'calibration_date' => date('Y-m-d')],
            ['device_id' => $deviceNodeId, 'sensor_type_id' => $typeIds['temperature'], 'sensor_code' => 'SN-TEMP-001', 'name' => 'Suhu Sensor Alpha', 'calibration_date' => date('Y-m-d')],
            ['device_id' => $deviceNodeId, 'sensor_type_id' => $typeIds['water_level'], 'sensor_code' => 'SN-LEVEL-001', 'name' => 'Water Level Sensor Alpha', 'calibration_date' => date('Y-m-d')]
        ];

        $sensorIds = [];
        foreach ($sensors as $sensor) {
            $sensorIds[$sensor['sensor_code']] = \Illuminate\Support\Facades\DB::table('sensors')->insertGetId(array_merge($sensor, [
                'status' => 'active',
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ]));
        }

        // ─── Calibration ───
        \Illuminate\Support\Facades\DB::table('device_calibration_configs')->insert([
            'device_id' => $deviceNodeId,
            'pond_id' => $kolam1->id,
            'ph_slope' => 1.0,
            'ph_offset' => 0.0,
            'do_scale' => 1.0,
            'do_offset' => 0.0,
            'tds_scale' => 1.0,
            'tds_offset' => 0.0,
            'suhu_offset' => 0.0,
            'revision' => 1,
            'is_active' => 1,
            'created_at' => date('Y-m-d H:i:s'),
            'updated_at' => date('Y-m-d H:i:s')
        ]);

        // ─── Readings ───
        $now = date('Y-m-d H:i:s');
        $readings = [
            ['sensor_id' => $sensorIds['SN-PH-001'], 'pond_id' => $kolam1->id, 'value' => 7.42, 'unit' => 'pH', 'recorded_at' => $now],
            ['sensor_id' => $sensorIds['SN-TDS-001'], 'pond_id' => $kolam1->id, 'value' => 850.00, 'unit' => 'ppm', 'recorded_at' => $now],
            ['sensor_id' => $sensorIds['SN-DO-001'], 'pond_id' => $kolam1->id, 'value' => 5.80, 'unit' => 'mg/L', 'recorded_at' => $now],
            ['sensor_id' => $sensorIds['SN-TEMP-001'], 'pond_id' => $kolam1->id, 'value' => 28.50, 'unit' => '°C', 'recorded_at' => $now],
            ['sensor_id' => $sensorIds['SN-LEVEL-001'], 'pond_id' => $kolam1->id, 'value' => 120.00, 'unit' => 'cm', 'recorded_at' => $now]
        ];

        foreach ($readings as $reading) {
            \Illuminate\Support\Facades\DB::table('sensor_readings')->insert(array_merge($reading, [
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s')
            ]));
        }
    }
}
