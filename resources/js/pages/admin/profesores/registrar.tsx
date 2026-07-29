import { Head, Link, useForm } from '@inertiajs/react';
import AdminLayout from '../../../layouts/AdminLayout';

export default function RegistrarProfesor() {
    const { data, setData, post, processing, errors } = useForm({
        nombre: '',
        apellido: '',
        dni: '',
        fecha_nacimiento: '',
        email: '',
        telefono: '',
        titulo: '',
        fecha_ingreso: '2026-07-28',
    });

    const submit = (e: React.FormEvent) => {
        e.preventDefault();
        post('/admin/profesores/registrar');
    };

    return (
        <AdminLayout>
            <Head title="Registrar Profesor" />
            
            <div className="p-4 md:p-6 lg:p-8 max-w-4xl mx-auto">
                
                {/* Header */}
                <div className="mb-6 md:mb-8 text-center md:text-left">
                    <h1 className="text-2xl md:text-3xl font-black text-slate-800 tracking-tight">Registro de Profesor</h1>
                    <p className="text-sm md:text-base text-slate-500 font-medium mt-1">Ingresa los datos del nuevo docente para agregarlo al plantel institucional.</p>
                </div>

                <form onSubmit={submit} className="space-y-6">
                    
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
                                    <input type="text" value={data.nombre} onChange={e => setData('nombre', e.target.value)} required className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. María Fernanda" />
                                    {errors.nombre && <span className="text-red-500 text-xs mt-1">{errors.nombre}</span>}
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Apellido <span className="text-red-500">*</span></label>
                                    <input type="text" value={data.apellido} onChange={e => setData('apellido', e.target.value)} required className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. González" />
                                    {errors.apellido && <span className="text-red-500 text-xs mt-1">{errors.apellido}</span>}
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">DNI <span className="text-red-500">*</span></label>
                                    <input type="text" value={data.dni} onChange={e => setData('dni', e.target.value)} required className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Sin puntos ni espacios" />
                                    {errors.dni && <span className="text-red-500 text-xs mt-1">{errors.dni}</span>}
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Fecha de Nacimiento <span className="text-red-500">*</span></label>
                                    <input type="date" value={data.fecha_nacimiento} onChange={e => setData('fecha_nacimiento', e.target.value)} required className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" />
                                    {errors.fecha_nacimiento && <span className="text-red-500 text-xs mt-1">{errors.fecha_nacimiento}</span>}
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Email</label>
                                    <input type="email" value={data.email} onChange={e => setData('email', e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="profesor@ejemplo.com" />
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Teléfono</label>
                                    <input type="text" value={data.telefono} onChange={e => setData('telefono', e.target.value)} className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. 351 1234567" />
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
                                    <input type="text" value={data.titulo} onChange={e => setData('titulo', e.target.value)} required className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" placeholder="Ej. Profesor en Matemáticas" />
                                    {errors.titulo && <span className="text-red-500 text-xs mt-1">{errors.titulo}</span>}
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Fecha de Ingreso <span className="text-red-500">*</span></label>
                                    <input type="date" value={data.fecha_ingreso} onChange={e => setData('fecha_ingreso', e.target.value)} required className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" />
                                </div>
                            </div>
                        </div>
                    </div>

                    {errors.error && (
                        <div className="p-4 bg-red-100 text-red-600 rounded-xl border border-red-200">
                            {errors.error}
                        </div>
                    )}

                    {/* Submit Action */}
                    <div className="pt-4 flex justify-center md:justify-end">
                        <button 
                            type="submit" 
                            disabled={processing}
                            className={`w-full md:w-auto bg-[#003057] hover:bg-[#002244] text-white px-8 py-3.5 rounded-xl font-bold text-[14px] shadow-md shadow-[#003057]/20 hover:shadow-lg transition-all flex items-center justify-center gap-2 group ${processing ? 'opacity-70 cursor-not-allowed' : 'hover:-translate-y-0.5'}`}
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" className={`h-5 w-5 transform transition-transform ${processing ? 'animate-spin' : 'group-hover:scale-110'}`} fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                {processing ? (
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                                ) : (
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                                )}
                            </svg>
                            {processing ? 'Guardando...' : 'Registrar Profesor y Asignar Materias'}
                        </button>
                    </div>

                </form>
            </div>
        </AdminLayout>
    );
}
