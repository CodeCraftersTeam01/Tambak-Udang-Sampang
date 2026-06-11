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
    }
}
