import { Head, Link } from '@inertiajs/react';
import { useState } from 'react';

export default function Welcome() {
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    return (
        <>
            <Head title="Instituto Secundario Arturo Capdevila" />
            
            <div className="min-h-screen bg-[#eef4f9] py-4 sm:py-10 px-2 sm:px-4 font-sans">
                <div className="max-w-5xl mx-auto bg-white rounded-3xl sm:rounded-[2rem] shadow-sm border border-slate-200 overflow-hidden">
                    
                    {/* Header */}
                    <div className="flex flex-col md:flex-row items-center justify-center md:justify-between px-6 sm:px-10 py-6">
                        <div className="flex flex-col sm:flex-row items-center gap-4 text-center sm:text-left">
                            <img 
                                src="/images/EscudoDeLaInstitucion.png" 
                                alt="ISAC Logo" 
                                className="w-20 h-20 sm:w-24 sm:h-24 object-contain"
                            />
                            <div className="flex flex-col">
                                <span className="text-xs sm:text-sm text-slate-600 font-semibold tracking-wide">Instituto Secundario</span>
                                <span className="text-xl sm:text-2xl font-bold text-[#003057]">Arturo Capdevila</span>
                            </div>
                        </div>
                        <div className="mt-4 md:mt-0 hidden md:flex items-center border-l-2 border-slate-200 pl-6 h-16 sm:h-20">
                            <span className="text-[#003057] font-medium text-base sm:text-lg">Educando mentes, construyendo futuros</span>
                        </div>
                    </div>

                    {/* Navbar */}
                    <nav className="bg-[#003057] text-white relative">
                        <div className="px-6 sm:px-8 py-3 flex items-center justify-between">
                            
                            {/* Mobile menu button */}
                            <button 
                                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                                className="md:hidden text-white hover:text-[#ffc107] focus:outline-none p-1"
                            >
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    {isMobileMenuOpen ? (
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                    ) : (
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                                    )}
                                </svg>
                            </button>

                            {/* Desktop menu */}
                            <ul className="hidden md:flex items-center gap-8 text-[15px] font-medium">
                                <li>
                                    <a href="#" className="text-[#ffc107] font-semibold border-b-2 border-[#ffc107] pb-1">
                                        Inicio
                                    </a>
                                </li>
                                <li className="flex items-center gap-1 cursor-pointer hover:text-[#ffc107] transition pb-1">
                                    Institución 
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                                        <path fillRule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clipRule="evenodd" />
                                    </svg>
                                </li>
                                <li className="flex items-center gap-1 cursor-pointer hover:text-[#ffc107] transition pb-1">
                                    Informacion General 
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                                        <path fillRule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clipRule="evenodd" />
                                    </svg>
                                </li>
                                <li className="flex items-center gap-1 cursor-pointer hover:text-[#ffc107] transition pb-1">
                                    Contacto 
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                                        <path fillRule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clipRule="evenodd" />
                                    </svg>
                                </li>
                                <li>
                                    <a href="#" className="hover:text-[#ffc107] transition pb-1">
                                        Portal Tutor
                                    </a>
                                </li>
                            </ul>

                            {/* CTA Button */}
                            <Link href="/login" className="bg-[#008f39] hover:bg-[#00752d] text-white px-4 sm:px-5 py-2 rounded-md font-medium transition text-sm shadow-md inline-block">
                                Campus Virtual
                            </Link>
                        </div>

                        {/* Mobile menu dropdown */}
                        <div className={`md:hidden absolute w-full bg-[#002244] border-t border-[#003057] transition-all duration-300 ease-in-out z-20 overflow-hidden ${isMobileMenuOpen ? 'max-h-64 border-b' : 'max-h-0'}`}>
                            <ul className="flex flex-col text-sm font-medium">
                                <li>
                                    <a href="#" className="block px-6 py-3 text-[#ffc107] border-b border-[#003057]">
                                        Inicio
                                    </a>
                                </li>
                                <li>
                                    <a href="#" className="block px-6 py-3 text-white hover:text-[#ffc107] hover:bg-[#001a33] border-b border-[#003057]">
                                        Institución
                                    </a>
                                </li>
                                <li>
                                    <a href="#" className="block px-6 py-3 text-white hover:text-[#ffc107] hover:bg-[#001a33] border-b border-[#003057]">
                                        Información General
                                    </a>
                                </li>
                                <li>
                                    <a href="#" className="block px-6 py-3 text-white hover:text-[#ffc107] hover:bg-[#001a33] border-b border-[#003057]">
                                        Contacto
                                    </a>
                                </li>
                                <li>
                                    <a href="#" className="block px-6 py-3 text-white hover:text-[#ffc107] hover:bg-[#001a33]">
                                        Portal Tutor
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </nav>

                    {/* Main Content Grid */}
                    <div className="p-4 sm:p-8 md:p-10 grid grid-cols-1 lg:grid-cols-3 gap-6 sm:gap-8">
                        
                        {/* Left Column: Hero & News */}
                        <div className="lg:col-span-2 flex flex-col gap-6 sm:gap-8">
                            
                            {/* Hero Image */}
                            <div className="relative rounded-2xl sm:rounded-[2rem] overflow-hidden shadow-md group h-[280px] sm:h-[350px] md:h-[400px]">
                                <img 
                                    src="/images/classroom_hero.jpg" 
                                    alt="Alumnos en clase" 
                                    className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" 
                                />
                                <div className="absolute inset-0 bg-gradient-to-t from-[#003057]/90 via-[#003057]/40 to-transparent flex items-end p-6 sm:p-8 md:p-10">
                                    <div>
                                        <span className="inline-block bg-[#ffc107] text-[#003057] text-[10px] sm:text-xs font-bold px-3 py-1 rounded-full mb-2 sm:mb-3 uppercase tracking-wider">Ciclo 2026</span>
                                        <h1 className="text-white text-2xl sm:text-3xl md:text-4xl font-bold leading-tight drop-shadow-md">Bienvenidos a nuestra<br className="hidden sm:block"/> comunidad educativa</h1>
                                    </div>
                                </div>
                            </div>

                            {/* News Section */}
                            <div className="bg-white rounded-2xl sm:rounded-[2rem] border border-slate-100 p-5 sm:p-6 md:p-8 shadow-sm">
                                <div className="flex items-center justify-between mb-5 sm:mb-6">
                                    <h3 className="text-[#003057] text-lg sm:text-xl font-bold flex items-center gap-2">
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 sm:h-6 sm:w-6 text-[#ffc107]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9.5a2.5 2.5 0 00-2.5-2.5H15" />
                                        </svg>
                                        Últimas Noticias
                                    </h3>
                                    <a href="#" className="text-xs sm:text-sm font-medium text-slate-500 hover:text-[#003057] transition">Ver todas &rarr;</a>
                                </div>
                                
                                {/* The Alert (if no news) */}
                                <div className="bg-[#daf4f6] border border-[#b2e8ec] rounded-xl sm:rounded-2xl p-6 sm:p-8 text-center">
                                    <div className="bg-white w-10 h-10 sm:w-12 sm:h-12 rounded-full flex items-center justify-center mx-auto mb-3 sm:mb-4 text-[#008695] shadow-sm">
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 sm:h-6 sm:w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                        </svg>
                                    </div>
                                    <h2 className="text-[#00606b] text-lg sm:text-xl font-semibold mb-2">No hay noticias disponibles</h2>
                                    <p className="text-[#008695] text-sm sm:text-base font-medium">Vuelve pronto para ver las últimas novedades de nuestra institución.</p>
                                </div>
                            </div>

                        </div>

                        {/* Right Column: Sidebar */}
                        <div className="flex flex-col gap-6 sm:gap-8">
                            
                            {/* Quick Links */}
                            <div className="bg-slate-50 rounded-2xl sm:rounded-[2rem] p-5 sm:p-6 md:p-8 border border-slate-200 shadow-sm">
                                <h3 className="text-[#003057] text-base sm:text-lg font-bold mb-4 sm:mb-5 border-b border-slate-200 pb-3 flex items-center gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" />
                                    </svg>
                                    Accesos Rápidos
                                </h3>
                                <div className="flex flex-col gap-3">
                                    <button className="flex items-center justify-between bg-white p-3.5 sm:p-4 rounded-xl border border-slate-200 hover:border-[#003057] hover:shadow-md transition group text-left">
                                        <span className="font-semibold text-sm sm:text-base text-slate-700 group-hover:text-[#003057]">Inscripciones 2026</span>
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 sm:h-5 sm:w-5 text-slate-300 group-hover:text-[#ffc107] transform group-hover:translate-x-1 transition" viewBox="0 0 20 20" fill="currentColor">
                                            <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clipRule="evenodd" />
                                        </svg>
                                    </button>
                                    <button className="flex items-center justify-between bg-white p-3.5 sm:p-4 rounded-xl border border-slate-200 hover:border-[#003057] hover:shadow-md transition group text-left">
                                        <span className="font-semibold text-sm sm:text-base text-slate-700 group-hover:text-[#003057]">Calendario Académico</span>
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 sm:h-5 sm:w-5 text-slate-300 group-hover:text-[#ffc107] transform group-hover:translate-x-1 transition" viewBox="0 0 20 20" fill="currentColor">
                                            <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clipRule="evenodd" />
                                        </svg>
                                    </button>
                                    <button className="flex items-center justify-between bg-white p-3.5 sm:p-4 rounded-xl border border-slate-200 hover:border-[#003057] hover:shadow-md transition group text-left">
                                        <span className="font-semibold text-sm sm:text-base text-slate-700 group-hover:text-[#003057]">Reglamento Escolar</span>
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 sm:h-5 sm:w-5 text-slate-300 group-hover:text-[#ffc107] transform group-hover:translate-x-1 transition" viewBox="0 0 20 20" fill="currentColor">
                                            <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clipRule="evenodd" />
                                        </svg>
                                    </button>
                                </div>
                            </div>

                            {/* Events */}
                            <div className="bg-[#003057] rounded-2xl sm:rounded-[2rem] p-5 sm:p-6 md:p-8 shadow-md text-white relative overflow-hidden">
                                <div className="absolute top-0 right-0 opacity-10">
                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-32 w-32 sm:h-40 sm:w-40 -mt-4 -mr-4 sm:-mt-6 sm:-mr-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                    </svg>
                                </div>
                                <h3 className="text-[#ffc107] text-base sm:text-lg font-bold mb-4 sm:mb-6 relative z-10">Próximos Eventos</h3>
                                <ul className="space-y-4 sm:space-y-5 relative z-10">
                                    <li className="flex gap-3 sm:gap-4 items-center bg-white/10 p-2.5 sm:p-3 rounded-xl hover:bg-white/20 transition cursor-default">
                                        <div className="bg-white rounded-lg p-2 text-center min-w-[3rem] sm:min-w-[3.5rem] shadow-sm">
                                            <span className="block text-[9px] sm:text-[10px] uppercase font-bold text-slate-500">Mar</span>
                                            <span className="block text-lg sm:text-xl font-black text-[#003057] leading-none">15</span>
                                        </div>
                                        <div>
                                            <span className="block text-sm sm:text-base font-semibold text-white">Inicio de Clases</span>
                                            <span className="block text-xs sm:text-sm text-[#daf4f6]">Todos los niveles</span>
                                        </div>
                                    </li>
                                    <li className="flex gap-3 sm:gap-4 items-center bg-white/10 p-2.5 sm:p-3 rounded-xl hover:bg-white/20 transition cursor-default">
                                        <div className="bg-white rounded-lg p-2 text-center min-w-[3rem] sm:min-w-[3.5rem] shadow-sm">
                                            <span className="block text-[9px] sm:text-[10px] uppercase font-bold text-slate-500">Abr</span>
                                            <span className="block text-lg sm:text-xl font-black text-[#003057] leading-none">10</span>
                                        </div>
                                        <div>
                                            <span className="block text-sm sm:text-base font-semibold text-white">Reunión de Padres</span>
                                            <span className="block text-xs sm:text-sm text-[#daf4f6]">Modalidad Virtual</span>
                                        </div>
                                    </li>
                                </ul>
                            </div>

                        </div>
                    </div>

                </div>
            </div>
        </>
    );
}
