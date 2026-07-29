import { Head } from '@inertiajs/react';
import AdminLayout from '../../../layouts/AdminLayout';

export default function InscribirAlumno() {
    return (
        <AdminLayout>
            <Head title="Inscribir Alumno" />
            
            <div className="p-4 md:p-6 lg:p-8 max-w-[1400px] mx-auto">
                
                {/* Header */}
                <div className="mb-6 md:mb-8">
                    <h1 className="text-2xl md:text-3xl font-black text-slate-800 tracking-tight">Nueva Inscripción</h1>
                    <p className="text-sm md:text-base text-slate-500 font-medium mt-1">Completa los datos para registrar a un nuevo alumno en el sistema.</p>
                </div>

                <form className="grid grid-cols-1 xl:grid-cols-12 gap-6 items-start">
                    
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
                                        <input type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. Juan Martín" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Apellido <span className="text-red-500">*</span></label>
                                        <input type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. Pérez" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">DNI <span className="text-red-500">*</span></label>
                                        <input type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Sin puntos ni espacios" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Fecha de Nacimiento <span className="text-red-500">*</span></label>
                                        <input type="date" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Nacionalidad <span className="text-red-500">*</span></label>
                                        <select className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all cursor-pointer">
                                            <option>-- Seleccione --</option>
                                            <option>Argentina</option>
                                            <option>Chilena</option>
                                            <option>Uruguaya</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Lugar de Nac. <span className="text-red-500">*</span></label>
                                        <input type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Provincia, País" />
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
                                        <input type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Calle, Número, Piso/Depto" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Localidad <span className="text-red-500">*</span></label>
                                        <input type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. Córdoba Capital" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Código Postal <span className="text-red-500">*</span></label>
                                        <input type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. 5000" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Teléfono Personal <span className="text-red-500">*</span></label>
                                        <input type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Código de área + Número" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Correo Electrónico <span className="text-red-500">*</span></label>
                                        <input type="email" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="alumno@ejemplo.com" />
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
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Grado / Curso <span className="text-red-500">*</span></label>
                                        <select className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all cursor-pointer">
                                            <option>-- Seleccione curso --</option>
                                            <option>1° Año</option>
                                            <option>2° Año</option>
                                            <option>3° Año</option>
                                            <option>4° Año</option>
                                            <option>5° Año</option>
                                            <option>6° Año</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Especialidad</label>
                                        <select className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all cursor-pointer">
                                            <option>-- No Aplica (1° a 3°) --</option>
                                            <option>Ciencias Naturales</option>
                                            <option>Economía y Administración</option>
                                            <option>Humanidades</option>
                                        </select>
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
                                        <label className="block text-xs font-bold text-[#daf4f6] uppercase tracking-wider mb-2">Nombre del Contacto <span className="text-red-400">*</span></label>
                                        <input type="text" className="w-full bg-white/10 border border-white/20 rounded-xl px-4 py-2.5 text-sm text-white placeholder-white/50 outline-none focus:bg-white/20 focus:border-white transition-all" placeholder="Familiar o Tutor" />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-bold text-[#daf4f6] uppercase tracking-wider mb-2">Teléfono de Emergencia <span className="text-red-400">*</span></label>
                                        <input type="text" className="w-full bg-white/10 border border-white/20 rounded-xl px-4 py-2.5 text-sm text-white placeholder-white/50 outline-none focus:bg-white/20 focus:border-white transition-all" placeholder="Solo urgencias" />
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
                                    <textarea rows={3} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-700 outline-none focus:bg-white focus:border-red-400 focus:ring-2 focus:ring-red-100 transition-all resize-y" placeholder="Describa si padece asma, alergias, diabetes, etc."></textarea>
                                </div>
                                <label className="flex items-start gap-3 p-3 border border-slate-200 rounded-xl hover:bg-slate-50 cursor-pointer transition-colors group">
                                    <div className="flex items-center h-5 mt-0.5">
                                        <input type="checkbox" className="w-4 h-4 text-[#003057] border-slate-300 rounded focus:ring-[#003057]" />
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
                                        <input type="number" defaultValue="0" min="0" className="w-full bg-slate-50 border border-slate-200 rounded-xl pl-9 pr-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" />
                                    </div>
                                </div>
                                
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Observaciones Adicionales</label>
                                    <textarea rows={3} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all resize-y" placeholder="Cualquier otra información relevante..."></textarea>
                                </div>
                            </div>
                        </div>

                        {/* Submit Action */}
                        <div className="pt-2">
                            <button type="button" className="w-full bg-[#008f39] hover:bg-[#00752d] text-white py-3.5 rounded-xl font-bold text-[15px] shadow-md shadow-[#008f39]/20 hover:shadow-lg hover:-translate-y-0.5 transition-all flex items-center justify-center gap-2 group">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 transform group-hover:scale-110 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" />
                                </svg>
                                Confirmar Inscripción
                            </button>
                        </div>

                    </div>
                </form>
            </div>
        </AdminLayout>
    );
}
