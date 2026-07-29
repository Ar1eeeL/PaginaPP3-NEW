import { Head, useForm } from '@inertiajs/react';
import AdminLayout from '@/layouts/AdminLayout';
import React, { FormEventHandler } from 'react';

export default function RegistrarTutor() {
    const { data, setData, post, processing, errors } = useForm({
        dni: '',
        apellido: '',
        nombre: '',
        fecha_nacimiento: '',
        email: '',
        direccion: '',
        telefono: '',
        localidad: '',
        codigo_postal: '',
        alumnos_vinculados: [] as string[],
    });

    const submit: FormEventHandler = (e) => {
        e.preventDefault();
        post('/admin/tutores'); // Endpoint to be implemented
    };

    const alumnosDisponibles: any[] = []; // Se debe poblar desde el backend

    return (
        <AdminLayout>
            <Head title="Registrar Tutor" />
            
            <div className="p-4 md:p-6 lg:p-8 max-w-[1200px] mx-auto">
                <form onSubmit={submit} className="bg-white rounded-lg shadow-sm border border-slate-200 overflow-hidden">
                    
                    {/* Header */}
                    <div className="bg-[#003057] px-6 py-4 flex items-center gap-3">
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                        </svg>
                        <h1 className="text-xl font-bold text-white tracking-wide">
                            Registrar Nuevo Tutor
                        </h1>
                    </div>

                    <div className="p-6 md:p-8 space-y-10">
                        
                        {/* Datos Personales */}
                        <div>
                            <h2 className="text-[#008f39] font-bold text-[17px] mb-2">Datos Personales del Tutor</h2>
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
                                    <label className="block text-sm font-bold text-slate-800 mb-1.5">Email <span className="text-red-500">*</span></label>
                                    <input 
                                        type="email" 
                                        className="w-full bg-white border border-slate-300 rounded-md px-3 py-2 text-sm text-slate-700 outline-none focus:border-[#003057] focus:ring-1 focus:ring-[#003057] transition-all" 
                                        placeholder="ejemplo@correo.com" 
                                        value={data.email}
                                        onChange={e => setData('email', e.target.value)}
                                        required
                                    />
                                    {errors.email && <p className="text-red-500 text-xs mt-1.5">{errors.email}</p>}
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

                        {/* Vincular Alumnos */}
                        <div>
                            <h2 className="text-[#008f39] font-bold text-[17px] mb-2">Vincular Alumnos al Tutor</h2>
                            <div className="h-[2px] w-full bg-[#008f39] mb-4"></div>
                            
                            <label className="block text-sm font-bold text-slate-800 mb-2">Seleccione uno o varios alumnos <span className="text-red-500">*</span></label>
                            
                            <div className="border border-slate-300 rounded-lg p-5 mt-1 bg-white">
                                {alumnosDisponibles.length === 0 ? (
                                    <div className="flex flex-col sm:flex-row items-center sm:items-start gap-4">
                                        <div className="text-center sm:text-left">
                                            <p className="text-[14px] font-medium text-slate-600">
                                                No hay alumnos registrados actualmente en el sistema para vincular. Por favor, registre alumnos primero.
                                            </p>
                                        </div>
                                    </div>
                                ) : (
                                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-y-3">
                                        {/* El mapeo de checkboxes iría aquí con el mismo diseño que preceptor */}
                                    </div>
                                )}
                            </div>
                            {errors.alumnos_vinculados && <p className="text-red-500 text-xs mt-2">{errors.alumnos_vinculados}</p>}
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
                                Registrar Tutor y Vínculos
                            </button>
                        </div>

                    </div>
                </form>
            </div>
        </AdminLayout>
    );
}
