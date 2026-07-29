import { Head, useForm } from '@inertiajs/react';
import AdminLayout from '@/layouts/AdminLayout';
import React, { FormEventHandler } from 'react';

export default function RegistrarPreceptor() {
    const { data, setData, post, processing, errors } = useForm({
        dni: '',
        email: '',
        apellido: '',
        nombre: '',
        telefono: '',
        grados_a_cargo: [] as string[],
    });

    const submit: FormEventHandler = (e) => {
        e.preventDefault();
        post('/admin/preceptores'); // Endpoint to be implemented
    };

    return (
        <AdminLayout>
            <Head title="Registrar Preceptor" />
            
            <div className="p-4 md:p-6 lg:p-8 max-w-4xl mx-auto">
                
                {/* Header */}
                <div className="mb-6 md:mb-8 text-center md:text-left flex items-center gap-4">
                    <div className="p-3 bg-[#003057] rounded-xl text-white hidden md:block">
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                        </svg>
                    </div>
                    <div>
                        <h1 className="text-2xl md:text-3xl font-black text-[#003057] tracking-tight">Registrar Nuevo Preceptor</h1>
                        <p className="text-sm md:text-base text-slate-500 font-medium mt-1">Ingresa los datos personales y asigna los grados a cargo.</p>
                    </div>
                </div>

                <form onSubmit={submit} className="space-y-6">
                    
                    {/* Datos Personales Card */}
                    <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative">
                        <div className="absolute top-0 left-0 w-1 h-full bg-[#008f39]"></div>
                        <div className="p-6 md:p-8">
                            <div className="flex items-center gap-3 mb-6 border-b border-slate-100 pb-4">
                                <h3 className="text-lg font-bold text-[#008f39]">1. Datos Personales del Preceptor</h3>
                            </div>
                            
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-5 md:gap-6">
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">DNI <span className="text-red-500">*</span></label>
                                    <input 
                                        type="text" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" 
                                        placeholder="Solo números" 
                                        value={data.dni}
                                        onChange={e => setData('dni', e.target.value)}
                                        required
                                    />
                                    {errors.dni && <p className="text-red-500 text-xs mt-1.5 font-medium">{errors.dni}</p>}
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Email <span className="text-red-500">*</span></label>
                                    <input 
                                        type="email" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" 
                                        placeholder="ejemplo@correo.com" 
                                        value={data.email}
                                        onChange={e => setData('email', e.target.value)}
                                        required
                                    />
                                    {errors.email && <p className="text-red-500 text-xs mt-1.5 font-medium">{errors.email}</p>}
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Apellido <span className="text-red-500">*</span></label>
                                    <input 
                                        type="text" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" 
                                        placeholder="Ingrese apellido" 
                                        value={data.apellido}
                                        onChange={e => setData('apellido', e.target.value)}
                                        required
                                    />
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Nombre <span className="text-red-500">*</span></label>
                                    <input 
                                        type="text" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" 
                                        placeholder="Ingrese nombre" 
                                        value={data.nombre}
                                        onChange={e => setData('nombre', e.target.value)}
                                        required
                                    />
                                </div>
                                <div>
                                    <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Teléfono</label>
                                    <input 
                                        type="text" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" 
                                        placeholder="Solo números" 
                                        value={data.telefono}
                                        onChange={e => setData('telefono', e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Grados Card */}
                    <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative">
                        <div className="absolute top-0 left-0 w-1 h-full bg-[#008f39]"></div>
                        <div className="p-6 md:p-8">
                            <div className="flex items-center gap-3 mb-6 border-b border-slate-100 pb-4">
                                <h3 className="text-lg font-bold text-[#008f39]">2. Asignar Grados a Cargo</h3>
                            </div>
                            
                            <p className="text-[13px] font-bold text-slate-500 uppercase tracking-wider mb-4">
                                Seleccione uno o varios grados <span className="text-red-500">*</span>
                            </p>
                            
                            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
                                {[
                                    { id: '1ero', label: '1er Grado' },
                                    { id: '2do', label: '2do Grado' },
                                    { id: '3ero', label: '3er Grado' },
                                    { id: '4to', label: '4to Grado' },
                                    { id: '5to', label: '5to Grado' },
                                    { id: '6to', label: '6to Grado' }
                                ].map((grado) => (
                                    <label 
                                        key={grado.id} 
                                        className={`flex items-center gap-3 p-4 border rounded-xl cursor-pointer transition-all ${
                                            data.grados_a_cargo.includes(grado.id) 
                                            ? 'bg-blue-50/50 border-[#003057] shadow-sm' 
                                            : 'bg-white border-slate-200 hover:border-[#003057]/30 hover:bg-slate-50'
                                        }`}
                                    >
                                        <div className="flex items-center justify-center">
                                            <input 
                                                type="checkbox" 
                                                className="w-5 h-5 text-[#003057] border-slate-300 rounded focus:ring-[#003057] cursor-pointer"
                                                checked={data.grados_a_cargo.includes(grado.id)}
                                                onChange={(e) => {
                                                    if (e.target.checked) {
                                                        setData('grados_a_cargo', [...data.grados_a_cargo, grado.id]);
                                                    } else {
                                                        setData('grados_a_cargo', data.grados_a_cargo.filter(g => g !== grado.id));
                                                    }
                                                }}
                                            />
                                        </div>
                                        <span className={`font-semibold ${data.grados_a_cargo.includes(grado.id) ? 'text-[#003057]' : 'text-slate-600'}`}>
                                            {grado.label}
                                        </span>
                                    </label>
                                ))}
                            </div>
                            {errors.grados_a_cargo && <p className="text-red-500 text-xs mt-3 font-medium">{errors.grados_a_cargo}</p>}
                        </div>
                    </div>

                    {/* Submit Action */}
                    <div className="pt-4 flex justify-center md:justify-end">
                        <button 
                            type="submit" 
                            disabled={processing}
                            className="w-full md:w-auto bg-[#003057] hover:bg-[#002244] text-white px-8 py-3.5 rounded-xl font-bold text-[14px] shadow-md shadow-[#003057]/20 hover:shadow-lg hover:-translate-y-0.5 transition-all flex items-center justify-center gap-2 group disabled:opacity-70 disabled:cursor-not-allowed"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 transform group-hover:scale-110 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            Registrar Preceptor y Asignar
                        </button>
                    </div>

                </form>
            </div>
        </AdminLayout>
    );
}
