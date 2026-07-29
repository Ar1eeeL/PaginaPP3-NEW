import { Link, usePage } from '@inertiajs/react';
import React, { useState, useEffect } from 'react';

export default function AdminLayout({ children }: { children: React.ReactNode }) {
    const { url } = usePage();
    const [isSidebarOpen, setIsSidebarOpen] = useState(false);
    const [isRegistrosOpen, setIsRegistrosOpen] = useState(url.startsWith('/admin/alumnos') || url.startsWith('/admin/profesores') || url.startsWith('/admin/preceptores') || url.startsWith('/admin/tutores') || url.startsWith('/admin/directores'));

    const toggleSidebar = () => setIsSidebarOpen(!isSidebarOpen);

    return (
        <div className="flex h-screen bg-[#eef4f9] font-sans overflow-hidden">
            
            {/* Mobile Header */}
            <div className="md:hidden fixed top-0 left-0 w-full h-16 bg-white border-b border-slate-200 z-30 flex items-center justify-between px-4 shadow-sm">
                <div className="flex items-center gap-2">
                    <div className="bg-slate-50 w-8 h-8 rounded-lg flex items-center justify-center border border-slate-100">
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-[#003057]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path d="M12 14l9-5-9-5-9 5 9 5z" />
                            <path d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
                        </svg>
                    </div>
                    <h2 className="text-[#003057] font-bold text-[15px]">Campus Virtual</h2>
                </div>
                <button onClick={toggleSidebar} className="text-slate-600 hover:text-[#003057] p-2 bg-slate-50 rounded-lg border border-slate-200 transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                    </svg>
                </button>
            </div>

            {/* Overlay for mobile sidebar */}
            {isSidebarOpen && (
                <div 
                    className="md:hidden fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-40 transition-opacity"
                    onClick={toggleSidebar}
                ></div>
            )}

            {/* Sidebar */}
            <div className={`
                fixed md:static inset-y-0 left-0 z-50
                w-[260px] bg-white border-r border-slate-200 flex flex-col justify-between shadow-[4px_0_24px_rgba(0,0,0,0.02)]
                transform transition-transform duration-300 ease-in-out shrink-0
                ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'}
            `}>
                
                <div className="flex flex-col h-full">
                    {/* Header Logo */}
                    <div className="p-7 text-center border-b border-slate-100 flex flex-col items-center relative">
                        {/* Mobile close button inside sidebar */}
                        <button onClick={toggleSidebar} className="md:hidden absolute top-4 right-4 text-slate-400 hover:text-slate-700 bg-slate-100 p-1.5 rounded-md">
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>

                        <div className="bg-slate-50 w-12 h-12 rounded-xl flex items-center justify-center mb-3 shadow-inner border border-slate-100">
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-[#003057]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path d="M12 14l9-5-9-5-9 5 9 5z" />
                                <path d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
                            </svg>
                        </div>
                        <h2 className="text-[#003057] font-extrabold text-[17px] tracking-tight">
                            Campus Virtual
                        </h2>
                        <p className="text-[11px] text-slate-500 mt-1.5 font-semibold uppercase tracking-wider">Panel de Administración</p>
                        <p className="text-[14px] font-bold text-[#003057] mt-1.5">Admin Sistema</p>
                    </div>

                    {/* Navigation */}
                    <nav className="p-4 flex flex-col gap-1.5 flex-1 overflow-y-auto">
                        <Link href="/admin/dashboard" onClick={() => setIsSidebarOpen(false)} className={`group flex items-center gap-3 px-4 py-3.5 rounded-xl font-semibold text-[14px] transition-all ${url === '/admin/dashboard' ? 'bg-[#003057] text-white shadow-md shadow-[#003057]/20' : 'text-slate-600 hover:bg-slate-50 hover:text-[#003057]'}`}>
                            <svg xmlns="http://www.w3.org/2000/svg" className={`h-5 w-5 transition-transform ${url === '/admin/dashboard' ? 'text-white/90 group-hover:scale-110' : 'text-slate-400 group-hover:text-[#003057]'}`} fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                            </svg>
                            Inicio
                        </Link>
                        
                        <div>
                            <button 
                                onClick={() => setIsRegistrosOpen(!isRegistrosOpen)}
                                className="group flex w-full items-center justify-between text-slate-600 hover:bg-slate-50 hover:text-[#003057] px-4 py-3.5 rounded-xl font-medium text-[14px] transition-all"
                            >
                                <div className="flex items-center gap-3">
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-slate-400 group-hover:text-[#003057] transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                    </svg>
                                    Registros
                                </div>
                                <svg xmlns="http://www.w3.org/2000/svg" className={`h-4 w-4 text-slate-300 group-hover:text-[#003057] transition-transform ${isRegistrosOpen ? 'rotate-180' : ''}`} fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M19 9l-7 7-7-7" />
                                </svg>
                            </button>
                            
                            <div className={`overflow-hidden transition-all duration-300 ease-in-out ${isRegistrosOpen ? 'max-h-[400px] opacity-100 mt-1' : 'max-h-0 opacity-0'}`}>
                                <ul className="flex flex-col gap-1 pl-12 pr-4 text-[13.5px] font-medium text-slate-500 py-2">
                                    <li>
                                        <Link 
                                            href="/admin/alumnos/inscribir" 
                                            className={`block py-2 px-3 rounded-md transition-colors ${url === '/admin/alumnos/inscribir' ? 'bg-[#003057] text-white font-semibold' : 'hover:text-[#003057]'}`}
                                        >
                                            Inscribir Alumno
                                        </Link>
                                    </li>
                                    <li>
                                        <Link 
                                            href="/admin/profesores/registrar" 
                                            className={`block py-2 px-3 rounded-md transition-colors ${url === '/admin/profesores/registrar' ? 'bg-[#003057] text-white font-semibold' : 'hover:text-[#003057]'}`}
                                        >
                                            Registrar Profesor
                                        </Link>
                                    </li>
                                    <li>
                                        <Link 
                                            href="/admin/preceptores/registrar" 
                                            className={`block py-2 px-3 rounded-md transition-colors ${url === '/admin/preceptores/registrar' ? 'bg-[#003057] text-white font-semibold' : 'hover:text-[#003057]'}`}
                                        >
                                            Registrar Preceptor
                                        </Link>
                                    </li>
                                    <li>
                                        <Link 
                                            href="/admin/tutores/registrar" 
                                            className={`block py-2 px-3 rounded-md transition-colors ${url === '/admin/tutores/registrar' ? 'bg-[#003057] text-white font-semibold' : 'hover:text-[#003057]'}`}
                                        >
                                            Registrar Tutor
                                        </Link>
                                    </li>
                                    <li>
                                        <Link 
                                            href="/admin/directores/registrar" 
                                            className={`block py-2 px-3 rounded-md transition-colors ${url === '/admin/directores/registrar' ? 'bg-[#003057] text-white font-semibold' : 'hover:text-[#003057]'}`}
                                        >
                                            Registrar Director
                                        </Link>
                                    </li>
                                    <li><Link href="#" className="block py-2 px-3 hover:text-[#003057] transition-colors rounded-md">Registrar Administrador</Link></li>
                                    <li><Link href="#" className="block py-2 px-3 hover:text-[#003057] transition-colors rounded-md">Registrar Tesorería</Link></li>
                                    <li><Link href="#" className="block py-2 px-3 hover:text-[#003057] transition-colors rounded-md">Registrar Noticia</Link></li>
                                    <li><Link href="#" className="block py-2 px-3 hover:text-[#003057] transition-colors rounded-md">Registrar Evento</Link></li>
                                </ul>
                            </div>
                        </div>
                        
                        <button className="group flex w-full items-center justify-between text-slate-600 hover:bg-slate-50 hover:text-[#003057] px-4 py-3.5 rounded-xl font-medium text-[14px] transition-all">
                            <div className="flex items-center gap-3">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-slate-400 group-hover:text-[#003057] transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                </svg>
                                Búsquedas
                            </div>
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 text-slate-300 group-hover:text-[#003057] transition-transform group-hover:translate-x-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M19 9l-7 7-7-7" />
                            </svg>
                        </button>
                        
                        <button className="group flex w-full items-center justify-between text-slate-600 hover:bg-slate-50 hover:text-[#003057] px-4 py-3.5 rounded-xl font-medium text-[14px] transition-all">
                            <div className="flex items-center gap-3">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-slate-400 group-hover:text-[#003057] transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                                </svg>
                                Gestión Académica
                            </div>
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 text-slate-300 group-hover:text-[#003057] transition-transform group-hover:-translate-y-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 15l7-7 7 7" />
                            </svg>
                        </button>
                        
                        <button className="group flex w-full items-center justify-between text-slate-600 hover:bg-slate-50 hover:text-[#003057] px-4 py-3.5 rounded-xl font-medium text-[14px] transition-all">
                            <div className="flex items-center gap-3">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-slate-400 group-hover:text-[#003057] transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                                </svg>
                                Gestión Ciclo Lectivo
                            </div>
                        </button>
                    </nav>
                </div>

                {/* Footer / Logout */}
                <div className="p-4 border-t border-slate-100">
                    <Link href="/logout" method="post" as="button" className="group flex w-full items-center gap-3 text-slate-500 hover:bg-red-50 hover:text-red-600 px-4 py-3.5 rounded-xl font-semibold text-[14px] transition-all">
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-slate-400 group-hover:text-red-500 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                        </svg>
                        Cerrar Sesión
                    </Link>
                </div>
            </div>

            {/* Main Content */}
            <div className="flex-1 overflow-auto bg-[#eef4f9] pt-16 md:pt-0">
                {children}
            </div>
        </div>
    );
}
