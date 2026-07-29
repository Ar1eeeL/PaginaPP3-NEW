import { Head } from '@inertiajs/react';
import AdminLayout from '../../../layouts/AdminLayout';

export default function RegistrarProfesor() {
    return (
        <AdminLayout>
            <Head title="Registrar Profesor" />
            
            <div className="p-4 md:p-6 lg:p-8 max-w-4xl mx-auto">
                
                {/* Header */}
                <div className="mb-6 md:mb-8 text-center md:text-left">
                    <h1 className="text-2xl md:text-3xl font-black text-slate-800 tracking-tight">Registro de Profesor</h1>
                    <p className="text-sm md:text-base text-slate-500 font-medium mt-1">Ingresa los datos del nuevo docente para agregarlo al plantel institucional.</p>
                </div>

                <form className="space-y-6">
                    
                    {/* Datos Personales Card */}
                    <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative">
                        <div className="absolute top-0 left-0 w-1 h-full bg-[#008f39]"></div>
                        <div className="p-6 md:p-8">
                            <div className="flex items-center gap-3 mb-6 border-b border-slate-100 pb-4">
                                <div className="p-2 bg-[#008f39]/10 rounded-lg text-[#008f39]">
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                    </svg>
                                </div>
                                <h3 className="text-lg font-bold text-[#003057]">Datos Personales</h3>
                            </div>
                            
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-5 md:gap-6">
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Nombre <span className="text-red-500">*</span></label>
                                    <input type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. María Fernanda" />
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Apellido <span className="text-red-500">*</span></label>
                                    <input type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. González" />
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
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Email</label>
                                    <input type="email" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="profesor@ejemplo.com" />
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Teléfono</label>
                                    <input type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. 351 1234567" />
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Datos Profesionales Card */}
                    <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative">
                        <div className="absolute top-0 left-0 w-1 h-full bg-[#008f39]"></div>
                        <div className="p-6 md:p-8">
                            <div className="flex items-center gap-3 mb-6 border-b border-slate-100 pb-4">
                                <div className="p-2 bg-[#008f39]/10 rounded-lg text-[#008f39]">
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                                    </svg>
                                </div>
                                <h3 className="text-lg font-bold text-[#003057]">Datos Profesionales</h3>
                            </div>
                            
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-5 md:gap-6">
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Título Profesional <span className="text-red-500">*</span></label>
                                    <input type="text" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. Profesor en Matemáticas" />
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Fecha de Ingreso <span className="text-red-500">*</span></label>
                                    <input type="date" defaultValue="2026-07-28" className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" />
                                </div>
                                <div className="md:col-span-2">
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Especialidades <span className="text-red-500">*</span></label>
                                    <select className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all cursor-pointer">
                                        <option>Seleccionar especialidades...</option>
                                        <option>Ciencias Exactas</option>
                                        <option>Ciencias Naturales</option>
                                        <option>Ciencias Sociales</option>
                                        <option>Lengua y Literatura</option>
                                        <option>Idiomas (Inglés)</option>
                                    </select>
                                    <p className="text-[11px] text-slate-500 font-medium mt-2">Seleccione una o más especialidades. La primera seleccionada será la principal.</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Submit Action */}
                    <div className="pt-4 flex justify-center md:justify-end">
                        <button type="button" className="w-full md:w-auto bg-[#003057] hover:bg-[#002244] text-white px-8 py-3.5 rounded-xl font-bold text-[14px] shadow-md shadow-[#003057]/20 hover:shadow-lg hover:-translate-y-0.5 transition-all flex items-center justify-center gap-2 group">
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 transform group-hover:scale-110 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            Registrar Profesor y Asignar Materias
                        </button>
                    </div>

                </form>
            </div>
        </AdminLayout>
    );
}
