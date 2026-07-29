import AdminLayout from '@/layouts/AdminLayout';
import { Head, useForm } from '@inertiajs/react';
import React, { FormEventHandler } from 'react';

export default function RegistrarDirector() {
    const { data, setData, post, processing, errors } = useForm({
        dni: '',
        apellido: '',
        nombre: '',
        fecha_nacimiento: '',
        email: '',
        telefono: '',
    });

    const submit: FormEventHandler = (e) => {
        e.preventDefault();
        post('/admin/directores'); // Endpoint to be implemented later
    };

    return (
        <AdminLayout>
            <Head title="Registrar Director" />
            
            <div className="p-6 md:p-10 max-w-[1100px] mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500">
                <div className="bg-white rounded-2xl shadow-xl shadow-slate-200/40 border border-slate-100 overflow-hidden">
                    {/* Header */}
                    <div className="bg-gradient-to-r from-[#003057] to-[#004b87] px-8 py-6 flex items-center gap-4 relative overflow-hidden">
                        {/* Decorative background element */}
                        <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 rounded-full blur-3xl -translate-y-1/2 translate-x-1/3"></div>
                        
                        <div className="bg-white/10 p-2.5 rounded-xl backdrop-blur-sm border border-white/20">
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                            </svg>
                        </div>
                        <h1 className="text-2xl font-bold text-white tracking-tight relative z-10">
                            Registrar Nuevo Director
                        </h1>
                    </div>

                    {/* Form Content */}
                    <form onSubmit={submit} className="p-8 md:p-10 bg-slate-50/30">
                        
                        {/* Section 1: Datos Personales */}
                        <div className="mb-8 bg-white p-8 rounded-2xl border border-slate-100 shadow-sm transition-shadow hover:shadow-md">
                            <div className="flex items-center gap-3 mb-8 border-b border-slate-100 pb-4">
                                <div className="h-8 w-1.5 bg-[#147a3e] rounded-full"></div>
                                <h2 className="text-xl font-bold text-slate-800">
                                    Datos Personales
                                </h2>
                            </div>
                            
                            <div className="grid grid-cols-1 md:grid-cols-12 gap-x-6 gap-y-8">
                                <div className="md:col-span-4">
                                    <label className="block text-sm font-bold text-slate-700 mb-2">DNI <span className="text-red-500">*</span></label>
                                    <input 
                                        type="text" 
                                        placeholder="Solo números" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 focus:bg-white focus:border-[#003057] focus:ring-[3px] focus:ring-[#003057]/10 outline-none transition-all text-sm font-medium text-slate-700 placeholder:text-slate-400"
                                        value={data.dni}
                                        onChange={e => setData('dni', e.target.value)}
                                        required
                                    />
                                    {errors.dni && <p className="text-red-500 text-xs mt-1.5 font-medium">{errors.dni}</p>}
                                </div>
                                <div className="md:col-span-4">
                                    <label className="block text-sm font-bold text-slate-700 mb-2">Apellido <span className="text-red-500">*</span></label>
                                    <input 
                                        type="text" 
                                        placeholder="Ingrese apellido" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 focus:bg-white focus:border-[#003057] focus:ring-[3px] focus:ring-[#003057]/10 outline-none transition-all text-sm font-medium text-slate-700 placeholder:text-slate-400"
                                        value={data.apellido}
                                        onChange={e => setData('apellido', e.target.value)}
                                        required
                                    />
                                </div>
                                <div className="md:col-span-4">
                                    <label className="block text-sm font-bold text-slate-700 mb-2">Nombre <span className="text-red-500">*</span></label>
                                    <input 
                                        type="text" 
                                        placeholder="Ingrese nombre" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 focus:bg-white focus:border-[#003057] focus:ring-[3px] focus:ring-[#003057]/10 outline-none transition-all text-sm font-medium text-slate-700 placeholder:text-slate-400"
                                        value={data.nombre}
                                        onChange={e => setData('nombre', e.target.value)}
                                        required
                                    />
                                </div>

                                <div className="md:col-span-4">
                                    <label className="block text-sm font-bold text-slate-700 mb-2">Fecha de Nacimiento <span className="text-red-500">*</span></label>
                                    <div className="relative">
                                        <input 
                                            type="date" 
                                            className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 focus:bg-white focus:border-[#003057] focus:ring-[3px] focus:ring-[#003057]/10 outline-none transition-all text-sm font-medium text-slate-700"
                                            value={data.fecha_nacimiento}
                                            onChange={e => setData('fecha_nacimiento', e.target.value)}
                                            required
                                        />
                                    </div>
                                </div>
                                <div className="md:col-span-4">
                                    <label className="block text-sm font-bold text-slate-700 mb-2">Email</label>
                                    <input 
                                        type="email" 
                                        placeholder="ejemplo@correo.com" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 focus:bg-white focus:border-[#003057] focus:ring-[3px] focus:ring-[#003057]/10 outline-none transition-all text-sm font-medium text-slate-700 placeholder:text-slate-400"
                                        value={data.email}
                                        onChange={e => setData('email', e.target.value)}
                                    />
                                </div>
                                <div className="md:col-span-4">
                                    <label className="block text-sm font-bold text-slate-700 mb-2">Teléfono</label>
                                    <input 
                                        type="text" 
                                        placeholder="Solo números" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 focus:bg-white focus:border-[#003057] focus:ring-[3px] focus:ring-[#003057]/10 outline-none transition-all text-sm font-medium text-slate-700 placeholder:text-slate-400"
                                        value={data.telefono}
                                        onChange={e => setData('telefono', e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Submit Button */}
                        <div className="flex justify-center mt-10 pt-6 border-t border-slate-200">
                            <button 
                                type="submit" 
                                disabled={processing}
                                className="bg-[#003057] hover:bg-[#002240] text-white px-8 py-3.5 rounded-xl font-bold flex items-center gap-3 transition-all shadow-lg shadow-[#003057]/30 hover:shadow-[#003057]/40 hover:-translate-y-0.5 disabled:opacity-70 disabled:cursor-not-allowed disabled:transform-none"
                            >
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                Registrar Director
                            </button>
                        </div>

                    </form>
                </div>
            </div>
        </AdminLayout>
    );
}
