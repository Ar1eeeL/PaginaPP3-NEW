<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('alumnos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            
            // Datos Personales
            $table->string('nombre');
            $table->string('apellido');
            $table->string('dni')->unique();
            $table->date('fecha_nacimiento')->nullable();
            $table->string('nacionalidad')->nullable();
            $table->string('lugar_nacimiento')->nullable();
            
            // Contacto
            $table->string('direccion')->nullable();
            $table->string('localidad')->nullable();
            $table->string('codigo_postal')->nullable();
            $table->string('telefono')->nullable();
            
            // Academico
            $table->string('curso')->nullable(); // e.g. 1A, 2B
            $table->string('turno')->nullable();
            $table->string('especialidad')->nullable();
            
            // Emergencia
            $table->string('contacto_emergencia_nombre')->nullable();
            $table->string('contacto_emergencia_telefono')->nullable();
            
            // Salud
            $table->text('alergias')->nullable();
            $table->boolean('asistencia_psicopedagogica')->default(false);
            
            // Otros
            $table->integer('hermanos_institucion')->default(0);
            $table->text('observaciones')->nullable();
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('alumnos');
    }
};
