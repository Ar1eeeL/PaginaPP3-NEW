import { Head, useForm, usePage } from '@inertiajs/react';
import React from 'react';

export default function ChangePassword() {
    const { auth } = usePage().props as any;

    const { data, setData, post, processing, errors } = useForm({
        password: '',
        password_confirmation: '',
    });

    const submit = (e: React.FormEvent) => {
        e.preventDefault();
        post('/cambiar-password');
    };

    return (
        <div className="min-h-screen bg-[#eef3f7] flex items-center justify-center p-4">
            <Head title="Cambiar Contraseña" />
            
            <div className="w-full max-w-md bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="bg-[#003057] p-6 text-white text-center">
                    <h2 className="text-xl font-bold mb-1">¡Bienvenido, {auth?.user?.name}!</h2>
                    <p className="text-sm text-blue-100">Por seguridad, debes cambiar tu contraseña inicial (DNI).</p>
                </div>
                
                <div className="p-6 md:p-8">
                    <form onSubmit={submit} className="space-y-5">
                        
                        <div>
                            <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Nueva Contraseña <span className="text-red-500">*</span></label>
                            <input 
                                type="password" 
                                value={data.password} 
                                onChange={e => setData('password', e.target.value)} 
                                required 
                                className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" 
                                placeholder="Mínimo 8 caracteres" 
                            />
                            {errors.password && <p className="text-red-500 text-xs mt-1">{errors.password}</p>}
                        </div>

                        <div>
                            <label className="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Confirmar Contraseña <span className="text-red-500">*</span></label>
                            <input 
                                type="password" 
                                value={data.password_confirmation} 
                                onChange={e => setData('password_confirmation', e.target.value)} 
                                required 
                                className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:bg-white focus:border-[#003057] focus:ring-2 focus:ring-[#003057]/20 transition-all" 
                                placeholder="Repita la nueva contraseña" 
                            />
                            {errors.password_confirmation && <p className="text-red-500 text-xs mt-1">{errors.password_confirmation}</p>}
                        </div>

                        <div className="pt-2">
                            <button 
                                type="submit" 
                                disabled={processing} 
                                className="w-full bg-[#008f39] hover:bg-[#00752d] disabled:bg-slate-400 text-white py-3.5 rounded-xl font-bold text-[15px] shadow-md shadow-[#008f39]/20 hover:shadow-lg hover:-translate-y-0.5 transition-all flex items-center justify-center gap-2 group"
                            >
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 transform group-hover:scale-110 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                                </svg>
                                {processing ? 'Actualizando...' : 'Actualizar Contraseña'}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    );
}
