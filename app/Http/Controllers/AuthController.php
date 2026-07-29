<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class AuthController extends Controller
{
    public function showLogin()
    {
        return Inertia::render('auth/login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'dni' => ['required'],
            'password' => ['required'],
        ]);

        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();

            $role = (string) Auth::user()->role;
            
            $route = match($role) {
                '1' => 'admin.dashboard',
                '2' => 'director.dashboard',
                '3' => 'preceptor.dashboard',
                '4' => 'tesoreria.dashboard',
                '5' => 'alumno.dashboard',
                '6' => 'tutor.dashboard',
                default => 'home',
            };

            // Redirige si la ruta existe, de lo contrario manda al home para que no de error
            if (\Illuminate\Support\Facades\Route::has($route)) {
                return redirect()->route($route);
            }

            return redirect()->route('home');
        }

        return back()->withErrors([
            'dni' => 'Las credenciales proporcionadas no coinciden con nuestros registros.',
        ]);
    }

    public function logout(Request $request)
    {
        Auth::logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('home');
    }
}
