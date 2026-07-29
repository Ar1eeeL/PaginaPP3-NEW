import { Head, Link, useForm } from '@inertiajs/react';

export default function Login() {
    const { data, setData, post, processing, errors } = useForm({
        dni: '',
        password: '',
    });

    const submit = (e: React.FormEvent) => {
        e.preventDefault();
        post('/login');
    };

    return (
        <>
            <Head title="Iniciar Sesión - ISAC" />
            
            {/* Contenedor Principal con Fondo y Overflow Hidden para los blobs */}
            <div className="min-h-screen bg-slate-50 flex flex-col items-center justify-center relative font-sans p-4 overflow-hidden">
                
                {/* Elementos Decorativos de Fondo (Blobs) */}
                <div className="absolute top-[-10%] left-[-10%] w-96 h-96 bg-blue-400 rounded-full mix-blend-multiply filter blur-[100px] opacity-30 animate-blob"></div>
                <div className="absolute top-[20%] right-[-10%] w-96 h-96 bg-emerald-400 rounded-full mix-blend-multiply filter blur-[100px] opacity-30 animate-blob animation-delay-2000"></div>
                <div className="absolute bottom-[-20%] left-[20%] w-96 h-96 bg-yellow-300 rounded-full mix-blend-multiply filter blur-[100px] opacity-30 animate-blob animation-delay-4000"></div>
                
                {/* Back button */}
                <div className="absolute bottom-6 left-6 z-20">
                    <Link 
                        href="/" 
                        className="group flex items-center gap-2 bg-[#003057] hover:bg-[#002244] text-white px-4 py-2.5 rounded-md text-sm font-semibold shadow-md hover:shadow-lg transition-all duration-300"
                    >
                        <span className="transform group-hover:-translate-x-1 transition-transform duration-300">&larr;</span> Volver al inicio
                    </Link>
                </div>

                {/* Login Card (Glassmorphism) */}
                <div className="bg-white/70 backdrop-blur-2xl border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.08)] rounded-[2.5rem] p-8 sm:p-12 max-w-[420px] w-full relative z-10">
                    
                    {/* Header Logo */}
                    <div className="flex items-center justify-center gap-4 mb-10">
                        <div className="relative">
                            <div className="absolute inset-0 bg-blue-100 rounded-full filter blur-md opacity-70"></div>
                            <img 
                                src="/images/EscudoDeLaInstitucion.png" 
                                alt="ISAC Logo" 
                                className="w-24 h-24 object-contain relative z-10 drop-shadow-sm"
                            />
                        </div>
                        <div className="flex flex-col text-left">
                            <span className="text-sm text-[#003057] font-semibold tracking-wide uppercase leading-tight">Instituto Secundario</span>
                            <span className="text-2xl font-bold text-[#003057] leading-tight">Arturo Capdevila</span>
                        </div>
                    </div>

                    {/* Titles */}
                    <div className="text-center mb-10">
                        <h1 className="text-[26px] font-bold text-slate-800 tracking-tight">Acceso al Sistema</h1>
                        <p className="text-sm text-slate-500 mt-2 font-medium">Ingresa tus credenciales para continuar al portal.</p>
                    </div>

                    {/* Form */}
                    <form onSubmit={submit} className="flex flex-col gap-6">
                        
                        {/* DNI Field */}
                        <div className="flex flex-col gap-2">
                            <label className="text-sm font-semibold text-slate-700 ml-1">DNI</label>
                            <div className="relative group">
                                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-slate-400 group-focus-within:text-blue-600 transition-colors">
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                    </svg>
                                </div>
                                <input 
                                    type="text" 
                                    value={data.dni}
                                    onChange={(e) => setData('dni', e.target.value)}
                                    placeholder="Ingresa tu número de DNI" 
                                    className="w-full bg-white/60 border border-slate-200 text-slate-800 text-sm rounded-2xl pl-11 pr-4 py-3.5 outline-none focus:bg-white focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 transition-all duration-300 placeholder:text-slate-400 font-medium"
                                />
                            </div>
                            {errors.dni && <span className="text-red-500 text-xs ml-1 font-medium">{errors.dni}</span>}
                        </div>

                        {/* Password Field */}
                        <div className="flex flex-col gap-2">
                            <label className="text-sm font-semibold text-slate-700 ml-1">Contraseña</label>
                            <div className="relative group">
                                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-slate-400 group-focus-within:text-blue-600 transition-colors">
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                                    </svg>
                                </div>
                                <input 
                                    type="password" 
                                    value={data.password}
                                    onChange={(e) => setData('password', e.target.value)}
                                    placeholder="Ingresa tu contraseña" 
                                    className="w-full bg-white/60 border border-slate-200 text-slate-800 text-sm rounded-2xl pl-11 pr-12 py-3.5 outline-none focus:bg-white focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 transition-all duration-300 placeholder:text-slate-400 font-medium"
                                />
                                <button type="button" className="absolute inset-y-0 right-0 pr-4 flex items-center text-slate-400 hover:text-slate-600 transition-colors">
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                    </svg>
                                </button>
                            </div>
                            {errors.password && <span className="text-red-500 text-xs ml-1 font-medium">{errors.password}</span>}
                        </div>

                        {/* Submit Button */}
                        <button 
                            type="submit" 
                            disabled={processing}
                            className="group bg-gradient-to-r from-[#003057] to-[#004a87] text-white w-full py-4 rounded-2xl font-bold mt-4 flex justify-center items-center gap-2 shadow-lg shadow-blue-900/20 hover:shadow-blue-900/40 hover:-translate-y-0.5 active:translate-y-0 transition-all duration-300 disabled:opacity-50"
                        >
                            Ingresar al Campus
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 transform group-hover:translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                            </svg>
                        </button>

                        {/* Forgot Password */}
                        <div className="text-center mt-2">
                            <a href="#" className="text-[#008f39] hover:text-[#006e2c] text-sm font-medium transition">
                                ¿Olvidó su contraseña?
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </>
    );
}
