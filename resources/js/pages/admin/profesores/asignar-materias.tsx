import React, { useState } from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import AdminLayout from '../../../layouts/AdminLayout';

export default function AsignarMaterias({ profesor, cursosData }: any) {
    const [expandedCourse, setExpandedCourse] = useState<string | null>(null);
    
    const { data, setData, post, processing } = useForm({
        selectedMaterias: {} as { [cursoId: string]: string[] }
    });

    const toggleCourse = (cursoId: string) => {
        setExpandedCourse(expandedCourse === cursoId ? null : cursoId);
    };

    const toggleMateria = (cursoId: string, materia: string) => {
        setData('selectedMaterias', {
            ...data.selectedMaterias,
            [cursoId]: data.selectedMaterias[cursoId]?.includes(materia)
                ? data.selectedMaterias[cursoId].filter(m => m !== materia)
                : [...(data.selectedMaterias[cursoId] || []), materia]
        });
    };

    const getTotalSelected = () => {
        return Object.values(data.selectedMaterias).reduce((acc, curr) => acc + curr.length, 0);
    };

    const handleSave = () => {
        post(`/admin/profesores/${profesor.id}/asignar-materias`);
    };

    return (
        <AdminLayout>
            <Head title="Asignar Materias" />
            
            <div className="p-4 md:p-6 lg:p-8 max-w-5xl mx-auto">
                
                {/* Header */}
                <div className="mb-6 md:mb-8 text-center md:text-left flex flex-col md:flex-row md:items-end justify-between gap-4">
                    <div>
                        <div className="flex items-center gap-3 mb-2">
                            <span className="bg-[#008f39]/10 text-[#008f39] text-xs font-bold px-3 py-1 rounded-full uppercase tracking-widest">Paso 2 de 2</span>
                        </div>
                        <h1 className="text-2xl md:text-3xl font-black text-slate-800 tracking-tight">Asignar Materias</h1>
                        <p className="text-sm md:text-base text-slate-500 font-medium mt-1">Selecciona los cursos en los que enseñará {profesor.nombre} {profesor.apellido}.</p>
                    </div>
                    <div className="bg-white border border-slate-200 rounded-xl px-5 py-3 text-center flex items-center gap-4 shadow-sm">
                        <p className="text-xs text-slate-500 font-bold uppercase tracking-wider">Total Seleccionadas</p>
                        <p className="text-2xl font-black text-[#008f39]">{getTotalSelected()}</p>
                    </div>
                </div>

                <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative mb-6">
                    <div className="absolute top-0 left-0 w-1 h-full bg-[#008f39]"></div>
                    <div className="p-6 md:p-8">
                        <div className="flex items-center gap-3 mb-6 border-b border-slate-100 pb-4">
                            <div className="p-2 bg-[#008f39]/10 rounded-lg text-[#008f39]">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                                </svg>
                            </div>
                            <h3 className="text-lg font-bold text-[#003057]">Cursos y Materias para {profesor.nombre}</h3>
                        </div>

                        <div className="space-y-3">
                            {cursosData.map((curso: any) => (
                                <div key={curso.id} className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden transition-all duration-300">
                                    {/* Course Header (Clickable) */}
                                    <button 
                                        type="button"
                                        onClick={() => toggleCourse(curso.id)}
                                        className={`w-full p-5 flex items-center justify-between text-left hover:bg-slate-50 transition-colors ${expandedCourse === curso.id ? 'border-b border-slate-100 bg-slate-50' : ''}`}
                                    >
                                        <div className="flex items-center gap-4">
                                            <div className={`w-10 h-10 rounded-xl flex items-center justify-center font-bold text-white shadow-sm ${curso.id.endsWith('B') ? 'bg-[#008f39]' : 'bg-[#003057]'}`}>
                                                {curso.id}
                                            </div>
                                            <div>
                                                <h3 className="text-lg font-black text-[#003057]">{curso.nombre}</h3>
                                                <div className="flex items-center gap-2 mt-1">
                                                    <span className="text-[11px] font-bold text-slate-500 bg-slate-200 px-2 py-0.5 rounded uppercase">{curso.turno}</span>
                                                    {curso.especialidad && (
                                                        <span className={`text-[11px] font-bold px-2 py-0.5 rounded uppercase ${curso.id.endsWith('B') ? 'bg-[#008f39]/10 text-[#008f39]' : 'bg-[#003057]/10 text-[#003057]'}`}>
                                                            {curso.especialidad}
                                                        </span>
                                                    )}
                                                </div>
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-4">
                                            {/* Counter for this course */}
                                            {data.selectedMaterias[curso.grado_id]?.length > 0 && (
                                                <span className="bg-[#003057] text-white text-xs font-bold px-2 py-1 rounded-full">
                                                    {data.selectedMaterias[curso.grado_id].length}
                                                </span>
                                            )}
                                            <svg xmlns="http://www.w3.org/2000/svg" className={`h-5 w-5 text-slate-400 transition-transform duration-300 ${expandedCourse === curso.id ? 'rotate-180' : ''}`} fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                            </svg>
                                        </div>
                                    </button>

                                    {/* Subjects List (Expandable) */}
                                    {expandedCourse === curso.id && (
                                        <div className="p-5 bg-slate-50/50">
                                            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
                                                {curso.materias.map((materia: string, index: number) => {
                                                    const isSelected = data.selectedMaterias[curso.grado_id]?.includes(materia);
                                                    return (
                                                        <button
                                                            key={index}
                                                            type="button"
                                                            onClick={() => toggleMateria(curso.grado_id, materia)}
                                                            className={`flex items-center gap-3 p-3 rounded-xl border text-left transition-all ${
                                                                isSelected 
                                                                    ? 'bg-[#008f39]/5 border-[#008f39] shadow-sm' 
                                                                    : 'bg-white border-slate-200 hover:border-[#003057]/30 hover:shadow-sm'
                                                            }`}
                                                        >
                                                            <div className={`w-5 h-5 rounded flex-shrink-0 flex items-center justify-center border transition-colors ${
                                                                isSelected
                                                                    ? 'bg-[#008f39] border-[#008f39]'
                                                                    : 'bg-white border-slate-300'
                                                            }`}>
                                                                {isSelected && (
                                                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-3.5 w-3.5 text-white" viewBox="0 0 20 20" fill="currentColor">
                                                                        <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                                                                    </svg>
                                                                )}
                                                            </div>
                                                            <span className={`text-sm font-medium ${isSelected ? 'text-[#003057]' : 'text-slate-600'}`}>
                                                                {materia}
                                                            </span>
                                                        </button>
                                                    );
                                                })}
                                            </div>
                                        </div>
                                    )}
                                </div>
                            ))}
                        </div>
                    </div>
                </div>

                {/* Submit Action */}
                <div className="mt-8 flex justify-between items-center bg-white p-6 rounded-2xl shadow-sm border border-slate-200 sticky bottom-6 z-20">
                    <Link href="/admin/profesores/registrar" className="text-slate-500 font-bold text-sm hover:text-[#003057] transition-colors">
                        ← Volver a Datos Profesionales
                    </Link>
                    <button 
                        type="button" 
                        onClick={handleSave}
                        disabled={processing || getTotalSelected() === 0}
                        className={`px-8 py-3.5 rounded-xl font-bold text-[14px] transition-all flex items-center gap-2 ${
                            getTotalSelected() > 0 
                            ? 'bg-[#008f39] hover:bg-[#0b5f38] text-white shadow-md shadow-[#008f39]/20 hover:-translate-y-0.5' 
                            : 'bg-slate-200 text-slate-400 cursor-not-allowed'
                        }`}
                    >
                        Confirmar Asignación
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" />
                        </svg>
                    </button>
                </div>
                
            </div>
        </AdminLayout>
    );
}
