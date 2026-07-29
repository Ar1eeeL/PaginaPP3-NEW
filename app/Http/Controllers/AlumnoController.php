<?php

namespace App\Http\Controllers;

use App\Models\Alumno;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AlumnoController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:255',
            'apellido' => 'required|string|max:255',
            'dni' => 'required|string|max:255|unique:users,dni',
            'fecha_nacimiento' => 'required|date',
            'nacionalidad' => 'nullable|string',
            'lugar_nacimiento' => 'nullable|string',
            'direccion' => 'nullable|string',
            'localidad' => 'nullable|string',
            'codigo_postal' => 'nullable|string',
            'telefono' => 'nullable|string',
            'email' => 'nullable|email',
            'curso' => 'required|string',
            'turno' => 'required|string',
            'especialidad' => 'required|string',
            'contacto_emergencia_nombre' => 'nullable|string',
            'contacto_emergencia_telefono' => 'nullable|string',
            'alergias' => 'nullable|string',
            'asistencia_psicopedagogica' => 'boolean',
            'hermanos_institucion' => 'numeric',
            'observaciones' => 'nullable|string',
        ]);

        DB::transaction(function () use ($request) {
            // Create user
            $user = User::create([
                'name' => $request->nombre . ' ' . $request->apellido,
                'dni' => $request->dni,
                'role' => '5', // 5 is Alumno based on AuthController
                'password' => Hash::make($request->dni), // Default password is DNI
                'must_change_password' => true,
            ]);

            // Create alumno record
            Alumno::create([
                'user_id' => $user->id,
                'nombre' => $request->nombre,
                'apellido' => $request->apellido,
                'dni' => $request->dni,
                'fecha_nacimiento' => $request->fecha_nacimiento,
                'nacionalidad' => $request->nacionalidad,
                'lugar_nacimiento' => $request->lugar_nacimiento,
                
                'direccion' => $request->direccion,
                'localidad' => $request->localidad,
                'codigo_postal' => $request->codigo_postal,
                'telefono' => $request->telefono,
                
                'curso' => $request->curso,
                'turno' => $request->turno,
                'especialidad' => $request->especialidad,
                
                'contacto_emergencia_nombre' => $request->contacto_emergencia_nombre,
                'contacto_emergencia_telefono' => $request->contacto_emergencia_telefono,
                
                'alergias' => $request->alergias,
                'asistencia_psicopedagogica' => $request->boolean('asistencia_psicopedagogica'),
                
                'hermanos_institucion' => $request->hermanos_institucion ?? 0,
                'observaciones' => $request->observaciones,
            ]);
        });

        return back()->with('success', 'Alumno inscrito correctamente.');
    }

    private function getMateriasParaAlumno($alumno)
    {
        $materias = [];
        if (!$alumno) return $materias;

        $curso = $alumno->curso; // Ej: "1° A"
        $grado = substr($curso, 0, 2); // "1°"
        $division = substr($curso, 3, 1); // "A" o "B"

        // Materias del Ciclo Básico comunes a todos
        $comunesBasico = [
            'Lengua y Literatura', 'Matemática', 'Biología', 'Física', 'Química', 
            'Geografía', 'Historia', 'Inglés', 'Educación Artística', 
            'Educación Tecnológica', 'Ciudadanía y Participación', 'Educación Física'
        ];

        // Materias del Ciclo Orientado comunes
        $comunesOrientado = [
            'Matemática', 'Lengua y Literatura', 'Biología', 'Geografía', 
            'Historia', 'Inglés', 'Educación Artística', 'Educación Física', 
            'Formación para la Vida y el Trabajo'
        ];

        if (in_array($grado, ['1°', '2°', '3°'])) {
            $materias = $comunesBasico;
            if ($grado === '3°') {
                $materias[] = 'Formación para la Vida y el Trabajo';
            }
        } else {
            $materias = $comunesOrientado;
            
            // Agregar materias específicas
            if ($division === 'B') {
                // Economía
                $materias = array_merge($materias, [
                    'Sistemas de Información Contable', 'Economía', 'Administración'
                ]);
            } elseif ($division === 'A') {
                // Turismo
                $materias = array_merge($materias, [
                    'Turismo y Sociedad', 'Administración de Organizaciones Turísticas', 'Patrimonio Turístico'
                ]);
            }
        }

        return $materias;
    }

    public function dashboard()
    {
        $user = auth()->user();
        
        return \Inertia\Inertia::render('alumno/dashboard');
    }

    public function materias()
    {
        $user = auth()->user();
        $materias = $this->getMateriasParaAlumno($user->alumno);

        return \Inertia\Inertia::render('alumno/materias', [
            'materias' => $materias
        ]);
    }
}
