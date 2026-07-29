<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::factory()->create([
            'name' => 'Admin Sistema',
            'dni' => '12345678',
            'role' => '1',
            'password' => '12345678',
        ]);

        User::factory()->create([
            'name' => 'Alumno Prueba',
            'dni' => '87654321',
            'role' => '5',
            'password' => '12345678',
        ]);
    }
}
