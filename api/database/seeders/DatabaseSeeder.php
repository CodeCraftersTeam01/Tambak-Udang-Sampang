<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Role;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // Buat Roles
        $roleSuperAdmin = Role::create(['name' => 'super_admin']);
        $rolePetambak = Role::create(['name' => 'petambak']);

        // Buat User Super Admin
        User::create([
            'role_id' => $roleSuperAdmin->id,
            'name' => 'Budi Super Admin',
            'email' => 'admin@tambak.com',
            'password' => Hash::make('password123')
        ]);

        // Buat User Petambak
        User::create([
            'role_id' => $rolePetambak->id,
            'name' => 'Joko Petambak',
            'email' => 'joko@tambak.com',
            'password' => Hash::make('password123')
        ]);
    }
}
