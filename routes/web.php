<?php

use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

// Define your routes here
Route::inertia('/', 'welcome')->name('home');

Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

Route::middleware('auth')->group(function () {
    Route::inertia('/admin/dashboard', 'admin/dashboard')->name('admin.dashboard');
    Route::inertia('/admin/alumnos/inscribir', 'admin/alumnos/inscribir')->name('admin.alumnos.inscribir');
    Route::post('/admin/alumnos/inscribir', [\App\Http\Controllers\AlumnoController::class, 'store']);
    // Profesores
    Route::inertia('/admin/profesores/registrar', 'admin/profesores/registrar')->name('admin.profesores.registrar');
    Route::post('/admin/profesores/registrar', [\App\Http\Controllers\ProfesorController::class, 'store']);
    Route::get('/admin/profesores/{id}/asignar-materias', [\App\Http\Controllers\ProfesorController::class, 'asignarMaterias'])->name('admin.profesores.asignar');
    Route::post('/admin/profesores/{id}/asignar-materias', [\App\Http\Controllers\ProfesorController::class, 'storeMaterias']);
    Route::inertia('/admin/preceptores/registrar', 'admin/preceptores/registrar')->name('admin.preceptores.registrar');
    Route::inertia('/admin/tutores/registrar', 'admin/tutores/registrar')->name('admin.tutores.registrar');
    Route::inertia('/admin/directores/registrar', 'admin/directores/registrar')->name('admin.directores.registrar');
    
    // Alumno Routes
    Route::get('/alumno/dashboard', [\App\Http\Controllers\AlumnoController::class, 'dashboard'])->name('alumno.dashboard');
    Route::get('/alumno/materias', [\App\Http\Controllers\AlumnoController::class, 'materias'])->name('alumno.materias');

    // Force Password Change
    Route::get('/cambiar-password', [\App\Http\Controllers\AuthController::class, 'showChangePassword'])->name('password.change');
    Route::post('/cambiar-password', [\App\Http\Controllers\AuthController::class, 'updatePassword']);
});
