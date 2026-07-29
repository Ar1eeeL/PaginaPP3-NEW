<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Inertia\Inertia;

class ProfesorController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:100',
            'apellido' => 'required|string|max:100',
            'dni' => 'required|string|max:20|unique:personas_fisicas,dni',
            'fecha_nacimiento' => 'required|date',
            'email' => 'nullable|email|max:100',
            'telefono' => 'nullable|string|max:20',
            'titulo' => 'required|string|max:100',
            'fecha_ingreso' => 'required|date',
        ]);

        DB::beginTransaction();
        try {
            // 1. Create User
            $user = User::create([
                'name' => $request->nombre . ' ' . $request->apellido,
                'email' => $request->email ?? ($request->dni . '@example.com'), // Fallback email if null
                'password' => Hash::make($request->dni), // Initial password is DNI
                'role' => 'Profesor',
                'must_change_password' => true,
            ]);

            // 2. Create Persona Fisica
            $personaId = DB::table('personas_fisicas')->insertGetId([
                'dni' => $request->dni,
                'nombre' => $request->nombre,
                'apellido' => $request->apellido,
                'fecha_nacimiento' => $request->fecha_nacimiento,
                'email' => $request->email,
                'telefono' => $request->telefono,
                'creado_en' => now(),
                'actualizado_en' => now(),
            ]);

            // 3. Create Profesor
            $profesorId = DB::table('profesores')->insertGetId([
                'usuario_id' => $user->id,
                'persona_fisica_id' => $personaId,
                'titulo' => $request->titulo,
                'fecha_ingreso' => $request->fecha_ingreso,
                'activo' => 1,
                'creado_en' => now(),
                'actualizado_en' => now(),
            ]);

            DB::commit();

            return redirect()->route('admin.profesores.asignar', ['id' => $profesorId]);
        } catch (\Exception $e) {
            DB::rollBack();
            return back()->withErrors(['error' => 'Error al registrar el profesor: ' . $e->getMessage()]);
        }
    }

    public function asignarMaterias($id)
    {
        $profesor = DB::table('profesores')
            ->join('personas_fisicas', 'profesores.persona_fisica_id', '=', 'personas_fisicas.id')
            ->where('profesores.id', $id)
            ->select('profesores.id', 'personas_fisicas.nombre', 'personas_fisicas.apellido')
            ->first();

        if (!$profesor) {
            abort(404, 'Profesor no encontrado');
        }

        // Obtener grados con sus divisiones y turnos
        $gradosRaw = DB::table('grados')
            ->leftJoin('turnos', 'grados.turno_id', '=', 'turnos.id')
            ->leftJoin('divisiones', 'grados.division_id', '=', 'divisiones.id')
            ->select(
                'grados.id as grado_id',
                'grados.nombre as grado_nombre',
                'turnos.nombre as turno_nombre',
                'divisiones.nombre as division_nombre',
                'grados.tipo_ciclo'
            )
            ->get();

        $materiasRaw = DB::table('materias')->where('activa', 1)->get();

        $cursosData = [];

        foreach ($gradosRaw as $g) {
            $cursoId = str_replace('°', '', $g->grado_nombre) . $g->division_nombre; // Ej: 1A
            
            // Especialidad
            $especialidad = null;
            if (str_contains($g->tipo_ciclo, 'Economía')) {
                $especialidad = 'Economía';
            } elseif (str_contains($g->tipo_ciclo, 'Turismo')) {
                $especialidad = 'Turismo';
            }

            // Filtrar materias por grado (Básico vs Orientado)
            $materiasDelGrado = [];
            foreach ($materiasRaw as $m) {
                // Las materias tienen el nombre con el grado, ej "Matemática 1°"
                if (str_contains($m->nombre, $g->grado_nombre)) {
                    // Si es ciclo orientado, filtrar por especialidad
                    if ($g->tipo_ciclo !== 'Básico' && $m->especialidad !== 'Común') {
                        if ($m->especialidad === $especialidad) {
                            $materiasDelGrado[] = str_replace(" " . $g->grado_nombre, "", $m->nombre);
                        }
                    } else {
                        $materiasDelGrado[] = str_replace(" " . $g->grado_nombre, "", $m->nombre);
                    }
                }
            }

            $cursosData[] = [
                'id' => $cursoId,
                'grado_id' => $g->grado_id,
                'nombre' => $g->grado_nombre . ' Año "' . $g->division_nombre . '"',
                'turno' => $g->turno_nombre,
                'especialidad' => $especialidad,
                'materias' => $materiasDelGrado
            ];
        }

        return Inertia::render('admin/profesores/asignar-materias', [
            'profesor' => $profesor,
            'cursosData' => $cursosData
        ]);
    }

    public function storeMaterias(Request $request, $id)
    {
        $selectedMaterias = $request->input('selectedMaterias', []); // [grado_id => [nombre_materia, ...]]

        $materiasRaw = DB::table('materias')->get();
        
        DB::beginTransaction();
        try {
            // Eliminar asignaciones previas para simplificar (opcional, si quisieras que sea actualizable)
            // DB::table('profesor_materia_grado')->where('profesor_id', $id)->delete();

            $materiasInsertadas = [];

            foreach ($selectedMaterias as $gradoId => $nombresMaterias) {
                // Fetch the grado to get its name (e.g. "1°")
                $grado = DB::table('grados')->where('id', $gradoId)->first();
                if (!$grado) continue;

                foreach ($nombresMaterias as $nombreMateria) {
                    // Reconstruir el nombre de la materia ("Matemática" + " 1°")
                    $nombreBuscado = $nombreMateria . ' ' . $grado->nombre;
                    
                    $materia = $materiasRaw->where('nombre', $nombreBuscado)->first();
                    if ($materia) {
                        DB::table('profesor_materia_grado')->insert([
                            'profesor_id' => $id,
                            'materia_id' => $materia->id,
                            'grado_id' => $gradoId,
                            'anio_lectivo' => date('Y'),
                            'creado_en' => now(),
                            'actualizado_en' => now(),
                        ]);

                        // Evitar duplicados en profesor_materia (que es una tabla general)
                        if (!in_array($materia->id, $materiasInsertadas)) {
                            $exists = DB::table('profesor_materia')
                                ->where('profesor_id', $id)
                                ->where('materia_id', $materia->id)
                                ->exists();
                                
                            if (!$exists) {
                                DB::table('profesor_materia')->insert([
                                    'profesor_id' => $id,
                                    'materia_id' => $materia->id,
                                    'creado_en' => now(),
                                ]);
                            }
                            $materiasInsertadas[] = $materia->id;
                        }
                    }
                }
            }

            DB::commit();

            return redirect()->route('admin.profesores.registrar')->with('success', 'Profesor y materias asignadas exitosamente.');
        } catch (\Exception $e) {
            DB::rollBack();
            return back()->withErrors(['error' => 'Error al asignar materias: ' . $e->getMessage()]);
        }
    }
}
