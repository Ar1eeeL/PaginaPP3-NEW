import React from 'react';
import { Head, usePage } from '@inertiajs/react';
import AlumnoLayout from '@/layouts/AlumnoLayout';

export default function MisMaterias({ materias = [] }: { materias?: string[] }) {
    const { auth } = usePage().props as any;
    const userName = auth?.user?.name || "Alumno";

    return (
        <AlumnoLayout>
            <Head title="Mis Materias - Campus Virtual" />
            
            <div className="max-w-[1400px] mx-auto space-y-6">
                
                {/* Header Banner */}
                <div className="bg-[#003057] rounded-3xl p-8 md:p-10 text-white shadow-lg relative overflow-hidden flex flex-col md:flex-row items-start md:items-center justify-between">
                    <div className="relative z-10 space-y-2">
                        <span className="bg-[#008f39] text-white text-xs font-bold px-3 py-1 rounded-full uppercase tracking-widest">Plan de Estudios</span>
                        <h1 className="text-3xl md:text-5xl font-black tracking-tight mt-4">Mis Materias</h1>
                        <p className="text-white/80 text-sm md:text-base font-medium max-w-lg mt-2">
                            Aquí encontrarás todas las asignaturas correspondientes a tu curso actual. Selecciona una para ver su contenido, tareas y calificaciones.
                        </p>
                    </div>
                </div>

                {/* Materias Grid */}
                <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 md:p-8">
                    <div className="flex items-center justify-between mb-8 border-b border-slate-100 pb-4">
                        <h2 className="text-xl font-bold text-[#003057] flex items-center gap-2">
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-[#008f39]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                            </svg>
                            Asignaturas en Curso
                        </h2>
                        <span className="text-sm font-bold text-[#008f39] bg-[#008f39]/10 px-3 py-1 rounded-full">{materias.length} Materias</span>
                    </div>
                    
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        {materias.length > 0 ? (
                            materias.map((materia, index) => (
                                <div key={index} className="flex flex-col p-5 rounded-2xl border border-slate-200 bg-slate-50 hover:bg-white hover:border-[#008f39]/50 hover:shadow-md transition-all group cursor-pointer relative overflow-hidden">
                                    <div className="absolute top-0 right-0 w-16 h-16 bg-gradient-to-bl from-[#008f39]/10 to-transparent rounded-bl-3xl -mr-8 -mt-8 group-hover:scale-150 transition-transform duration-500"></div>
                                    
                                    <div className="w-12 h-12 rounded-xl bg-white shadow-sm border border-slate-100 text-[#003057] flex items-center justify-center mb-4 group-hover:bg-[#008f39] group-hover:text-white group-hover:border-[#008f39] transition-colors relative z-10">
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                                        </svg>
                                    </div>
                                    
                                    <div className="flex-1 relative z-10">
                                        <h3 className="font-bold text-[#003057] text-lg group-hover:text-[#008f39] transition-colors leading-tight mb-2">{materia}</h3>
                                        <div className="flex items-center gap-4 mt-auto pt-4 border-t border-slate-200/50">
                                            <span className="text-xs text-slate-500 font-bold flex items-center gap-1 hover:text-[#003057]">
                                                <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                                </svg>
                                                Ver clases
                                            </span>
                                            <span className="text-xs text-slate-500 font-bold flex items-center gap-1 hover:text-[#003057]">
                                                <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                                </svg>
                                                Tareas
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            ))
                        ) : (
                            <div className="col-span-full py-16 text-center text-slate-500 flex flex-col items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-16 w-16 text-slate-300 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <p className="text-lg font-bold text-slate-600 mb-1">No hay materias asignadas</p>
                                <p className="text-sm">Aún no tienes asignaturas para tu curso actual.</p>
                            </div>
                        )}
                    </div>
                </div>

            </div>
        </AlumnoLayout>
    );
}
