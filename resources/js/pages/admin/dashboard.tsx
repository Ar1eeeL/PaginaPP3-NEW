import { Head } from '@inertiajs/react';
import AdminLayout from '../../layouts/AdminLayout';

export default function Dashboard() {
    const cursos = [
        { grado: '1°', div: 'A', turno: 'Tarde', alumnos: 0, total: '0%' },
        { grado: '1°', div: 'B', turno: 'Mañana', alumnos: 0, total: '0%' },
        { grado: '2°', div: 'A', turno: 'Tarde', alumnos: 0, total: '0%' },
        { grado: '2°', div: 'B', turno: 'Mañana', alumnos: 0, total: '0%' },
        { grado: '3°', div: 'A', turno: 'Mañana', alumnos: 0, total: '0%' },
        { grado: '3°', div: 'B', turno: 'Mañana', alumnos: 0, total: '0%' },
        { grado: '4°', div: 'A', turno: 'Mañana', alumnos: 0, total: '0%' },
        { grado: '4°', div: 'B', turno: 'Mañana', alumnos: 0, total: '0%' },
        { grado: '5°', div: 'A', turno: 'Mañana', alumnos: 0, total: '0%' },
        { grado: '5°', div: 'B', turno: 'Mañana', alumnos: 0, total: '0%' },
        { grado: '6°', div: 'A', turno: 'Mañana', alumnos: 0, total: '0%' },
        { grado: '6°', div: 'B', turno: 'Mañana', alumnos: 0, total: '0%' },
    ];

    return (
        <AdminLayout>
            <Head title="Panel de Administración" />
            
            <div className="p-4 md:p-6 lg:p-10 max-w-[1600px] mx-auto space-y-6 md:space-y-8">
                
                {/* Header */}
                <div className="mb-2 md:mb-4">
                    <h1 className="text-2xl md:text-3xl font-black text-slate-800 tracking-tight">Resumen General</h1>
                    <p className="text-sm md:text-base text-slate-500 font-medium mt-1">Monitorea la actividad y estado de la institución en tiempo real.</p>
                </div>

                {/* Stats Row */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-6 xl:gap-8">
                    {/* Alumnos */}
                    <div className="group bg-white rounded-2xl shadow-sm hover:shadow-xl hover:shadow-[#008f39]/5 hover:-translate-y-1 transition-all duration-300 p-5 md:p-6 relative overflow-hidden border border-slate-100">
                        <div className="absolute top-0 left-0 w-full h-1.5 bg-[#008f39]"></div>
                        <div className="flex justify-between items-start mt-1 md:mt-2">
                            <div>
                                <p className="text-[12px] md:text-[14px] text-slate-500 font-semibold uppercase tracking-wider mb-1 md:mb-2">Alumnos Activos</p>
                                <h3 className="text-4xl md:text-5xl font-black text-slate-800 tracking-tight">0</h3>
                            </div>
                            <div className="p-3 md:p-4 bg-[#008f39]/10 rounded-xl md:rounded-2xl text-[#008f39] group-hover:scale-110 group-hover:bg-[#008f39] group-hover:text-white transition-all duration-300">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 md:h-8 md:w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                                </svg>
                            </div>
                        </div>
                    </div>

                    {/* Profesores */}
                    <div className="group bg-white rounded-2xl shadow-sm hover:shadow-xl hover:shadow-[#008f39]/5 hover:-translate-y-1 transition-all duration-300 p-5 md:p-6 relative overflow-hidden border border-slate-100">
                        <div className="absolute top-0 left-0 w-full h-1.5 bg-[#008f39]"></div>
                        <div className="flex justify-between items-start mt-1 md:mt-2">
                            <div>
                                <p className="text-[12px] md:text-[14px] text-slate-500 font-semibold uppercase tracking-wider mb-1 md:mb-2">Profesores Activos</p>
                                <h3 className="text-4xl md:text-5xl font-black text-slate-800 tracking-tight">0</h3>
                            </div>
                            <div className="p-3 md:p-4 bg-[#008f39]/10 rounded-xl md:rounded-2xl text-[#008f39] group-hover:scale-110 group-hover:bg-[#008f39] group-hover:text-white transition-all duration-300">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 md:h-8 md:w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                                </svg>
                            </div>
                        </div>
                    </div>

                    {/* Cursos */}
                    <div className="group bg-white rounded-2xl shadow-sm hover:shadow-xl hover:shadow-[#008f39]/5 hover:-translate-y-1 transition-all duration-300 p-5 md:p-6 relative overflow-hidden border border-slate-100">
                        <div className="absolute top-0 left-0 w-full h-1.5 bg-[#008f39]"></div>
                        <div className="flex justify-between items-start mt-1 md:mt-2">
                            <div>
                                <p className="text-[12px] md:text-[14px] text-slate-500 font-semibold uppercase tracking-wider mb-1 md:mb-2">Cursos / Divisiones</p>
                                <h3 className="text-4xl md:text-5xl font-black text-slate-800 tracking-tight">12</h3>
                            </div>
                            <div className="p-3 md:p-4 bg-[#008f39]/10 rounded-xl md:rounded-2xl text-[#008f39] group-hover:scale-110 group-hover:bg-[#008f39] group-hover:text-white transition-all duration-300">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 md:h-8 md:w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                                </svg>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Main Content Grid */}
                <div className="grid grid-cols-1 xl:grid-cols-3 gap-6 xl:gap-8 items-start">
                    
                    {/* Left Column (Table) */}
                    <div className="xl:col-span-2 bg-white rounded-2xl shadow-[0_2px_15px_-3px_rgba(0,0,0,0.07)] border border-slate-100 overflow-hidden flex flex-col relative">
                        <div className="absolute top-0 left-0 w-full h-1 bg-[#008f39] z-10"></div>
                        
                        {/* Table Header Controls */}
                        <div className="p-4 md:p-6 border-b border-slate-100 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-white/50 backdrop-blur-sm mt-1">
                            <div>
                                <h3 className="text-slate-800 font-bold text-lg tracking-tight">Distribución de Alumnos</h3>
                                <p className="text-sm text-slate-500 mt-1">Gestión por grado y curso</p>
                            </div>
                            <div className="relative w-full sm:w-auto">
                                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                    <svg className="h-4 w-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                    </svg>
                                </div>
                                <input type="text" placeholder="Buscar curso..." className="bg-slate-50 border border-slate-200 text-slate-600 text-sm rounded-lg pl-9 pr-4 py-2 outline-none focus:border-blue-400 focus:ring-2 focus:ring-blue-100 transition-all w-full sm:w-64" />
                            </div>
                        </div>

                        {/* Responsive Table / Cards Container */}
                        <div className="p-4">
                            
                            {/* Desktop/Tablet Table View (Hidden on mobile) */}
                            <div className="hidden lg:block overflow-x-auto">
                                <table className="w-full text-sm text-left border-separate border-spacing-y-2">
                                    <thead>
                                        <tr className="text-white font-semibold uppercase tracking-wider text-[11px] bg-[#003057] rounded-lg">
                                            <th className="px-5 py-4 rounded-l-lg">Grado/Div</th>
                                            <th className="px-5 py-4 text-center">Turno</th>
                                            <th className="px-5 py-4 text-center">Alumnos</th>
                                            <th className="px-5 py-4 text-center">Ocupación</th>
                                            <th className="px-5 py-4">Materias</th>
                                            <th className="px-5 py-4 text-right rounded-r-lg">Acción</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {cursos.map((curso, index) => (
                                            <tr key={`desktop-${index}`} className="group bg-white hover:bg-blue-50/50 shadow-[0_1px_3px_rgb(0,0,0,0.02)] transition-colors border border-slate-100 rounded-xl">
                                                <td className="px-5 py-4 rounded-l-xl border-y border-l border-slate-100 group-hover:border-blue-100">
                                                    <div className="flex items-center gap-3">
                                                        <div className="w-10 h-10 rounded-full bg-blue-100 text-[#003057] flex items-center justify-center font-bold">
                                                            {curso.grado}
                                                        </div>
                                                        <div>
                                                            <p className="font-bold text-slate-800 text-[15px]">División {curso.div}</p>
                                                            <p className="text-xs text-slate-500">Secundaria</p>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td className="px-5 py-4 border-y border-slate-100 group-hover:border-blue-100 text-center">
                                                    <span className={`px-2.5 py-1 rounded-md text-xs font-semibold ${curso.turno === 'Mañana' ? 'bg-amber-100 text-amber-700' : 'bg-indigo-100 text-indigo-700'}`}>
                                                        {curso.turno}
                                                    </span>
                                                </td>
                                                <td className="px-5 py-4 text-center border-y border-slate-100 group-hover:border-blue-100">
                                                    <span className="font-bold text-slate-700 text-[15px]">{curso.alumnos}</span>
                                                </td>
                                                <td className="px-5 py-4 text-center border-y border-slate-100 group-hover:border-blue-100">
                                                    <div className="flex flex-col items-center gap-1.5">
                                                        <span className="text-xs font-semibold text-slate-500">{curso.total}</span>
                                                        <div className="w-full bg-slate-200 rounded-full h-1.5 max-w-[60px]">
                                                            <div className="bg-slate-400 h-1.5 rounded-full" style={{ width: '0%' }}></div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td className="px-5 py-4 border-y border-slate-100 group-hover:border-blue-100">
                                                    <select className="w-full border border-slate-200 rounded-lg px-3 py-2 text-[13px] text-slate-600 outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 bg-white shadow-sm transition-all cursor-pointer">
                                                        <option>Seleccionar...</option>
                                                        <option>Matemáticas</option>
                                                        <option>Literatura</option>
                                                    </select>
                                                </td>
                                                <td className="px-5 py-4 text-right rounded-r-xl border-y border-r border-slate-100 group-hover:border-blue-100">
                                                    <button className="bg-[#003057] border border-[#003057] text-white hover:text-white hover:bg-[#002244] hover:border-[#002244] px-4 py-2 rounded-lg text-[13px] font-semibold inline-flex items-center gap-2 transition-all shadow-sm">
                                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                                        </svg>
                                                        Promedios
                                                    </button>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>

                            {/* Mobile Card View (Hidden on large screens) */}
                            <div className="lg:hidden flex flex-col gap-4">
                                {cursos.map((curso, index) => (
                                    <div key={`mobile-${index}`} className="bg-white border border-slate-200 rounded-xl p-4 shadow-sm hover:shadow-md transition-shadow">
                                        <div className="flex justify-between items-start mb-4 border-b border-slate-100 pb-3">
                                            <div className="flex items-center gap-3">
                                                <div className="w-12 h-12 rounded-full bg-blue-100 text-[#003057] flex items-center justify-center font-black text-lg">
                                                    {curso.grado}
                                                </div>
                                                <div>
                                                    <p className="font-bold text-slate-800 text-[16px]">División {curso.div}</p>
                                                    <p className="text-xs text-slate-500 font-medium">Secundaria</p>
                                                </div>
                                            </div>
                                            <span className={`px-2.5 py-1 rounded-md text-xs font-bold ${curso.turno === 'Mañana' ? 'bg-amber-100 text-amber-700' : 'bg-indigo-100 text-indigo-700'}`}>
                                                {curso.turno}
                                            </span>
                                        </div>
                                        
                                        <div className="grid grid-cols-2 gap-4 mb-4">
                                            <div className="bg-slate-50 p-3 rounded-lg border border-slate-100 flex flex-col items-center justify-center">
                                                <p className="text-[11px] text-slate-500 font-bold uppercase tracking-wider mb-1">Alumnos</p>
                                                <span className="font-black text-slate-800 text-xl">{curso.alumnos}</span>
                                            </div>
                                            <div className="bg-slate-50 p-3 rounded-lg border border-slate-100 flex flex-col items-center justify-center">
                                                <p className="text-[11px] text-slate-500 font-bold uppercase tracking-wider mb-1">Ocupación</p>
                                                <span className="font-bold text-slate-700 text-lg mb-1">{curso.total}</span>
                                                <div className="w-full bg-slate-200 rounded-full h-1.5 max-w-[80%]">
                                                    <div className="bg-slate-400 h-1.5 rounded-full" style={{ width: '0%' }}></div>
                                                </div>
                                            </div>
                                        </div>

                                        <div className="space-y-3">
                                            <div>
                                                <label className="text-xs font-bold text-slate-500 uppercase tracking-wide ml-1 mb-1 block">Materias</label>
                                                <select className="w-full border border-slate-200 rounded-lg px-3 py-2.5 text-sm text-slate-700 outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 bg-white transition-all cursor-pointer">
                                                    <option>Seleccionar materia...</option>
                                                    <option>Matemáticas</option>
                                                    <option>Literatura</option>
                                                </select>
                                            </div>
                                            <button className="w-full bg-[#003057] text-white hover:bg-[#002244] py-2.5 rounded-lg text-sm font-bold flex items-center justify-center gap-2 transition-all shadow-sm">
                                                <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                                </svg>
                                                Gestionar Promedios
                                            </button>
                                        </div>
                                    </div>
                                ))}
                            </div>

                        </div>
                    </div>

                    {/* Right Column (Inscriptions) */}
                    <div className="bg-white rounded-2xl shadow-[0_2px_15px_-3px_rgba(0,0,0,0.07)] border border-slate-100 flex flex-col h-full overflow-hidden relative mt-6 xl:mt-0">
                        <div className="absolute top-0 left-0 w-full h-1 bg-[#008f39] z-10"></div>
                        <div className="p-4 md:p-6 border-b border-slate-100 flex justify-between items-center bg-white/50 backdrop-blur-sm mt-1">
                            <div>
                                <h3 className="text-slate-800 font-bold text-lg tracking-tight">Últimas Inscripciones</h3>
                            </div>
                        </div>
                        <div className="flex-1 p-8 flex flex-col items-center justify-center text-center min-h-[300px]">
                            <div className="w-20 h-20 md:w-24 md:h-24 bg-slate-50 rounded-full flex items-center justify-center mb-4 md:mb-6 shadow-inner border border-slate-100">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-8 w-8 md:h-10 md:w-10 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
                                </svg>
                            </div>
                            <p className="text-sm text-slate-500 font-medium">No hay inscripciones recientes</p>
                        </div>
                    </div>

                </div>
            </div>
        </AdminLayout>
    );
}
