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
    Route::inertia('/admin/profesores/registrar', 'admin/profesores/registrar')->name('admin.profesores.registrar');
});
