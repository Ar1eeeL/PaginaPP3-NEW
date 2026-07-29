<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('personas_fisicas')) {
            Schema::create('personas_fisicas', function (Blueprint $table) {
                $table->id();
                $table->string('dni', 20);
                $table->string('nombre', 100);
                $table->string('apellido', 100);
                $table->date('fecha_nacimiento');
                $table->string('direccion', 255)->nullable();
                $table->string('localidad', 100)->nullable();
                $table->string('codigo_postal', 10)->nullable();
                $table->string('telefono', 20)->nullable();
                $table->string('email', 100)->nullable();
                $table->timestamp('creado_en')->useCurrent();
                $table->timestamp('actualizado_en')->useCurrent()->useCurrentOnUpdate();
            });
        }

        if (!Schema::hasTable('profesores')) {
            Schema::create('profesores', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('usuario_id');
                $table->unsignedBigInteger('persona_fisica_id');
                $table->string('titulo', 100)->nullable();
                $table->date('fecha_ingreso')->nullable();
                $table->boolean('activo')->default(1);
                $table->text('observaciones')->nullable();
                $table->timestamp('creado_en')->useCurrent();
                $table->timestamp('actualizado_en')->useCurrent()->useCurrentOnUpdate();
            });
        }

        if (!Schema::hasTable('turnos')) {
            Schema::create('turnos', function (Blueprint $table) {
                $table->id();
                $table->string('nombre');
                $table->time('hora_inicio')->nullable();
                $table->time('hora_fin')->nullable();
            });
            DB::table('turnos')->insert([
                ['nombre' => 'Mañana'],
                ['nombre' => 'Tarde'],
            ]);
        }

        if (!Schema::hasTable('divisiones')) {
            Schema::create('divisiones', function (Blueprint $table) {
                $table->id();
                $table->string('nombre');
            });
            DB::table('divisiones')->insert([
                ['nombre' => 'A'],
                ['nombre' => 'B'],
                ['nombre' => 'C'],
            ]);
        }

        if (!Schema::hasTable('grados')) {
            Schema::create('grados', function (Blueprint $table) {
                $table->id();
                $table->string('nombre', 50);
                $table->unsignedBigInteger('turno_id')->nullable();
                $table->unsignedBigInteger('division_id');
                $table->string('tipo_ciclo')->default('Básico');
                $table->timestamp('creado_en')->useCurrent();
                $table->timestamp('actualizado_en')->useCurrent()->useCurrentOnUpdate();
            });
            // Fake data for grados
            DB::table('grados')->insert([
                ['nombre' => '1°', 'turno_id' => 2, 'division_id' => 1, 'tipo_ciclo' => 'Básico'],
                ['nombre' => '1°', 'turno_id' => 1, 'division_id' => 2, 'tipo_ciclo' => 'Básico'],
                ['nombre' => '2°', 'turno_id' => 2, 'division_id' => 1, 'tipo_ciclo' => 'Básico'],
                ['nombre' => '2°', 'turno_id' => 1, 'division_id' => 2, 'tipo_ciclo' => 'Básico'],
                ['nombre' => '4°', 'turno_id' => 1, 'division_id' => 1, 'tipo_ciclo' => 'Orientado Turismo'],
                ['nombre' => '4°', 'turno_id' => 1, 'division_id' => 2, 'tipo_ciclo' => 'Orientado Economía'],
            ]);
        }

        if (!Schema::hasTable('materias')) {
            Schema::create('materias', function (Blueprint $table) {
                $table->id();
                $table->string('nombre', 100);
                $table->string('descripcion', 255)->nullable();
                $table->integer('horas_semanales')->default(0);
                $table->boolean('activa')->default(1);
                $table->boolean('es_especialidad')->default(0);
                $table->string('especialidad')->default('Común');
                $table->timestamp('creado_en')->useCurrent();
                $table->timestamp('actualizado_en')->useCurrent()->useCurrentOnUpdate();
            });
            // Fake data for materias
            DB::table('materias')->insert([
                ['nombre' => 'Lengua y Literatura 1°', 'especialidad' => 'Común'],
                ['nombre' => 'Matemática 1°', 'especialidad' => 'Común'],
                ['nombre' => 'Historia 2°', 'especialidad' => 'Común'],
                ['nombre' => 'Economía 4°', 'especialidad' => 'Economía'],
                ['nombre' => 'Patrimonio Turístico 4°', 'especialidad' => 'Turismo'],
            ]);
        }

        if (!Schema::hasTable('profesor_materia')) {
            Schema::create('profesor_materia', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('profesor_id');
                $table->unsignedBigInteger('materia_id');
                $table->timestamp('creado_en')->useCurrent();
            });
        }

        if (!Schema::hasTable('profesor_materia_grado')) {
            Schema::create('profesor_materia_grado', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('profesor_id');
                $table->unsignedBigInteger('materia_id');
                $table->unsignedBigInteger('grado_id');
                $table->integer('anio_lectivo');
                $table->timestamp('creado_en')->useCurrent();
                $table->timestamp('actualizado_en')->useCurrent()->useCurrentOnUpdate();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('profesor_materia_grado');
        Schema::dropIfExists('profesor_materia');
        Schema::dropIfExists('materias');
        Schema::dropIfExists('grados');
        Schema::dropIfExists('divisiones');
        Schema::dropIfExists('turnos');
        Schema::dropIfExists('profesores');
        Schema::dropIfExists('personas_fisicas');
    }
};
