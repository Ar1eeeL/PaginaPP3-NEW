import { Head, useForm } from '@inertiajs/react';
import AdminLayout from '../../../layouts/AdminLayout';
import React, { useState } from 'react';

export default function InscribirAlumno() {
    const [showSuccess, setShowSuccess] = useState(false);

    const { data, setData, post, processing, errors, reset } = useForm({
        nombre: '',
        apellido: '',
        dni: '',
        fecha_nacimiento: '',
        nacionalidad: '',
        lugar_nacimiento: '',
        direccion: '',
        localidad: '',
        codigo_postal: '',
        telefono: '',
        email: '',
        curso: '',
        turno: '',
        especialidad: '',
        contacto_emergencia_nombre: '',
        contacto_emergencia_telefono: '',
        alergias: '',
        asistencia_psicopedagogica: false,
        hermanos_institucion: 0,
        observaciones: ''
    });

    const submit = (e: React.FormEvent) => {
        e.preventDefault();
        post('/admin/alumnos/inscribir', {
            onSuccess: () => {
                setShowSuccess(true);
                reset();
                
                // Clear the derived readonly inputs
                const turnoInput = document.getElementById('turno_display') as HTMLInputElement;
                const espInput = document.getElementById('especialidad_display') as HTMLInputElement;
                if(turnoInput) turnoInput.value = '';
                if(espInput) espInput.value = '';

                setTimeout(() => setShowSuccess(false), 3000);
            }
        });
    };

    return (
        <AdminLayout>
            <Head title="Inscribir Alumno" />
            
            {/* Success Toast */}
            {showSuccess && (
                <div className="fixed top-20 right-8 z-50 animate-fade-in-down">
                    <div className="bg-[#008f39] text-white px-6 py-4 rounded-xl shadow-lg shadow-[#008f39]/20 flex items-center gap-3 border border-[#00752d]">
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        <div>
                            <p className="font-bold text-[15px]">¡Éxito!</p>
                            <p className="text-sm text-green-100">Alumno inscripto correctamente.</p>
                        </div>
                    </div>
                </div>
            )}

            <div className="p-4 md:p-6 lg:p-8 max-w-[1400px] mx-auto">
                
                {/* Header */}
                <div className="mb-6 md:mb-8">
                    <h1 className="text-2xl md:text-3xl font-black text-slate-800 tracking-tight">Nueva Inscripción</h1>
                    <p className="text-sm md:text-base text-slate-500 font-medium mt-1">Completa los datos para registrar a un nuevo alumno en el sistema.</p>
                </div>

                <form onSubmit={submit} className="grid grid-cols-1 xl:grid-cols-12 gap-6 items-start">
                    
                    {/* Left Column (Primary Info) */}
                    <div className="xl:col-span-8 space-y-6">
                        
                        {/* Datos Personales Card */}
                        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative">
                            <div className="absolute top-0 left-0 w-1 h-full bg-[#008f39]"></div>
                            <div className="p-6 md:p-8">
                                <div className="flex items-center gap-3 mb-6">
                                    <div className="p-2 bg-[#008f39]/10 rounded-lg text-[#008f39]">
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                        </svg>
                                    </div>
                                    <h3 className="text-lg font-bold text-[#003057]">Datos Personales</h3>
                                </div>
                                
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Nombre <span className="text-red-500">*</span></label>
                                        <input type="text" value={data.nombre} onChange={e => setData('nombre', e.target.value)} required className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. Juan Martín" />
                                        {errors.nombre && <p className="text-red-500 text-xs mt-1">{errors.nombre}</p>}
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Apellido <span className="text-red-500">*</span></label>
                                        <input type="text" value={data.apellido} onChange={e => setData('apellido', e.target.value)} required className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. Pérez" />
                                        {errors.apellido && <p className="text-red-500 text-xs mt-1">{errors.apellido}</p>}
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">DNI <span className="text-red-500">*</span></label>
                                        <input type="text" value={data.dni} onChange={e => setData('dni', e.target.value)} required className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Sin puntos ni espacios" />
                                        {errors.dni && <p className="text-red-500 text-xs mt-1">{errors.dni}</p>}
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Fecha de Nacimiento <span className="text-red-500">*</span></label>
                                        <input type="date" value={data.fecha_nacimiento} onChange={e => setData('fecha_nacimiento', e.target.value)} required className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" />
                                        {errors.fecha_nacimiento && <p className="text-red-500 text-xs mt-1">{errors.fecha_nacimiento}</p>}
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Nacionalidad <span className="text-red-500">*</span></label>
                                        <select value={data.nacionalidad} onChange={e => setData('nacionalidad', e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all cursor-pointer">
                                            <option value="">-- Seleccione --</option>
                                            <option value="Argentina">Argentina</option>
                                            <option value="Chilena">Chilena</option>
                                            <option value="Uruguaya">Uruguaya</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Lugar de Nac. <span className="text-red-500">*</span></label>
                                        <input type="text" value={data.lugar_nacimiento} onChange={e => setData('lugar_nacimiento', e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Provincia, País" />
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Datos de Contacto Card */}
                        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative">
                            <div className="absolute top-0 left-0 w-1 h-full bg-[#008f39]"></div>
                            <div className="p-6 md:p-8">
                                <div className="flex items-center gap-3 mb-6">
                                    <div className="p-2 bg-[#008f39]/10 rounded-lg text-[#008f39]">
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                                        </svg>
                                    </div>
                                    <h3 className="text-lg font-bold text-[#003057]">Información de Contacto</h3>
                                </div>
                                
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                                    <div className="md:col-span-2">
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Dirección Completa <span className="text-red-500">*</span></label>
                                        <input type="text" value={data.direccion} onChange={e => setData('direccion', e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Calle, Número, Piso/Depto" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Localidad <span className="text-red-500">*</span></label>
                                        <input type="text" value={data.localidad} onChange={e => setData('localidad', e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. Córdoba Capital" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Código Postal <span className="text-red-500">*</span></label>
                                        <input type="text" value={data.codigo_postal} onChange={e => setData('codigo_postal', e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. 5000" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Teléfono Personal <span className="text-red-500">*</span></label>
                                        <input type="text" value={data.telefono} onChange={e => setData('telefono', e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Código de área + Número" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Correo Electrónico <span className="text-red-500">*</span></label>
                                        <input type="email" value={data.email} onChange={e => setData('email', e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="alumno@ejemplo.com" />
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Datos Académicos Card */}
                        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative">
                            <div className="absolute top-0 left-0 w-1 h-full bg-[#008f39]"></div>
                            <div className="p-6 md:p-8">
                                <div className="flex items-center gap-3 mb-6">
                                    <div className="p-2 bg-[#008f39]/10 rounded-lg text-[#008f39]">
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                                        </svg>
                                    </div>
                                    <h3 className="text-lg font-bold text-[#003057]">Inscripción Académica</h3>
                                </div>
                                
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                                    <div className="md:col-span-2">
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Curso y División <span className="text-red-500">*</span></label>
                                        <select 
                                            value={data.curso}
                                            required
                                            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all cursor-pointer"
                                            onChange={(e) => {
                                                const select = e.target;
                                                const selectedOption = select.options[select.selectedIndex];
                                                const turno = selectedOption.getAttribute('data-turno') || '';
                                                const especialidad = selectedOption.getAttribute('data-especialidad') || '';
                                                
                                                setData(prev => ({
                                                    ...prev,
                                                    curso: select.value,
                                                    turno: turno,
                                                    especialidad: especialidad
                                                }));
                                            }}
                                        >
                                            <option value="">-- Seleccione curso --</option>
                                            <optgroup label="Ciclo Básico (Sin Especialidad)">
                                                <option value="1A" data-turno="Tarde" data-especialidad="No Aplica">1° Año "A"</option>
                                                <option value="1B" data-turno="Mañana" data-especialidad="No Aplica">1° Año "B"</option>
                                                <option value="2A" data-turno="Tarde" data-especialidad="No Aplica">2° Año "A"</option>
                                                <option value="2B" data-turno="Mañana" data-especialidad="No Aplica">2° Año "B"</option>
                                                <option value="3A" data-turno="Mañana" data-especialidad="No Aplica">3° Año "A"</option>
                                                <option value="3B" data-turno="Mañana" data-especialidad="No Aplica">3° Año "B"</option>
                                            </optgroup>
                                            <optgroup label="Ciclo Orientado (Con Especialidad)">
                                                <option value="4A" data-turno="Mañana" data-especialidad="Turismo">4° Año "A"</option>
                                                <option value="4B" data-turno="Mañana" data-especialidad="Economía">4° Año "B"</option>
                                                <option value="5A" data-turno="Mañana" data-especialidad="Turismo">5° Año "A"</option>
                                                <option value="5B" data-turno="Mañana" data-especialidad="Economía">5° Año "B"</option>
                                                <option value="6A" data-turno="Mañana" data-especialidad="Turismo">6° Año "A"</option>
                                                <option value="6B" data-turno="Mañana" data-especialidad="Economía">6° Año "B"</option>
                                            </optgroup>
                                        </select>
                                        {errors.curso && <p className="text-red-500 text-xs mt-1">{errors.curso}</p>}
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Turno Asignado</label>
                                        <input 
                                            type="text" 
                                            readOnly 
                                            value={data.turno}
                                            className="w-full bg-slate-100 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-500 cursor-not-allowed font-medium" 
                                            placeholder="Automático según curso" 
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Especialidad Asignada</label>
                                        <input 
                                            type="text" 
                                            readOnly 
                                            value={data.especialidad}
                                            className="w-full bg-slate-100 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-500 cursor-not-allowed font-medium" 
                                            placeholder="Automático según curso" 
                                        />
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>

                    {/* Right Column (Secondary Info) */}
                    <div className="xl:col-span-4 space-y-6">
                        
                        {/* Emergencia Card */}
                        <div className="bg-[#003057] rounded-2xl shadow-sm border border-[#002244] overflow-hidden text-white relative">
                            <div className="absolute top-0 right-0 opacity-10">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-32 w-32 -mt-4 -mr-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                                </svg>
                            </div>
                            <div className="p-6 relative z-10">
                                <h3 className="text-lg font-bold text-[#ffc107] mb-5">Contacto de Emergencia</h3>
                                <div className="space-y-4">
                                    <div>
                                        <label className="block text-xs font-bold text-[#daf4f6] uppercase tracking-wider mb-2">Nombre del Contacto</label>
                                        <input type="text" value={data.contacto_emergencia_nombre} onChange={e => setData('contacto_emergencia_nombre', e.target.value)} className="w-full bg-white/10 border border-white/20 rounded-xl px-4 py-2.5 text-sm text-white placeholder-white/50 outline-none focus:bg-white/20 focus:border-white transition-all" placeholder="Familiar o Tutor" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-[#daf4f6] uppercase tracking-wider mb-2">Teléfono de Emergencia</label>
                                        <input type="text" value={data.contacto_emergencia_telefono} onChange={e => setData('contacto_emergencia_telefono', e.target.value)} className="w-full bg-white/10 border border-white/20 rounded-xl px-4 py-2.5 text-sm text-white placeholder-white/50 outline-none focus:bg-white/20 focus:border-white transition-all" placeholder="Solo urgencias" />
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Salud Card */}
                        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden p-6">
                            <div className="flex items-center gap-3 mb-5">
                                <div className="p-2 bg-red-50 rounded-lg text-red-500">
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                                    </svg>
                                </div>
                                <h3 className="text-[15px] font-bold text-slate-800">Ficha Médica Básica</h3>
                            </div>
                            
                            <div className="space-y-4">
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Alergias o Condiciones</label>
                                    <textarea rows={3} value={data.alergias} onChange={e => setData('alergias', e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-700 outline-none focus:bg-white focus:border-red-400 focus:ring-2 focus:ring-red-100 transition-all resize-y" placeholder="Describa si padece asma, alergias, diabetes, etc."></textarea>
                                </div>
                                <label className="flex items-start gap-3 p-3 border border-slate-200 rounded-xl hover:bg-slate-50 cursor-pointer transition-colors group">
                                    <div className="flex items-center h-5 mt-0.5">
                                        <input type="checkbox" checked={data.asistencia_psicopedagogica} onChange={e => setData('asistencia_psicopedagogica', e.target.checked)} className="w-4 h-4 text-[#003057] border-slate-300 rounded focus:ring-[#003057]" />
                                    </div>
                                    <div className="flex flex-col">
                                        <span className="text-sm font-semibold text-slate-700 group-hover:text-[#003057]">Asistencia Psicopedagógica</span>
                                        <span className="text-xs text-slate-500">Marque si el alumno recibe o requiere acompañamiento.</span>
                                    </div>
                                </label>
                            </div>
                        </div>

                        {/* Familiares & Observaciones */}
                        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden p-6">
                            <h3 className="text-[15px] font-bold text-slate-800 mb-5 border-b border-slate-100 pb-3">Otros Datos</h3>
                            
                            <div className="space-y-5">
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Hermanos en la Institución</label>
                                    <div className="relative">
                                        <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                                            </svg>
                                        </div>
                                        <input type="number" min="0" value={data.hermanos_institucion} onChange={e => setData('hermanos_institucion', parseInt(e.target.value) || 0)} className="w-full bg-slate-50 border border-slate-200 rounded-xl pl-9 pr-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" />
                                    </div>
                                </div>
                                
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Observaciones Adicionales</label>
                                    <textarea rows={3} value={data.observaciones} onChange={e => setData('observaciones', e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all resize-y" placeholder="Cualquier otra información relevante..."></textarea>
                                </div>
                            </div>
                        </div>

                        {/* Submit Action */}
                        <div className="pt-2">
                            <button type="submit" disabled={processing} className="w-full bg-[#008f39] hover:bg-[#00752d] disabled:bg-slate-400 text-white py-3.5 rounded-xl font-bold text-[15px] shadow-md shadow-[#008f39]/20 hover:shadow-lg hover:-translate-y-0.5 transition-all flex items-center justify-center gap-2 group">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 transform group-hover:scale-110 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" />
                                </svg>
                                {processing ? 'Confirmando...' : 'Confirmar Inscripción'}
                            </button>
                        </div>

                    </div>
                </form>
            </div>
        </AdminLayout>
    );
}
