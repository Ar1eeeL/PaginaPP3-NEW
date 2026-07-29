import { Head, useForm } from '@inertiajs/react';
import AdminLayout from '@/layouts/AdminLayout';
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
        post('/admin/directores'); // Endpoint to be implemented
    };

    return (
        <AdminLayout>
            <Head title="Registrar Director" />
            
            <div className="p-4 md:p-6 lg:p-8 max-w-[1200px] mx-auto">
                <form onSubmit={submit} className="bg-white rounded-lg shadow-sm border border-slate-200 overflow-hidden">
                    
                    {/* Header */}
                    <div className="bg-[#003057] px-6 py-4 flex items-center gap-3">
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                        </svg>
                        <h1 className="text-xl font-bold text-white tracking-wide">
                            Registrar Nuevo Director
                        </h1>
                    </div>

                    <div className="p-6 md:p-8 space-y-10">
                        
                        {/* Datos Personales */}
                        <div>
                            <h2 className="text-[#008f39] font-bold text-[17px] mb-2">Datos Personales</h2>
                            <div className="h-[2px] w-full bg-[#008f39] mb-6"></div>
                            
                            <div className="grid grid-cols-1 md:grid-cols-12 gap-x-6 gap-y-6">
                                <div className="md:col-span-4">
                                    <label className="block text-sm font-bold text-slate-800 mb-1.5">DNI <span className="text-red-500">*</span></label>
                                    <input 
                                        type="text" 
                                        className="w-full bg-white border border-slate-300 rounded-md px-3 py-2 text-sm text-slate-700 outline-none focus:border-[#003057] focus:ring-1 focus:ring-[#003057] transition-all" 
                                        placeholder="Solo números" 
                                        value={data.dni}
                                        onChange={e => setData('dni', e.target.value)}
                                        required
                                    />
                                    {errors.dni && <p className="text-red-500 text-xs mt-1.5">{errors.dni}</p>}
                                </div>
                                <div className="md:col-span-4">
                                    <label className="block text-sm font-bold text-slate-800 mb-1.5">Apellido <span className="text-red-500">*</span></label>
                                    <input 
                                        type="text" 
                                        className="w-full bg-white border border-slate-300 rounded-md px-3 py-2 text-sm text-slate-700 outline-none focus:border-[#003057] focus:ring-1 focus:ring-[#003057] transition-all" 
                                        placeholder="Ingrese apellido" 
                                        value={data.apellido}
                                        onChange={e => setData('apellido', e.target.value)}
                                        required
                                    />
                                </div>
                                <div className="md:col-span-4">
                                    <label className="block text-sm font-bold text-slate-800 mb-1.5">Nombre <span className="text-red-500">*</span></label>
                                    <input 
                                        type="text" 
                                        className="w-full bg-white border border-slate-300 rounded-md px-3 py-2 text-sm text-slate-700 outline-none focus:border-[#003057] focus:ring-1 focus:ring-[#003057] transition-all" 
                                        placeholder="Ingrese nombre" 
                                        value={data.nombre}
                                        onChange={e => setData('nombre', e.target.value)}
                                        required
                                    />
                                </div>

                                <div className="md:col-span-4">
                                    <label className="block text-sm font-bold text-slate-800 mb-1.5">Fecha de Nacimiento <span className="text-red-500">*</span></label>
                                    <input 
                                        type="date" 
                                        className="w-full bg-white border border-slate-300 rounded-md px-3 py-2 text-sm text-slate-700 outline-none focus:border-[#003057] focus:ring-1 focus:ring-[#003057] transition-all" 
                                        value={data.fecha_nacimiento}
                                        onChange={e => setData('fecha_nacimiento', e.target.value)}
                                        required
                                    />
                                </div>
                                <div className="md:col-span-4">
                                    <label className="block text-sm font-bold text-slate-800 mb-1.5">Email</label>
                                    <input 
                                        type="email" 
                                        className="w-full bg-white border border-slate-300 rounded-md px-3 py-2 text-sm text-slate-700 outline-none focus:border-[#003057] focus:ring-1 focus:ring-[#003057] transition-all" 
                                        placeholder="ejemplo@correo.com" 
                                        value={data.email}
                                        onChange={e => setData('email', e.target.value)}
                                    />
                                </div>
                                <div className="md:col-span-4">
                                    <label className="block text-sm font-bold text-slate-800 mb-1.5">Teléfono</label>
                                    <input 
                                        type="text" 
                                        className="w-full bg-white border border-slate-300 rounded-md px-3 py-2 text-sm text-slate-700 outline-none focus:border-[#003057] focus:ring-1 focus:ring-[#003057] transition-all" 
                                        placeholder="Solo números" 
                                        value={data.telefono}
                                        onChange={e => setData('telefono', e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Submit Action */}
                        <div className="flex justify-center pt-4">
                            <button 
                                type="submit" 
                                disabled={processing}
                                className="bg-[#003057] hover:bg-[#002244] text-white px-8 py-2.5 rounded-md font-medium text-sm transition-colors flex items-center justify-center gap-2"
                            >
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                Registrar Director
                            </button>
                        </div>

                    </div>
                </form>
            </div>
        </AdminLayout>
    );
}
