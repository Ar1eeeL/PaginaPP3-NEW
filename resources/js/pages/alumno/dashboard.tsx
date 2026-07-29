import React, { useState } from 'react';
import { Head, usePage } from '@inertiajs/react';
import AlumnoLayout from '@/layouts/AlumnoLayout';

export default function AlumnoDashboard({ materias = [] }: { materias?: string[] }) {
    const { auth } = usePage().props as any;
    const [calendarTab, setCalendarTab] = useState('Todos');

    const userName = auth?.user?.name || "Alumno";

    return (
        <AlumnoLayout>
            <Head title="Campus Virtual - Alumno" />
            
            <div className="max-w-[1400px] mx-auto space-y-8">
                
                {/* Premium Header Banner */}
                <div className="bg-gradient-to-r from-[#0b5f38] to-[#003057] rounded-3xl p-8 md:p-10 text-white shadow-lg relative overflow-hidden flex flex-col md:flex-row items-start md:items-center justify-between">
                    {/* Decorative pattern */}
                    <div className="absolute top-0 right-0 -mt-10 -mr-10 opacity-10 pointer-events-none">
                        <svg width="400" height="400" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <circle cx="50" cy="50" r="40" stroke="white" strokeWidth="2" strokeDasharray="4 4" />
                            <circle cx="50" cy="50" r="30" stroke="white" strokeWidth="2" />
                            <circle cx="50" cy="50" r="20" stroke="white" strokeWidth="2" strokeDasharray="4 4" />
                        </svg>
                    </div>

                    <div className="relative z-10 space-y-2">
                        <span className="bg-white/20 text-white text-xs font-bold px-3 py-1 rounded-full uppercase tracking-widest backdrop-blur-sm border border-white/30">Panel Principal</span>
                        <h1 className="text-3xl md:text-5xl font-black tracking-tight mt-4">¡Hola, {userName.split(' ')[0]}!</h1>
                        <p className="text-white/80 text-sm md:text-base font-medium max-w-lg mt-2">
                            Revisa tus actividades del día, mantente al tanto de los avisos y organiza tu calendario académico desde un solo lugar.
                        </p>
                    </div>

                    {/* Quick Info Box (Date/Time) */}
                    <div className="hidden md:flex flex-col items-end relative z-10">
                        <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-5 text-right">
                            <p className="text-sm text-white/80 font-semibold uppercase tracking-wider mb-1">Hoy es</p>
                            <p className="text-2xl font-bold">29 de Julio, 2026</p>
                        </div>
                    </div>
                </div>

                {/* KPI / Quick Stats */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    {/* Stat 1 */}
                    <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200 flex items-center gap-5 hover:shadow-md transition-shadow group">
                        <div className="w-14 h-14 rounded-xl bg-[#008f39]/10 text-[#008f39] flex items-center justify-center group-hover:scale-110 transition-transform">
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                        <div>
                            <p className="text-sm font-bold text-slate-500 uppercase tracking-wider">Asistencia</p>
                            <p className="text-3xl font-black text-[#003057]">95<span className="text-lg text-slate-400">%</span></p>
                        </div>
                    </div>

                    {/* Stat 2 */}
                    <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200 flex items-center gap-5 hover:shadow-md transition-shadow group">
                        <div className="w-14 h-14 rounded-xl bg-[#003057]/10 text-[#003057] flex items-center justify-center group-hover:scale-110 transition-transform">
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                            </svg>
                        </div>
                        <div>
                            <p className="text-sm font-bold text-slate-500 uppercase tracking-wider">Promedio Gral.</p>
                            <p className="text-3xl font-black text-[#003057]">8.75</p>
                        </div>
                    </div>

                    {/* Stat 3 */}
                    <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200 flex items-center gap-5 hover:shadow-md transition-shadow group">
                        <div className="w-14 h-14 rounded-xl bg-orange-50 text-orange-500 flex items-center justify-center group-hover:scale-110 transition-transform">
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                        <div>
                            <p className="text-sm font-bold text-slate-500 uppercase tracking-wider">Tareas Pendientes</p>
                            <p className="text-3xl font-black text-[#003057]">2</p>
                        </div>
                    </div>
                </div>

                {/* Main Grid */}
                <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
                    
                    {/* Left Column */}
                    <div className="lg:col-span-8 space-y-6">
                        
                        {/* Actividades de Hoy (Timeline) */}
                        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative">
                            <div className="absolute top-0 left-0 w-1.5 h-full bg-[#008f39]"></div>
                            <div className="p-6 md:p-8">
                                <div className="flex items-center justify-between mb-6 border-b border-slate-100 pb-4">
                                    <h2 className="text-xl font-bold text-[#003057] flex items-center gap-2">
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-[#008f39]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                        </svg>
                                        Clases de Hoy
                                    </h2>
                                    <span className="text-sm font-bold text-[#008f39] bg-[#008f39]/10 px-3 py-1 rounded-full">Turno Mañana</span>
                                </div>
                                
                                <div className="space-y-6 relative before:absolute before:inset-0 before:ml-4 before:-translate-x-px md:before:mx-auto md:before:translate-x-0 before:h-full before:w-0.5 before:bg-slate-200">
                                    
                                    {/* Item 1 */}
                                    <div className="relative flex items-center justify-between md:justify-normal md:odd:flex-row-reverse group is-active">
                                        <div className="flex items-center justify-center w-8 h-8 rounded-full border-4 border-white bg-[#008f39] text-white shadow shrink-0 md:order-1 md:group-odd:-translate-x-1/2 md:group-even:translate-x-1/2 z-10"></div>
                                        <div className="w-[calc(100%-3rem)] md:w-[calc(50%-2rem)] p-4 rounded-xl border border-[#008f39]/30 bg-[#008f39]/5 shadow-sm">
                                            <div className="flex items-center justify-between mb-1">
                                                <span className="text-xs font-bold text-[#008f39] bg-white px-2 py-0.5 rounded shadow-sm">08:00 - 09:20</span>
                                                <span className="text-xs font-bold text-slate-400">Aula 12</span>
                                            </div>
                                            <h3 className="font-bold text-[#003057] text-base">Matemática</h3>
                                            <p className="text-sm text-slate-600 mt-1">Prof. Gómez, Carlos</p>
                                        </div>
                                    </div>

                                    {/* Item 2 */}
                                    <div className="relative flex items-center justify-between md:justify-normal md:odd:flex-row-reverse group">
                                        <div className="flex items-center justify-center w-8 h-8 rounded-full border-4 border-white bg-slate-300 text-slate-500 shadow shrink-0 md:order-1 md:group-odd:-translate-x-1/2 md:group-even:translate-x-1/2 z-10"></div>
                                        <div className="w-[calc(100%-3rem)] md:w-[calc(50%-2rem)] p-4 rounded-xl border border-slate-200 bg-white shadow-sm hover:border-slate-300 transition-colors">
                                            <div className="flex items-center justify-between mb-1">
                                                <span className="text-xs font-bold text-slate-500 bg-slate-100 px-2 py-0.5 rounded">09:30 - 10:50</span>
                                                <span className="text-xs font-bold text-slate-400">Aula 12</span>
                                            </div>
                                            <h3 className="font-bold text-[#003057] text-base">Lengua y Literatura</h3>
                                            <p className="text-sm text-slate-600 mt-1">Prof. Martínez, Laura</p>
                                        </div>
                                    </div>

                                    {/* Item 3 */}
                                    <div className="relative flex items-center justify-between md:justify-normal md:odd:flex-row-reverse group">
                                        <div className="flex items-center justify-center w-8 h-8 rounded-full border-4 border-white bg-slate-300 text-slate-500 shadow shrink-0 md:order-1 md:group-odd:-translate-x-1/2 md:group-even:translate-x-1/2 z-10"></div>
                                        <div className="w-[calc(100%-3rem)] md:w-[calc(50%-2rem)] p-4 rounded-xl border border-slate-200 bg-white shadow-sm hover:border-slate-300 transition-colors">
                                            <div className="flex items-center justify-between mb-1">
                                                <span className="text-xs font-bold text-slate-500 bg-slate-100 px-2 py-0.5 rounded">11:10 - 12:30</span>
                                                <span className="text-xs font-bold text-slate-400">Lab 1</span>
                                            </div>
                                            <h3 className="font-bold text-[#003057] text-base">Física</h3>
                                            <p className="text-sm text-slate-600 mt-1">Prof. Fernández, Roberto</p>
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </div>

                    </div>

                    {/* Right Column */}
                    <div className="lg:col-span-4 space-y-6">
                        
                        {/* Avisos */}
                        <div className="bg-[#003057] rounded-2xl shadow-md border border-[#002244] overflow-hidden relative">
                            <div className="absolute top-0 right-0 p-4 opacity-20 pointer-events-none">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-16 w-16 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                                </svg>
                            </div>
                            <div className="p-6 relative z-10">
                                <h3 className="text-lg font-bold text-white mb-4">Avisos Importantes</h3>
                                
                                <div className="space-y-3">
                                    <div className="bg-[#002244]/50 border border-white/10 rounded-xl p-4 hover:bg-[#002244] transition-colors cursor-pointer">
                                        <div className="flex items-center gap-2 mb-1">
                                            <div className="w-2 h-2 rounded-full bg-red-400 shrink-0"></div>
                                            <span className="text-xs font-bold text-[#daf4f6]">Preceptoría</span>
                                        </div>
                                        <p className="text-sm text-white font-medium leading-snug">Reunión de padres programada para el 15 de Agosto.</p>
                                    </div>
                                    
                                    <div className="bg-[#002244]/50 border border-white/10 rounded-xl p-4 hover:bg-[#002244] transition-colors cursor-pointer">
                                        <div className="flex items-center gap-2 mb-1">
                                            <div className="w-2 h-2 rounded-full bg-[#ffb81c] shrink-0"></div>
                                            <span className="text-xs font-bold text-[#daf4f6]">Secretaría</span>
                                        </div>
                                        <p className="text-sm text-white font-medium leading-snug">Recordatorio: Entregar ficha médica actualizada.</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Calendar Widget */}
                        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                            
                            {/* Calendar Tabs */}
                            <div className="flex border-b border-slate-200 bg-slate-50/50 p-2 gap-2">
                                <button 
                                    onClick={() => setCalendarTab('Todos')}
                                    className={`flex-1 py-1.5 px-2 rounded-lg text-[12px] font-bold flex items-center justify-center gap-1.5 transition-all ${
                                        calendarTab === 'Todos' ? 'bg-[#003057] text-white shadow-md shadow-[#003057]/20 scale-105' : 'bg-white text-slate-500 border border-slate-200 hover:bg-slate-100 hover:text-slate-800'
                                    }`}
                                >
                                    Todos
                                </button>
                                <button 
                                    onClick={() => setCalendarTab('Evaluaciones')}
                                    className={`flex-1 py-1.5 px-2 rounded-lg text-[12px] font-bold flex items-center justify-center gap-1.5 transition-all ${
                                        calendarTab === 'Evaluaciones' ? 'bg-[#008f39] text-white shadow-md shadow-[#008f39]/20 scale-105' : 'bg-white text-slate-500 border border-slate-200 hover:bg-slate-100 hover:text-slate-800'
                                    }`}
                                >
                                    Eval.
                                </button>
                                <button 
                                    onClick={() => setCalendarTab('Eventos')}
                                    className={`flex-1 py-1.5 px-2 rounded-lg text-[12px] font-bold flex items-center justify-center gap-1.5 transition-all ${
                                        calendarTab === 'Eventos' ? 'bg-orange-500 text-white shadow-md shadow-orange-500/20 scale-105' : 'bg-white text-slate-500 border border-slate-200 hover:bg-slate-100 hover:text-slate-800'
                                    }`}
                                >
                                    Eventos
                                </button>
                            </div>

                            <div className="p-6">
                                {/* Calendar Controls */}
                                <div className="flex items-center justify-between gap-3 mb-6">
                                    <div className="flex-1 flex gap-2">
                                        <select className="w-full bg-[#eef3f7] border-none text-[#003057] font-bold text-sm rounded-lg px-3 py-2 outline-none cursor-pointer focus:ring-2 focus:ring-[#003057]/20">
                                            <option>Julio</option>
                                        </select>
                                        <select className="w-full bg-[#eef3f7] border-none text-[#003057] font-bold text-sm rounded-lg px-3 py-2 outline-none cursor-pointer focus:ring-2 focus:ring-[#003057]/20">
                                            <option>2026</option>
                                        </select>
                                    </div>
                                    <div className="flex gap-1.5">
                                        <button className="w-9 h-9 flex items-center justify-center bg-[#eef3f7] text-[#003057] rounded-lg hover:bg-[#d8e3eb] transition-colors">
                                            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" />
                                            </svg>
                                        </button>
                                        <button className="w-9 h-9 flex items-center justify-center bg-[#eef3f7] text-[#003057] rounded-lg hover:bg-[#d8e3eb] transition-colors">
                                            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 5l7 7-7 7" />
                                            </svg>
                                        </button>
                                    </div>
                                </div>

                                {/* Calendar Grid */}
                                <div className="grid grid-cols-7 gap-y-3 gap-x-1 text-center">
                                    {/* Days */}
                                    {['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day, i) => (
                                        <div key={i} className="text-xs font-black text-slate-400 mb-2 uppercase">{day}</div>
                                    ))}
                                    
                                    {/* Empty slots */}
                                    <div></div><div></div>
                                    
                                    {/* Dates */}
                                    {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28].map(date => (
                                        <div key={date} className="relative flex items-center justify-center group">
                                            <div className="text-[14px] font-medium text-slate-700 flex items-center justify-center h-8 w-8 cursor-pointer group-hover:bg-slate-100 rounded-full transition-colors">
                                                {date}
                                            </div>
                                            {/* Dummy Event Dots */}
                                            {date === 15 && <span className="absolute bottom-0 w-1 h-1 rounded-full bg-red-400"></span>}
                                            {date === 22 && <span className="absolute bottom-0 w-1 h-1 rounded-full bg-[#008f39]"></span>}
                                        </div>
                                    ))}

                                    {/* Highlighted Date */}
                                    <div className="relative flex items-center justify-center">
                                        <div className="text-[14px] text-white flex items-center justify-center h-9 w-9 bg-[#003057] rounded-full font-bold shadow-md shadow-[#003057]/30 cursor-pointer hover:bg-[#002244] transform hover:scale-110 transition-all">
                                            29
                                        </div>
                                    </div>

                                    {[30, 31].map(date => (
                                        <div key={date} className="relative flex items-center justify-center group">
                                            <div className="text-[14px] font-medium text-slate-700 flex items-center justify-center h-8 w-8 cursor-pointer group-hover:bg-slate-100 rounded-full transition-colors">
                                                {date}
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

            </div>
        </AlumnoLayout>
    );
}
