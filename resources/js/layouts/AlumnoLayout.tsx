import { Link, usePage } from '@inertiajs/react';
import React, { useState } from 'react';

export default function AlumnoLayout({ children }: { children: React.ReactNode }) {
    const { url } = usePage();
    const { auth } = usePage().props as any;
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    // Mock User Info for now (since auth user might not have these specific relations loaded easily in the layout without passing them specifically)
    // You can adapt this to use auth.user once you have the backend models ready
    const user = {
        name: auth?.user?.name || "Ariel Gonzalez",
        role: "Alumno",
        grade: "4° B"
    };

    return (
        <div className="min-h-screen bg-[#eef3f7] flex">
            {/* Mobile Menu Overlay */}
            {isMobileMenuOpen && (
                <div 
                    className="fixed inset-0 bg-slate-900/50 z-40 lg:hidden"
                    onClick={() => setIsMobileMenuOpen(false)}
                ></div>
            )}

            {/* Sidebar */}
            <aside className={`
                fixed lg:sticky top-0 left-0 z-50
                w-[280px] h-screen
                bg-white border-r border-slate-200
                flex flex-col
                transition-transform duration-300 ease-in-out
                ${isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
            `}>
                {/* Logo Area */}
                <div className="p-6 pb-4">
                    <div className="flex items-center justify-center gap-3">
                        <img 
                            src="/images/EscudoDeLaInstitucion.png" 
                            alt="Escudo ISAC" 
                            className="w-12 h-14 object-contain"
                        />
                        <div className="flex flex-col justify-center">
                            <span className="text-[11px] font-bold text-slate-800 leading-tight">Instituto Secundario</span>
                            <span className="text-[13px] font-black text-[#003057] leading-tight">Arturo Capdevila</span>
                        </div>
                    </div>
                </div>

                {/* User Info Profile */}
                <div className="px-6 py-4 flex flex-col items-center border-b border-slate-100">
                    <h3 className="text-base font-bold text-[#003057]">{user.name}</h3>
                    <p className="text-[13px] text-slate-500 mb-2">{user.role}</p>
                    <div className="border border-blue-200 text-blue-600 bg-blue-50 px-3 py-0.5 rounded text-xs font-bold shadow-sm">
                        {user.grade}
                    </div>
                </div>

                {/* Navigation */}
                <div className="flex-1 overflow-y-auto px-4 py-6 space-y-1">
                    
                    <Link 
                        href="/alumno/dashboard"
                        className={`flex items-center gap-4 px-4 py-3 rounded-xl transition-all ${
                            url.startsWith('/alumno/dashboard') 
                            ? 'bg-[#003057] text-white font-semibold shadow-md' 
                            : 'text-slate-600 hover:bg-slate-50 hover:text-[#003057]'
                        }`}
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={url.startsWith('/alumno/dashboard') ? 2.5 : 2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                        </svg>
                        <span className="text-[14.5px]">Inicio</span>
                    </Link>

                    <Link 
                        href="#"
                        className="flex items-center gap-4 px-4 py-3 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-[#003057] transition-all"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        </svg>
                        <span className="text-[14.5px]">Mi Perfil</span>
                    </Link>

                    <Link 
                        href="/alumno/materias"
                        className={`flex items-center gap-4 px-4 py-3 rounded-xl transition-all ${
                            url.startsWith('/alumno/materias') 
                            ? 'bg-[#003057] text-white font-semibold shadow-md' 
                            : 'text-slate-600 hover:bg-slate-50 hover:text-[#003057]'
                        }`}
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={url.startsWith('/alumno/materias') ? 2.5 : 2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                        </svg>
                        <span className="text-[14.5px]">Mis materias</span>
                    </Link>

                    <Link 
                        href="#"
                        className="flex items-center gap-4 px-4 py-3 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-[#003057] transition-all"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
                        </svg>
                        <span className="text-[14.5px]">Mis Calificaciones</span>
                    </Link>

                    <Link 
                        href="#"
                        className="flex items-center gap-4 px-4 py-3 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-[#003057] transition-all"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                        </svg>
                        <span className="text-[14.5px]">Horario</span>
                    </Link>

                    <Link 
                        href="#"
                        className="flex items-center gap-4 px-4 py-3 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-[#003057] transition-all"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                        </svg>
                        <span className="text-[14.5px]">Mensajes</span>
                    </Link>

                    <Link 
                        href="#"
                        className="flex items-center gap-4 px-4 py-3 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-[#003057] transition-all"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                        <span className="text-[14.5px]">Justificar inasistencia</span>
                    </Link>

                </div>

                {/* Logout Button */}
                <div className="p-4 border-t border-slate-200">
                    <Link
                        href="/logout"
                        method="post"
                        as="button"
                        className="w-full flex items-center gap-3 px-4 py-3 text-slate-600 hover:bg-red-50 hover:text-red-600 rounded-xl transition-colors group"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 transform group-hover:-translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                        </svg>
                        <span className="text-[14px] font-medium">Cerrar Sesión</span>
                    </Link>
                </div>
            </aside>

            {/* Main Content */}
            <div className="flex-1 min-w-0 flex flex-col min-h-screen relative">
                
                {/* Mobile Top Bar */}
                <div className="lg:hidden bg-white border-b border-slate-200 px-4 py-3 flex items-center justify-between sticky top-0 z-30 shadow-sm">
                    <button 
                        onClick={() => setIsMobileMenuOpen(true)}
                        className="p-2 text-slate-500 hover:bg-slate-50 rounded-lg"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                        </svg>
                    </button>
                    <span className="font-bold text-[#003057]">Mi Campus</span>
                    <div className="w-10"></div> {/* Spacer for center alignment */}
                </div>

                <main className="flex-1 p-4 md:p-6 lg:p-8 overflow-y-auto">
                    {children}
                </main>
            </div>
        </div>
    );
}
