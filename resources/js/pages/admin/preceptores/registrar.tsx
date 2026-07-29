import AdminLayout from '@/layouts/AdminLayout';
import { Head, useForm } from '@inertiajs/react';
import React, { FormEventHandler } from 'react';

export default function RegistrarPreceptor() {
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
        grados: [] as string[],
    });

    const submit: FormEventHandler = (e) => {
        e.preventDefault();
        post('/admin/preceptores'); // Endpoint to be implemented later
    };

    const gradosOptions = [
        '1º A - Tarde', '1º B - Mañana',
        '2º A - Tarde', '2º B - Mañana',
        '3º A - Mañana', '3º B - Mañana',
        '4º A - Mañana', '4º B - Mañana',
        '5º A - Mañana', '5º B - Mañana',
        '6º A - Mañana', '6º B - Mañana',
    ];

    const handleCheckboxChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const value = e.target.value;
        if (e.target.checked) {
            setData('grados', [...data.grados, value]);
        } else {
            setData('grados', data.grados.filter(g => g !== value));
        }
    };

    return (
        <AdminLayout>
            <Head title="Registrar Preceptor" />
            
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
                            Registrar Nuevo Preceptor
                        </h1>
                    </div>

                    {/* Form Content */}
                    <form onSubmit={submit} className="p-8 md:p-10 bg-slate-50/30">
                        
                        {/* Section 1: Datos Personales */}
                        <div className="mb-12 bg-white p-8 rounded-2xl border border-slate-100 shadow-sm transition-shadow hover:shadow-md">
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
                                <div className="md:col-span-8">
                                    <label className="block text-sm font-bold text-slate-700 mb-2">Correo Electrónico</label>
                                    <input 
                                        type="email" 
                                        placeholder="ejemplo@correo.com" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 focus:bg-white focus:border-[#003057] focus:ring-[3px] focus:ring-[#003057]/10 outline-none transition-all text-sm font-medium text-slate-700 placeholder:text-slate-400"
                                        value={data.email}
                                        onChange={e => setData('email', e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Section 2: Datos de Contacto */}
                        <div className="mb-12 bg-white p-8 rounded-2xl border border-slate-100 shadow-sm transition-shadow hover:shadow-md">
                            <div className="flex items-center gap-3 mb-8 border-b border-slate-100 pb-4">
                                <div className="h-8 w-1.5 bg-[#147a3e] rounded-full opacity-70"></div>
                                <h2 className="text-xl font-bold text-slate-800">
                                    Datos de Contacto <span className="text-sm font-medium text-slate-400 ml-2">(Opcional)</span>
                                </h2>
                            </div>
                            
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-8">
                                <div>
                                    <label className="block text-sm font-bold text-slate-700 mb-2">Dirección</label>
                                    <input 
                                        type="text" 
                                        placeholder="Calle y número"
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 focus:bg-white focus:border-[#003057] focus:ring-[3px] focus:ring-[#003057]/10 outline-none transition-all text-sm font-medium text-slate-700 placeholder:text-slate-400"
                                        value={data.direccion}
                                        onChange={e => setData('direccion', e.target.value)}
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-bold text-slate-700 mb-2">Teléfono</label>
                                    <input 
                                        type="text" 
                                        placeholder="Solo números" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 focus:bg-white focus:border-[#003057] focus:ring-[3px] focus:ring-[#003057]/10 outline-none transition-all text-sm font-medium text-slate-700 placeholder:text-slate-400"
                                        value={data.telefono}
                                        onChange={e => setData('telefono', e.target.value)}
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-bold text-slate-700 mb-2">Localidad</label>
                                    <input 
                                        type="text" 
                                        placeholder="Ciudad / Barrio"
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 focus:bg-white focus:border-[#003057] focus:ring-[3px] focus:ring-[#003057]/10 outline-none transition-all text-sm font-medium text-slate-700 placeholder:text-slate-400"
                                        value={data.localidad}
                                        onChange={e => setData('localidad', e.target.value)}
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-bold text-slate-700 mb-2">Código Postal</label>
                                    <input 
                                        type="text" 
                                        placeholder="Solo números" 
                                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 focus:bg-white focus:border-[#003057] focus:ring-[3px] focus:ring-[#003057]/10 outline-none transition-all text-sm font-medium text-slate-700 placeholder:text-slate-400"
                                        value={data.codigo_postal}
                                        onChange={e => setData('codigo_postal', e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Section 3: Asignación de Grados */}
                        <div className="mb-10 bg-white p-8 rounded-2xl border border-slate-100 shadow-sm transition-shadow hover:shadow-md">
                            <div className="flex items-center gap-3 mb-8 border-b border-slate-100 pb-4">
                                <div className="h-8 w-1.5 bg-[#003057] rounded-full"></div>
                                <h2 className="text-xl font-bold text-slate-800">
                                    Asignación de Grados
                                </h2>
                            </div>
                            
                            <div>
                                <label className="block text-sm font-bold text-slate-700 mb-4">Grados a cargo <span className="text-red-500">*</span></label>
                                
                                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-4">
                                    {gradosOptions.map((grado, idx) => {
                                        const isChecked = data.grados.includes(grado);
                                        return (
                                            <label 
                                                key={idx} 
                                                className={`
                                                    relative flex items-center gap-3 p-4 rounded-xl border-2 cursor-pointer transition-all duration-200 group
                                                    ${isChecked 
                                                        ? 'border-[#003057] bg-[#003057]/5 shadow-sm' 
                                                        : 'border-slate-200 bg-white hover:border-[#003057]/30 hover:bg-slate-50'
                                                    }
                                                `}
                                            >
                                                <div className="relative flex items-center">
                                                    <input 
                                                        type="checkbox" 
                                                        value={grado}
                                                        checked={isChecked}
                                                        onChange={handleCheckboxChange}
                                                        className="peer sr-only"
                                                    />
                                                    <div className={`
                                                        h-6 w-6 rounded-md border flex items-center justify-center transition-all
                                                        ${isChecked ? 'bg-[#003057] border-[#003057]' : 'bg-white border-slate-300 group-hover:border-[#003057]/50'}
                                                    `}>
                                                        <svg xmlns="http://www.w3.org/2000/svg" className={`h-4 w-4 text-white transition-transform duration-200 ${isChecked ? 'scale-100' : 'scale-0'}`} viewBox="0 0 20 20" fill="currentColor">
                                                            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                                                        </svg>
                                                    </div>
                                                </div>
                                                <span className={`font-semibold text-sm transition-colors ${isChecked ? 'text-[#003057]' : 'text-slate-600 group-hover:text-slate-900'}`}>
                                                    {grado}
                                                </span>
                                            </label>
                                        );
                                    })}
                                </div>
                                {errors.grados && <p className="text-red-500 text-xs mt-3 font-medium">{errors.grados}</p>}
                            </div>
                        </div>

                        {/* Submit Button */}
                        <div className="flex justify-end mt-12 pt-6 border-t border-slate-200">
                            <button 
                                type="submit" 
                                disabled={processing}
                                className="bg-[#003057] hover:bg-[#002240] text-white px-8 py-3.5 rounded-xl font-bold flex items-center gap-3 transition-all shadow-lg shadow-[#003057]/30 hover:shadow-[#003057]/40 hover:-translate-y-0.5 disabled:opacity-70 disabled:cursor-not-allowed disabled:transform-none"
                            >
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                </svg>
                                Registrar Preceptor
                            </button>
                        </div>

                    </form>
                </div>
            </div>
        </AdminLayout>
    );
}
