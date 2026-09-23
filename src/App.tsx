import React, { useState } from 'react';
import {
  Theater,
  Calendar,
  Users,
  AlertTriangle,
  CheckCircle2,
  Clock,
  MapPin,
  Plus,
  Trash2,
  Edit,
  LogIn,
  LogOut,
  UserCheck,
  FileCode,
  Smartphone,
  Layers,
  ChevronRight,
  Sparkles,
  Search,
  ShieldCheck,
  Copy,
  Check,
  Play,
  Sun,
  Moon,
  Monitor,
  Bell,
  SlidersHorizontal,
  Bookmark,
  FileText,
  ExternalLink,
  Info,
  CheckCircle,
  X,
  Phone,
  ArrowRight,
  HelpCircle,
  Eye,
  EyeOff
} from 'lucide-react';

// Types
interface ProductionItem {
  id: string;
  title: string;
  playwright: string;
  dates: string;
  director: string;
  venue: string;
  castCount: number;
  upcomingEventsCount: number;
  imageURL: string;
  statusTag: string;
  code: string;
  timelineLabel: string;
  timelineProgress: number; // percentage
  milestones: { name: string; date: string; active?: boolean }[];
  attendanceRate: string;
}

interface RoleItem {
  id: string;
  productionId: string;
  character: string;
  type: string; // 'Lead' | 'Ensemble' | 'Supporting'
  actorName?: string;
  actorEmail?: string;
  assigned: boolean;
  conflict?: string;
  onTimeRate?: string;
  candidatesCount?: number;
}

interface EventItem {
  id: string;
  productionId: string;
  productionTitle: string;
  title: string;
  date: string;
  timeRange: string;
  duration: string;
  startMinutes: number;
  endMinutes: number;
  type: 'Rehearsal' | 'Production Meeting' | 'Audition Call' | 'Dress Rehearsal' | 'Performance';
  venue: string;
  castInfo: string;
  avatars: string[];
  notes?: string;
  conflictWarning?: string;
  bucket: 'TODAY' | 'TOMORROW' | 'UPCOMING';
  pillColor?: string;
}

interface AuditionSlot {
  id: string;
  productionTitle: string;
  dateMonth: string;
  dateDay: string;
  callTime: string;
  venue: string;
  slotCode: string;
  roleOpenings: string;
  submissionsCount: number;
  applicantInitials: string[];
  isSignedUp: boolean;
  bannerImg: string;
  preparedMaterial?: string;
  castingDirector?: string;
  isDirectorView: boolean;
}

const INITIAL_PRODUCTIONS: ProductionItem[] = [
  {
    id: 'prod-hamlet',
    title: 'Hamlet',
    playwright: 'By William Shakespeare',
    dates: 'Oct 1 – Oct 20, 2025',
    director: 'Ananya Sharma',
    venue: 'Main Auditorium',
    castCount: 12,
    upcomingEventsCount: 5,
    imageURL: 'https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?w=600&auto=format&fit=crop&q=80',
    statusTag: 'Tech Rehearsals',
    code: 'PROD-08',
    timelineLabel: 'Week 3 of 6 (50%)',
    timelineProgress: 50,
    milestones: [
      { name: 'Stumble-through', date: 'Oct 14', active: true },
      { name: 'Final Dress', date: 'Oct 18', active: false },
    ],
    attendanceRate: '94% Call Attendance',
  },
  {
    id: 'prod-tempest',
    title: 'The Tempest',
    playwright: 'By William Shakespeare',
    dates: 'Nov 20 – Dec 5, 2025',
    director: 'Ananya Sharma',
    venue: 'Studio B & Stage 2',
    castCount: 8,
    upcomingEventsCount: 3,
    imageURL: 'https://images.unsplash.com/photo-1469488865564-c2de10f69f96?w=600&auto=format&fit=crop&q=80',
    statusTag: 'Pre-Prod & Casting',
    code: 'PROD-09',
    timelineLabel: 'Phase 1: Auditions Complete',
    timelineProgress: 25,
    milestones: [
      { name: 'Auditions Round 2', date: 'Oct 13', active: true },
      { name: 'First Table Read', date: 'Oct 28', active: false },
    ],
    attendanceRate: 'Auditions Open',
  },
];

const INITIAL_ROLES: RoleItem[] = [
  { id: 'role-1', productionId: 'prod-hamlet', character: 'Hamlet', type: 'Lead', actorName: 'John Smith', actorEmail: 'john.smith@actor.org', assigned: true, onTimeRate: '100% on-time' },
  { id: 'role-2', productionId: 'prod-hamlet', character: 'Ophelia', type: 'Supporting', actorName: 'Sarah Jenkins', actorEmail: 'sarah.j@actor.org', assigned: true, conflict: 'Dress Fitting vs Act I Staging' },
  { id: 'role-3', productionId: 'prod-hamlet', character: 'Claudius', type: 'Lead', assigned: false, candidatesCount: 4 },
  { id: 'role-4', productionId: 'prod-hamlet', character: 'Gertrude', type: 'Supporting', actorName: 'Elena Rostova', actorEmail: 'e.rostova@ensemble.net', assigned: true },
  { id: 'role-5', productionId: 'prod-hamlet', character: 'Polonius', type: 'Supporting', actorName: 'Michael Brown', actorEmail: 'm.brown@theatreworks.com', assigned: true },
];

const INITIAL_EVENTS: EventItem[] = [
  {
    id: 'evt-1',
    productionId: 'prod-hamlet',
    productionTitle: 'Hamlet',
    title: 'Hamlet — Act II Blocking',
    date: 'TODAY • OCT 12',
    timeRange: '10:00 AM – 1:00 PM',
    duration: '3h Run',
    startMinutes: 10 * 60,
    endMinutes: 13 * 60,
    type: 'Rehearsal',
    venue: 'Main Auditorium',
    castInfo: 'Sarah J., John S. +4 others (6/6 confirmed)',
    avatars: ['SJ', 'JS', 'MB'],
    notes: 'Act II Scene 1 court entrance and ghost encounter',
    bucket: 'TODAY',
  },
  {
    id: 'evt-2',
    productionId: 'prod-tempest',
    productionTitle: 'The Tempest',
    title: 'The Tempest — Lighting Cue Sync',
    date: 'TODAY • OCT 12',
    timeRange: '2:00 PM – 3:30 PM',
    duration: '90m Session',
    startMinutes: 14 * 60,
    endMinutes: 15.5 * 60,
    type: 'Production Meeting',
    venue: 'Studio B',
    castInfo: 'Design Team & Stage Manager (4 confirmed)',
    avatars: ['AS', 'LD'],
    notes: 'Includes DMX console deck testing with LD Vance',
    bucket: 'TODAY',
  },
  {
    id: 'evt-3',
    productionId: 'prod-tempest',
    productionTitle: 'The Tempest',
    title: 'The Tempest — Caliban & Ariel Auditions',
    date: 'TOMORROW • OCT 13',
    timeRange: '11:00 AM – 1:30 PM',
    duration: '2.5h Call',
    startMinutes: 11 * 60,
    endMinutes: 13.5 * 60,
    type: 'Audition Call',
    venue: 'Audition Room 201',
    castInfo: '8 candidates scheduled',
    avatars: ['MK', 'EL'],
    notes: 'Sides: Act I Sc II (Monologues)',
    bucket: 'TOMORROW',
  },
  {
    id: 'evt-4',
    productionId: 'prod-hamlet',
    productionTitle: 'Hamlet',
    title: 'Hamlet — Full Run Act I & II',
    date: 'TOMORROW • OCT 13',
    timeRange: '6:00 PM – 9:00 PM',
    duration: '3h Run',
    startMinutes: 18 * 60,
    endMinutes: 21 * 60,
    type: 'Dress Rehearsal',
    venue: 'Main Auditorium',
    castInfo: 'Full Pit & Costumes',
    avatars: ['JS', 'SJ', 'ER', 'MB'],
    notes: 'SM Call: 5:15 PM • Curtain Call run-through: 8:45 PM',
    conflictWarning: 'Sarah Jenkins (Ophelia) double-booked with Wardrobe Fitting Session B.',
    bucket: 'TOMORROW',
  },
];

const INITIAL_AUDITIONS: AuditionSlot[] = [
  {
    id: 'aud-1',
    productionTitle: 'Hamlet',
    dateMonth: 'SEP',
    dateDay: '20',
    callTime: '3:00 PM Call',
    venue: 'Room 201 • Rehearsal Wing B',
    slotCode: 'Slot #A4',
    roleOpenings: 'Claudius, Ensemble',
    submissionsCount: 8,
    applicantInitials: ['EL', 'MK', 'JS', '+5'],
    isSignedUp: false,
    bannerImg: 'https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?w=600&auto=format&fit=crop&q=80',
    isDirectorView: true,
  },
  {
    id: 'aud-2',
    productionTitle: 'The Tempest',
    dateMonth: 'OCT',
    dateDay: '13',
    callTime: '11:00 AM – 1:30 PM',
    venue: 'Audition Room 201',
    slotCode: 'Slot: 11:45 AM',
    roleOpenings: 'Caliban & Ariel',
    preparedMaterial: '2-Min Monologue + Cold',
    submissionsCount: 12,
    applicantInitials: ['SJ', 'MB', 'DK'],
    isSignedUp: true,
    bannerImg: 'https://images.unsplash.com/photo-1469488865564-c2de10f69f96?w=600&auto=format&fit=crop&q=80',
    castingDirector: 'Helena Shaw',
    isDirectorView: false,
  },
];

export default function App() {
  const [activeTab, setActiveTab] = useState<'simulator' | 'conflict_lab' | 'code_browser' | 'test_runner'>('simulator');
  
  // Mobile app view inside phone
  const [phoneScreen, setPhoneScreen] = useState<'home' | 'schedule' | 'productions' | 'profile' | 'production_details' | 'auditions' | 'create_event' | 'login' | 'signup'>('home');
  const [selectedProd, setSelectedProd] = useState<ProductionItem>(INITIAL_PRODUCTIONS[0]);
  const [prodDetailsTab, setProdDetailsTab] = useState<'roles' | 'schedule' | 'auditions'>('roles');
  
  // Theme inside the phone (Light is default!)
  const [themeMode, setThemeMode] = useState<'light' | 'dark' | 'system'>('light');

  // Interactive State
  const [currentUserRole, setCurrentUserRole] = useState<'director' | 'cast'>('director');
  const [scheduleFilter, setScheduleFilter] = useState<'all' | 'Rehearsal' | 'Audition' | 'Performance'>('all');
  const [auditionsTab, setAuditionsTab] = useState<'upcoming' | 'my_signups'>('upcoming');
  const [tempestSignedUp, setTempestSignedUp] = useState<boolean>(true);

  // New Event Form State
  const [formEventType, setFormEventType] = useState<'Rehearsal' | 'Performance' | 'Audition' | 'Prod Meeting'>('Rehearsal');
  const [formProd, setFormProd] = useState('Hamlet (Oct 1 – Oct 20)');
  const [formDate, setFormDate] = useState('October 15, 2025');
  const [formStartTime, setFormStartTime] = useState('18:00');
  const [formEndTime, setFormEndTime] = useState('20:00');
  const [formVenue, setFormVenue] = useState('Main Auditorium');
  const [formCast, setFormCast] = useState<string[]>(['Sarah Jenkins (Ophelia)', 'John Smith (Hamlet)', 'Michael Brown (Polonius)']);
  const [formNotes, setFormNotes] = useState('Act 1 blocking rehearsal and script walk-through.');

  // Venue Conflict Modal State
  const [conflictModalOpen, setConflictModalOpen] = useState(false);
  const [conflictData, setConflictData] = useState({
    title: 'Venue Conflict',
    subtitle: 'Main Auditorium is already booked during this time.',
    venue: 'Main Auditorium (Stage & Pit)',
    conflictingProduction: 'Hamlet Rehearsal',
    productionSeries: 'Hamlet (Fall Season)',
    timeRange: '6:00 PM – 8:00 PM (2 hr block)',
    bookedBy: 'Stage Manager / Tech Crew',
    suggestion: 'Adjusting start time to 8:15 PM or relocating to Studio B resolves this conflict with zero scheduling warnings.',
  });

  // Check Overlap helper
  const checkConflict = () => {
    const startM = parseInt(formStartTime.split(':')[0]) * 60 + parseInt(formStartTime.split(':')[1] || '0');
    const endM = parseInt(formEndTime.split(':')[0]) * 60 + parseInt(formEndTime.split(':')[1] || '0');

    // Overlaps 18:00 to 20:00 at Main Auditorium?
    if (formVenue === 'Main Auditorium' && startM < 20 * 60 && endM > 18 * 60) {
      setConflictModalOpen(true);
      return true;
    }
    return false;
  };

  const isDark = themeMode === 'dark';
  const phoneBg = isDark ? 'bg-[#121118]' : 'bg-[#FAF8FF]';
  const surfaceWhite = isDark ? 'bg-[#1E1D24] border-white/10 text-white' : 'bg-white border-[#EAE8EE] text-[#131B2E] shadow-[0_1px_3px_rgba(0,0,0,0.03)]';
  const textSub = isDark ? 'text-gray-400' : 'text-[#574144]';
  const textPrimary = isDark ? 'text-white' : 'text-[#131B2E]';

  return (
    <div className="min-h-screen bg-[#0E0D13] text-gray-100 flex flex-col font-sans selection:bg-[#881337] selection:text-white">
      {/* Top Application Ribbon */}
      <header className="border-b border-white/10 bg-[#15141C]/90 backdrop-blur sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 py-3 flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-[#881337] flex items-center justify-center shadow-md shadow-[#881337]/30">
              <Theater className="w-5 h-5 text-white" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-lg font-bold tracking-tight text-white">StageSync</h1>
                <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#881337]/30 border border-[#881337] text-[#FFB2BD]">
                  Stitch Visual Standard
                </span>
              </div>
              <p className="text-[11px] text-gray-400">Professional Theatre Management Suite</p>
            </div>
          </div>

          {/* Nav Tabs */}
          <div className="flex items-center bg-black/50 p-1 rounded-xl border border-white/10 text-xs">
            <button
              onClick={() => setActiveTab('simulator')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition ${
                activeTab === 'simulator' ? 'bg-[#881337] text-white shadow' : 'text-gray-400 hover:text-white'
              }`}
            >
              <Smartphone className="w-3.5 h-3.5" />
              Mobile App View
            </button>
            <button
              onClick={() => setActiveTab('conflict_lab')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition ${
                activeTab === 'conflict_lab' ? 'bg-[#881337] text-white shadow' : 'text-gray-400 hover:text-white'
              }`}
            >
              <AlertTriangle className="w-3.5 h-3.5" />
              Conflict Engine Lab
            </button>
            <button
              onClick={() => setActiveTab('code_browser')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition ${
                activeTab === 'code_browser' ? 'bg-[#881337] text-white shadow' : 'text-gray-400 hover:text-white'
              }`}
            >
              <FileCode className="w-3.5 h-3.5" />
              Flutter Architecture
            </button>
            <button
              onClick={() => setActiveTab('test_runner')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition ${
                activeTab === 'test_runner' ? 'bg-[#881337] text-white shadow' : 'text-gray-400 hover:text-white'
              }`}
            >
              <ShieldCheck className="w-3.5 h-3.5" />
              Unit Tests
            </button>
          </div>
        </div>
      </header>

      {/* Main Workspace */}
      <main className="flex-1 max-w-7xl w-full mx-auto p-4 sm:p-6">
        {activeTab === 'simulator' && (
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
            {/* Left Column: Screen Navigation & Role Switcher */}
            <div className="lg:col-span-4 space-y-4">
              {/* Screen Jumper Card */}
              <div className="bg-[#171620] border border-white/10 rounded-2xl p-5 shadow-xl space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold uppercase tracking-wider text-[#FFB2BD] flex items-center gap-1.5">
                    <Sparkles className="w-3.5 h-3.5 text-[#D97706]" />
                    Stitch Screens
                  </span>
                  <span className="text-[10px] bg-black/40 px-2 py-0.5 rounded text-gray-400">Jump to Screen</span>
                </div>

                <div className="grid grid-cols-2 gap-2 text-xs">
                  <button
                    onClick={() => setPhoneScreen('home')}
                    className={`p-2.5 rounded-xl border text-left flex items-center justify-between transition ${
                      phoneScreen === 'home' ? 'bg-[#881337]/20 border-[#881337] text-white font-bold' : 'border-white/5 bg-black/30 text-gray-400 hover:text-white'
                    }`}
                  >
                    <span>1. Home Deck</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => setPhoneScreen('schedule')}
                    className={`p-2.5 rounded-xl border text-left flex items-center justify-between transition ${
                      phoneScreen === 'schedule' ? 'bg-[#881337]/20 border-[#881337] text-white font-bold' : 'border-white/5 bg-black/30 text-gray-400 hover:text-white'
                    }`}
                  >
                    <span>2. Callboard</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => setPhoneScreen('productions')}
                    className={`p-2.5 rounded-xl border text-left flex items-center justify-between transition ${
                      phoneScreen === 'productions' ? 'bg-[#881337]/20 border-[#881337] text-white font-bold' : 'border-white/5 bg-black/30 text-gray-400 hover:text-white'
                    }`}
                  >
                    <span>3. Productions</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => setPhoneScreen('production_details')}
                    className={`p-2.5 rounded-xl border text-left flex items-center justify-between transition ${
                      phoneScreen === 'production_details' ? 'bg-[#881337]/20 border-[#881337] text-white font-bold' : 'border-white/5 bg-black/30 text-gray-400 hover:text-white'
                    }`}
                  >
                    <span>4. Prod Details</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => setPhoneScreen('auditions')}
                    className={`p-2.5 rounded-xl border text-left flex items-center justify-between transition ${
                      phoneScreen === 'auditions' ? 'bg-[#881337]/20 border-[#881337] text-white font-bold' : 'border-white/5 bg-black/30 text-gray-400 hover:text-white'
                    }`}
                  >
                    <span>5. Auditions</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => setPhoneScreen('create_event')}
                    className={`p-2.5 rounded-xl border text-left flex items-center justify-between transition ${
                      phoneScreen === 'create_event' ? 'bg-[#881337]/20 border-[#881337] text-white font-bold' : 'border-white/5 bg-black/30 text-gray-400 hover:text-white'
                    }`}
                  >
                    <span>6. Create Event</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => setPhoneScreen('profile')}
                    className={`p-2.5 rounded-xl border text-left flex items-center justify-between transition ${
                      phoneScreen === 'profile' ? 'bg-[#881337]/20 border-[#881337] text-white font-bold' : 'border-white/5 bg-black/30 text-gray-400 hover:text-white'
                    }`}
                  >
                    <span>7. Profile</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => setConflictModalOpen(true)}
                    className="p-2.5 rounded-xl border border-red-500/30 bg-red-950/20 text-red-300 text-left flex items-center justify-between hover:bg-red-950/40 transition"
                  >
                    <span className="font-bold">8. Conflict Dialog</span>
                    <AlertTriangle className="w-3.5 h-3.5 text-red-400" />
                  </button>
                </div>
              </div>

              {/* Persona Switcher */}
              <div className="bg-[#171620] border border-white/10 rounded-2xl p-4 text-xs space-y-3">
                <span className="font-bold text-gray-300 block">Active Backstage Role:</span>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    onClick={() => setCurrentUserRole('director')}
                    className={`p-2.5 rounded-xl border text-left transition ${
                      currentUserRole === 'director' ? 'bg-[#881337]/20 border-[#881337] text-white' : 'bg-black/20 border-white/10 text-gray-400'
                    }`}
                  >
                    <span className="font-bold block">Ananya Sharma</span>
                    <span className="text-[10px] text-gray-400">Director / Lead</span>
                  </button>
                  <button
                    onClick={() => setCurrentUserRole('cast')}
                    className={`p-2.5 rounded-xl border text-left transition ${
                      currentUserRole === 'cast' ? 'bg-[#2E7D32]/20 border-[#2E7D32] text-white' : 'bg-black/20 border-white/10 text-gray-400'
                    }`}
                  >
                    <span className="font-bold block">Sarah Jenkins</span>
                    <span className="text-[10px] text-gray-400">Cast / Performer</span>
                  </button>
                </div>
              </div>

              {/* Design System Reference Specs */}
              <div className="bg-[#171620] border border-white/10 rounded-2xl p-4 text-xs space-y-2 text-gray-400 leading-relaxed">
                <div className="font-bold text-white flex items-center gap-1.5">
                  <Theater className="w-4 h-4 text-[#881337]" />
                  Stitch Architectural Specs
                </div>
                <p>
                  Palette: Warm Off-White Canvas (<code className="text-gray-200">#FAF8FF</code>), Deep Charcoal Typography (<code className="text-gray-200">#131B2E</code>), Velvet Crimson (<code className="text-gray-200">#881337</code>), and Slate Blue accents (<code className="text-gray-200">#475569</code>).
                </p>
              </div>
            </div>

            {/* Right Column: Handheld Mobile Device Frame */}
            <div className="lg:col-span-8 flex justify-center">
              <div className="w-full max-w-[405px] h-[835px] bg-[#222129] border-[10px] border-[#2C2A34] rounded-[50px] shadow-2xl overflow-hidden flex flex-col relative select-none">
                
                {/* Phone Status Bar */}
                <div className={`${isDark ? 'bg-[#181720] text-gray-300' : 'bg-[#FAF8FF] text-gray-700'} px-6 pt-3 pb-1 flex justify-between items-center text-[11px] font-semibold border-b ${isDark ? 'border-white/5' : 'border-black/5'}`}>
                  <span>9:41</span>
                  <div className="w-20 h-4 bg-black/80 rounded-full mx-auto" />
                  <div className="flex items-center gap-1.5">
                    <span>5G</span>
                    <div className="w-4 h-2.5 border border-current rounded-xs p-0.5">
                      <div className="w-full h-full bg-current rounded-2xs" />
                    </div>
                  </div>
                </div>

                {/* Stitch Global Header Bar */}
                <div className={`${isDark ? 'bg-[#181720] border-white/10' : 'bg-[#FAF8FF]/95 border-[#EAE8EE]'} px-4 py-2.5 border-b flex items-center justify-between backdrop-blur-md sticky top-0 z-30`}>
                  <div className="flex items-center gap-2">
                    {['production_details', 'create_event'].includes(phoneScreen) && (
                      <button
                        onClick={() => setPhoneScreen('home')}
                        className="w-8 h-8 rounded-lg flex items-center justify-center hover:bg-black/5 text-[#131B2E] mr-1"
                      >
                        ←
                      </button>
                    )}
                    <div className="w-7 h-7 rounded-lg bg-[#881337] flex items-center justify-center text-white shadow-xs">
                      <Theater className="w-4 h-4" />
                    </div>
                    <div>
                      <div className="text-xs font-bold tracking-tight text-[#881337] leading-none">StageSync</div>
                      <div className="text-[10px] text-[#574144] font-medium leading-none mt-0.5">
                        {phoneScreen === 'home' ? 'Home' : phoneScreen === 'schedule' ? 'Schedule' : phoneScreen === 'productions' ? 'Productions' : phoneScreen === 'auditions' ? 'Auditions' : 'Production Deck'}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <button className="w-8 h-8 rounded-full flex items-center justify-center text-[#574144] hover:bg-black/5 relative">
                      <Bell className="w-4 h-4" />
                      <span className="w-1.5 h-1.5 rounded-full bg-[#881337] absolute top-1.5 right-1.5" />
                    </button>
                    <button
                      onClick={() => setPhoneScreen('profile')}
                      className="w-7 h-7 rounded-full overflow-hidden border border-black/10 active:scale-95 transition"
                    >
                      <img
                        src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80"
                        alt="Profile"
                        className="w-full h-full object-cover"
                      />
                    </button>
                  </div>
                </div>

                {/* Mobile Viewport Body */}
                <div className={`flex-1 overflow-y-auto ${phoneBg} p-4 space-y-4`}>
                  
                  {/* ==================== 1. STITCH HOME SCREEN ==================== */}
                  {phoneScreen === 'home' && (
                    <div className="space-y-4">
                      {/* Editorial Header */}
                      <div className="pt-1">
                        <div className="flex items-center justify-between text-[10px] font-bold uppercase tracking-wider text-[#881337] mb-1">
                          <span className="flex items-center gap-1">
                            <span className="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse" />
                            Live Production Deck
                          </span>
                          <span className="text-[#574144]">Week 3 • Tech Block</span>
                        </div>
                        <h2 className="text-2xl font-bold tracking-tight text-[#131B2E] font-serif leading-tight">
                          Good morning,<br />Ananya
                        </h2>
                        <p className="text-xs text-[#574144] mt-1">
                          Here&apos;s what&apos;s happening across your productions today.
                        </p>
                      </div>

                      {/* 3 Compact Dashboard Metric Cards */}
                      <div className="grid grid-cols-3 gap-2">
                        <div className={`p-2.5 rounded-xl border ${surfaceWhite}`}>
                          <div className="flex items-center justify-between text-[10px] font-bold uppercase tracking-wider text-[#881337]">
                            <span>Active</span>
                            <Theater className="w-3 h-3 text-[#881337]" />
                          </div>
                          <div className="text-xl font-bold text-[#131B2E] mt-1">2</div>
                          <div className="text-[10px] text-[#574144]">Productions</div>
                        </div>

                        <div className={`p-2.5 rounded-xl border ${surfaceWhite}`}>
                          <div className="flex items-center justify-between text-[10px] font-bold uppercase tracking-wider text-amber-600">
                            <span>Today</span>
                            <Calendar className="w-3 h-3 text-amber-600" />
                          </div>
                          <div className="text-xl font-bold text-[#131B2E] mt-1">5</div>
                          <div className="text-[10px] text-[#574144]">Upcoming Events</div>
                        </div>

                        <div className={`p-2.5 rounded-xl border ${surfaceWhite}`}>
                          <div className="flex items-center justify-between text-[10px] font-bold uppercase tracking-wider text-slate-600">
                            <span>Roster</span>
                            <Users className="w-3 h-3 text-slate-600" />
                          </div>
                          <div className="text-xl font-bold text-[#131B2E] mt-1">12</div>
                          <div className="text-[10px] text-[#574144]">Cast Members</div>
                        </div>
                      </div>

                      {/* Notification / Cue Check Confirmed Callout */}
                      <div className={`p-3 rounded-xl border flex items-start gap-3 ${surfaceWhite} bg-purple-50/30`}>
                        <div className="w-8 h-8 rounded-lg bg-purple-100 flex items-center justify-center text-[#881337] shrink-0">
                          <Bell className="w-4 h-4" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center justify-between">
                            <span className="text-xs font-bold text-[#131B2E]">Stage 1 Cue Check Confirmed</span>
                            <span className="text-[10px] text-gray-400">12m ago</span>
                          </div>
                          <p className="text-[11px] text-[#574144] line-clamp-2 mt-0.5">
                            Lighting levels for Hamlet Act II Scene 1 locked with lighting desk. All wireless lav packs verified.
                          </p>
                        </div>
                      </div>

                      {/* Upcoming Events Section */}
                      <div className="space-y-2">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <h3 className="text-sm font-bold text-[#131B2E]">Upcoming Events</h3>
                            <span className="text-[10px] px-2 py-0.5 rounded-full bg-purple-100 text-[#881337] font-semibold">Today</span>
                          </div>
                          <button
                            onClick={() => setPhoneScreen('schedule')}
                            className="text-xs text-[#881337] font-semibold hover:underline flex items-center gap-0.5"
                          >
                            <span>View Run Sheet</span>
                            <ChevronRight className="w-3 h-3" />
                          </button>
                        </div>

                        {/* Event Card 1: Hamlet */}
                        <div className={`p-3.5 rounded-xl border relative overflow-hidden ${surfaceWhite}`}>
                          <div className="absolute left-0 top-0 bottom-0 w-1.5 bg-[#881337]" />
                          <div className="pl-1 space-y-1.5">
                            <div className="flex items-center justify-between">
                              <span className="text-xs font-bold text-[#131B2E]">10:00 AM – 1:00 PM • 3h Run</span>
                              <span className="text-[10px] font-bold px-2 py-0.5 rounded-md bg-[#881337]/10 text-[#881337]">Rehearsal</span>
                            </div>
                            <h4 className="text-sm font-bold text-[#131B2E]">Hamlet</h4>
                            <div className="flex items-center gap-3 text-xs text-[#574144]">
                              <span className="flex items-center gap-1">
                                <MapPin className="w-3 h-3 text-[#881337]" />
                                Main Auditorium
                              </span>
                              <span>•</span>
                              <span>Full Stage Setup</span>
                            </div>
                            <div className="pt-1 flex items-center justify-between text-[11px] text-[#574144]">
                              <span>Sarah J., John S. +4 others</span>
                              <div className="flex -space-x-1.5">
                                <span className="w-5 h-5 rounded-full bg-[#881337] text-white font-bold text-[9px] flex items-center justify-center">SJ</span>
                                <span className="w-5 h-5 rounded-full bg-slate-600 text-white font-bold text-[9px] flex items-center justify-center">JS</span>
                                <span className="w-5 h-5 rounded-full bg-gray-200 text-gray-700 font-bold text-[9px] flex items-center justify-center">+4</span>
                              </div>
                            </div>
                          </div>
                        </div>

                        {/* Event Card 2: The Tempest */}
                        <div className={`p-3.5 rounded-xl border relative overflow-hidden ${surfaceWhite}`}>
                          <div className="absolute left-0 top-0 bottom-0 w-1.5 bg-blue-500" />
                          <div className="pl-1 space-y-1.5">
                            <div className="flex items-center justify-between">
                              <span className="text-xs font-bold text-[#131B2E]">2:00 PM – 3:30 PM • 90m Session</span>
                              <span className="text-[10px] font-bold px-2 py-0.5 rounded-md bg-blue-50 text-blue-700">Production Meeting</span>
                            </div>
                            <h4 className="text-sm font-bold text-[#131B2E]">The Tempest</h4>
                            <div className="flex items-center gap-3 text-xs text-[#574144]">
                              <span className="flex items-center gap-1">
                                <MapPin className="w-3 h-3 text-blue-600" />
                                Studio B
                              </span>
                              <span>•</span>
                              <span>A/V &amp; Projection Review</span>
                            </div>
                            <div className="pt-1 flex items-center justify-between text-[11px]">
                              <span className="text-[#574144]">Design Team &amp; Stage Manager</span>
                              <span className="text-[10px] font-bold px-1.5 py-0.5 rounded bg-gray-100 text-gray-600">HYBRID</span>
                            </div>
                          </div>
                        </div>
                      </div>

                      {/* Your Productions Section */}
                      <div className="space-y-2 pt-2">
                        <div className="flex items-center justify-between">
                          <div>
                            <h3 className="text-sm font-bold text-[#131B2E]">Your Productions</h3>
                            <p className="text-[10px] text-[#574144]">Current active repertory &amp; stage schedules</p>
                          </div>
                          <button
                            onClick={() => setPhoneScreen('create_event')}
                            className="text-[11px] bg-[#881337] text-white px-2.5 py-1 rounded-lg font-semibold flex items-center gap-1 shadow-xs"
                          >
                            <Plus className="w-3 h-3" /> New Event
                          </button>
                        </div>

                        {/* Rich Production Card 1: Hamlet */}
                        <div className={`p-3.5 rounded-xl border space-y-3 ${surfaceWhite}`}>
                          <div className="flex gap-3">
                            <img
                              src={INITIAL_PRODUCTIONS[0].imageURL}
                              alt="Hamlet"
                              className="w-16 h-20 object-cover rounded-lg shrink-0 border border-black/5"
                            />
                            <div className="flex-1 min-w-0 flex flex-col justify-between">
                              <div>
                                <div className="flex items-start justify-between">
                                  <span className="text-[10px] text-gray-400 font-mono">OCT 1 – OCT 20</span>
                                  <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-amber-50 text-amber-700 border border-amber-200">In Rehearsal</span>
                                </div>
                                <h4 className="text-sm font-bold text-[#131B2E]">Hamlet</h4>
                                <p className="text-[11px] text-[#574144]">Directed by Ananya Sharma</p>
                              </div>
                              <div className="text-[10px] text-gray-500">
                                12 cast members • 5 upcoming events
                              </div>
                            </div>
                          </div>

                          {/* Rehearsal Timeline Progress */}
                          <div className="bg-gray-50 rounded-lg p-2.5 space-y-1.5 border border-gray-100">
                            <div className="flex justify-between items-center text-[10px] font-bold">
                              <span className="text-[#131B2E]">Rehearsal Timeline</span>
                              <span className="text-[#881337]">Week 3 of 6 (50%)</span>
                            </div>
                            <div className="w-full bg-gray-200 h-1.5 rounded-full overflow-hidden">
                              <div className="bg-[#881337] h-full w-1/2 rounded-full" />
                            </div>
                            <div className="flex justify-between text-[9px] text-gray-500 pt-0.5">
                              <span>First Read</span>
                              <span className="font-bold text-[#881337]">Blocking</span>
                              <span>Tech Week</span>
                              <span>Opening</span>
                            </div>
                          </div>

                          <div className="pt-1 flex items-center justify-between border-t border-gray-100 text-xs">
                            <span className="text-[10px] text-gray-500 flex items-center gap-1">
                              <FileText className="w-3 h-3 text-[#881337]" /> Prompt book locked
                            </span>
                            <button
                              onClick={() => {
                                setSelectedProd(INITIAL_PRODUCTIONS[0]);
                                setPhoneScreen('production_details');
                              }}
                              className="text-xs text-[#881337] font-bold flex items-center gap-1 hover:underline"
                            >
                              Manage <ExternalLink className="w-3 h-3" />
                            </button>
                          </div>
                        </div>

                        {/* Rich Production Card 2: The Tempest */}
                        <div className={`p-3.5 rounded-xl border space-y-3 ${surfaceWhite}`}>
                          <div className="flex gap-3">
                            <img
                              src={INITIAL_PRODUCTIONS[1].imageURL}
                              alt="The Tempest"
                              className="w-16 h-20 object-cover rounded-lg shrink-0 border border-black/5"
                            />
                            <div className="flex-1 min-w-0 flex flex-col justify-between">
                              <div>
                                <div className="flex items-start justify-between">
                                  <span className="text-[10px] text-gray-400 font-mono">NOV 20 – DEC 5</span>
                                  <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-blue-50 text-blue-700 border border-blue-200">Casting &amp; Pre-pro</span>
                                </div>
                                <h4 className="text-sm font-bold text-[#131B2E]">The Tempest</h4>
                                <p className="text-[11px] text-[#574144]">Directed by Ananya Sharma</p>
                              </div>
                              <div className="text-[10px] text-gray-500">
                                8 cast members • 3 upcoming events
                              </div>
                            </div>
                          </div>

                          <div className="pt-1 flex items-center justify-between border-t border-gray-100 text-xs">
                            <span className="text-[10px] text-gray-500">Call sheet pending approval</span>
                            <button
                              onClick={() => {
                                setSelectedProd(INITIAL_PRODUCTIONS[1]);
                                setPhoneScreen('production_details');
                              }}
                              className="text-xs text-[#881337] font-bold flex items-center gap-1 hover:underline"
                            >
                              Manage <ExternalLink className="w-3 h-3" />
                            </button>
                          </div>
                        </div>
                      </div>

                      {/* Director's Blocking Log Callout */}
                      <div className="p-3 bg-red-50/50 rounded-xl border border-red-100 flex items-center justify-between text-xs">
                        <div className="flex items-center gap-2">
                          <div className="w-8 h-8 rounded-lg bg-[#881337]/10 text-[#881337] flex items-center justify-center">
                            <Edit className="w-4 h-4" />
                          </div>
                          <div>
                            <div className="font-bold text-[#131B2E]">Director&apos;s Blocking Log</div>
                            <div className="text-[10px] text-[#574144]">Record adjustments during run</div>
                          </div>
                        </div>
                        <button className="px-3 py-1 bg-white border border-gray-200 rounded-lg text-xs font-semibold text-[#881337] shadow-xs">
                          Open Pad
                        </button>
                      </div>
                    </div>
                  )}

                  {/* ==================== 2. STITCH SCHEDULE / CALLBOARD ==================== */}
                  {phoneScreen === 'schedule' && (
                    <div className="space-y-3">
                      <div className="flex justify-between items-center">
                        <div>
                          <h2 className="text-base font-bold text-[#131B2E] tracking-tight">Production Callboard</h2>
                          <p className="text-[10px] text-[#574144]">Synchronized timeline &amp; rehearsal calls</p>
                        </div>
                        <div className="flex items-center bg-gray-100 p-0.5 rounded-lg text-[10px] font-bold">
                          <span className="px-2 py-1 bg-white rounded shadow-xs text-[#131B2E]">List</span>
                          <span className="px-2 py-1 text-gray-500">Cal</span>
                        </div>
                      </div>

                      {/* Filter Chips */}
                      <div className="flex gap-1.5 overflow-x-auto pb-1 text-[11px]">
                        <button
                          onClick={() => setScheduleFilter('all')}
                          className={`px-3 py-1 rounded-full font-semibold transition ${
                            scheduleFilter === 'all' ? 'bg-[#881337] text-white' : 'bg-white border border-gray-200 text-gray-600'
                          }`}
                        >
                          All (7)
                        </button>
                        <button
                          onClick={() => setScheduleFilter('Rehearsal')}
                          className={`px-3 py-1 rounded-full font-semibold transition ${
                            scheduleFilter === 'Rehearsal' ? 'bg-[#881337] text-white' : 'bg-white border border-gray-200 text-gray-600'
                          }`}
                        >
                          Rehearsals (4)
                        </button>
                        <button
                          onClick={() => setScheduleFilter('Audition')}
                          className={`px-3 py-1 rounded-full font-semibold transition ${
                            scheduleFilter === 'Audition' ? 'bg-[#881337] text-white' : 'bg-white border border-gray-200 text-gray-600'
                          }`}
                        >
                          Auditions (2)
                        </button>
                        <button
                          onClick={() => setScheduleFilter('Performance')}
                          className={`px-3 py-1 rounded-full font-semibold transition ${
                            scheduleFilter === 'Performance' ? 'bg-[#881337] text-white' : 'bg-white border border-gray-200 text-gray-600'
                          }`}
                        >
                          Performance
                        </button>
                      </div>

                      {/* Stage Status Callout */}
                      <div className="p-2.5 rounded-xl bg-purple-50/50 border border-purple-100 flex items-center justify-between text-xs">
                        <div className="flex items-center gap-2">
                          <div className="w-6 h-6 rounded-md bg-[#881337]/10 text-[#881337] flex items-center justify-center font-bold">
                            <Theater className="w-3.5 h-3.5" />
                          </div>
                          <div>
                            <span className="font-bold text-[#131B2E]">Stage A: Dark until 10:00 AM</span>
                            <p className="text-[10px] text-[#574144]">Sound check in progress • Studio B clear</p>
                          </div>
                        </div>
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-purple-100 text-[#881337]">Live Sync</span>
                      </div>

                      {/* Timeline: TODAY • OCT 12 */}
                      <div className="space-y-3 pt-1">
                        <div className="flex items-center gap-1.5 text-[11px] font-bold text-[#881337] uppercase tracking-wider">
                          <span className="w-2 h-2 rounded-full bg-[#881337]" />
                          <span>Today • Oct 12</span>
                        </div>

                        {INITIAL_EVENTS.filter(e => e.bucket === 'TODAY').map(evt => (
                          <div key={evt.id} className={`p-3.5 rounded-xl border relative space-y-2 ${surfaceWhite}`}>
                            <div className="flex justify-between items-start">
                              <div className="flex items-center gap-1.5 text-xs text-gray-500 font-medium">
                                <Clock className="w-3.5 h-3.5 text-[#881337]" />
                                <span className="font-bold text-[#131B2E]">{evt.timeRange}</span>
                              </div>
                              <span className="text-[10px] font-bold px-2 py-0.5 rounded-md bg-[#881337]/10 text-[#881337]">
                                {evt.type}
                              </span>
                            </div>

                            <h4 className="text-sm font-bold text-[#131B2E]">{evt.title}</h4>
                            <div className="text-xs text-[#574144] flex items-center gap-3">
                              <span className="flex items-center gap-1">
                                <MapPin className="w-3 h-3 text-[#881337]" />
                                {evt.venue}
                              </span>
                              <span>•</span>
                              <span>{evt.castInfo}</span>
                            </div>

                            <div className="pt-1 flex items-center justify-between border-t border-gray-100 text-xs">
                              <div className="flex -space-x-1.5">
                                {evt.avatars.map((av, i) => (
                                  <span key={i} className="w-5 h-5 rounded-full bg-slate-700 text-white font-bold text-[9px] flex items-center justify-center ring-1 ring-white">
                                    {av}
                                  </span>
                                ))}
                              </div>
                              <span className="text-[11px] font-semibold text-[#881337] hover:underline cursor-pointer">
                                Call sheet →
                              </span>
                            </div>
                          </div>
                        ))}
                      </div>

                      {/* Timeline: TOMORROW • OCT 13 */}
                      <div className="space-y-3 pt-2">
                        <div className="flex items-center gap-1.5 text-[11px] font-bold text-gray-600 uppercase tracking-wider">
                          <span className="w-2 h-2 rounded-full bg-gray-500" />
                          <span>Tomorrow • Oct 13</span>
                        </div>

                        {INITIAL_EVENTS.filter(e => e.bucket === 'TOMORROW').map(evt => (
                          <div key={evt.id} className={`p-3.5 rounded-xl border relative space-y-2 ${surfaceWhite}`}>
                            <div className="flex justify-between items-start">
                              <div className="flex items-center gap-1.5 text-xs text-gray-500 font-medium">
                                <Clock className="w-3.5 h-3.5 text-[#881337]" />
                                <span className="font-bold text-[#131B2E]">{evt.timeRange}</span>
                              </div>
                              <span className="text-[10px] font-bold px-2 py-0.5 rounded-md bg-purple-100 text-[#881337]">
                                {evt.type}
                              </span>
                            </div>

                            <h4 className="text-sm font-bold text-[#131B2E]">{evt.title}</h4>
                            <div className="text-xs text-[#574144] flex items-center gap-3">
                              <span className="flex items-center gap-1">
                                <MapPin className="w-3 h-3 text-[#881337]" />
                                {evt.venue}
                              </span>
                              <span>•</span>
                              <span>{evt.castInfo}</span>
                            </div>

                            {/* Live Conflict Warning Card */}
                            {evt.conflictWarning && (
                              <div className="p-2.5 rounded-lg bg-red-50 border border-red-200 text-red-900 space-y-1">
                                <div className="flex items-center justify-between text-xs font-bold">
                                  <span className="flex items-center gap-1 text-red-700">
                                    <AlertTriangle className="w-3.5 h-3.5" />
                                    1 Conflict detected
                                  </span>
                                  <button
                                    onClick={() => setConflictModalOpen(true)}
                                    className="px-2 py-0.5 rounded bg-red-700 text-white text-[10px] font-bold shadow-xs hover:bg-red-800"
                                  >
                                    Resolve
                                  </button>
                                </div>
                                <p className="text-[11px] leading-tight text-red-800">
                                  {evt.conflictWarning}
                                </p>
                              </div>
                            )}

                            <div className="pt-1 text-[10px] text-gray-400">
                              {evt.notes}
                            </div>
                          </div>
                        ))}
                      </div>

                      {/* Floating Add Event Button */}
                      <button
                        onClick={() => setPhoneScreen('create_event')}
                        className="w-full py-3 rounded-xl bg-[#881337] hover:bg-[#6e0f2b] text-white font-bold text-xs flex items-center justify-center gap-1.5 shadow-md transition"
                      >
                        <Plus className="w-4 h-4" /> Add Event
                      </button>
                    </div>
                  )}

                  {/* ==================== 3. STITCH PRODUCTIONS SCREEN ==================== */}
                  {phoneScreen === 'productions' && (
                    <div className="space-y-3">
                      {/* Search Bar */}
                      <div className="relative">
                        <Search className="w-4 h-4 absolute left-3 top-2.5 text-gray-400" />
                        <input
                          type="text"
                          placeholder="Search productions, plays, directors..."
                          className="w-full pl-9 pr-3 py-2 rounded-xl border border-gray-200 bg-white text-xs text-[#131B2E] placeholder:text-gray-400 focus:outline-none focus:border-[#881337]"
                        />
                      </div>

                      {/* Filter Pills */}
                      <div className="flex gap-2 text-xs">
                        <button className="px-3 py-1 rounded-full bg-[#881337] text-white font-bold">Active (2)</button>
                        <button className="px-3 py-1 rounded-full bg-gray-100 text-gray-600 font-medium">Upcoming (1)</button>
                        <button className="px-3 py-1 rounded-full bg-gray-100 text-gray-400 font-medium">Archived (0)</button>
                      </div>

                      {/* Header */}
                      <div className="flex items-center justify-between pt-1">
                        <div className="flex items-center gap-2">
                          <h3 className="text-sm font-bold text-[#131B2E]">All Active Productions</h3>
                          <span className="text-[10px] bg-gray-100 px-1.5 py-0.5 rounded text-gray-600 font-bold">2</span>
                        </div>
                        <button
                          onClick={() => setPhoneScreen('create_event')}
                          className="text-xs bg-[#881337] text-white px-2.5 py-1 rounded-lg font-bold flex items-center gap-1"
                        >
                          <Plus className="w-3.5 h-3.5" /> New Production
                        </button>
                      </div>

                      {/* Production Cards */}
                      <div className="space-y-3">
                        {INITIAL_PRODUCTIONS.map(prod => (
                          <div
                            key={prod.id}
                            className={`rounded-xl border overflow-hidden ${surfaceWhite}`}
                          >
                            {/* Poster Banner */}
                            <div className="h-32 w-full relative">
                              <img src={prod.imageURL} alt={prod.title} className="w-full h-full object-cover" />
                              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/30 to-transparent" />
                              <span className="absolute top-2.5 right-2.5 text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#881337] text-white backdrop-blur">
                                {prod.statusTag}
                              </span>
                              <div className="absolute bottom-2 left-3 text-white text-[10px] font-mono">
                                📅 {prod.dates}
                              </div>
                              <div className="absolute bottom-2 right-3 text-white text-[10px] font-mono bg-black/40 px-1.5 rounded">
                                {prod.code}
                              </div>
                            </div>

                            <div className="p-3.5 space-y-2.5">
                              <div>
                                <h4 className="text-base font-bold text-[#131B2E]">{prod.title}</h4>
                                <p className="text-xs text-[#574144]">{prod.playwright}</p>
                              </div>

                              <div className="grid grid-cols-2 gap-2 text-xs text-[#574144]">
                                <div>Dir. {prod.director}</div>
                                <div>{prod.venue}</div>
                              </div>

                              {/* Key Metrics Chips */}
                              <div className="flex flex-wrap gap-1.5 text-[10px]">
                                <span className="px-2 py-0.5 rounded-full bg-gray-100 text-gray-700 font-semibold">
                                  👥 {prod.castCount} Cast
                                </span>
                                <span className="px-2 py-0.5 rounded-full bg-gray-100 text-gray-700 font-semibold">
                                  🔔 {prod.upcomingEventsCount} Calls Left
                                </span>
                                <span className="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 font-semibold border border-emerald-200">
                                  ✓ {prod.attendanceRate}
                                </span>
                              </div>

                              {/* Milestones Box */}
                              <div className="bg-gray-50 rounded-lg p-2.5 space-y-1 text-xs">
                                <div className="flex justify-between items-center font-bold text-[10px] text-gray-500 uppercase">
                                  <span>Upcoming Milestones</span>
                                  <span className="text-[#881337]">2 pending</span>
                                </div>
                                {prod.milestones.map((m, idx) => (
                                  <div key={idx} className="flex justify-between items-center text-[11px]">
                                    <span className="flex items-center gap-1.5 text-[#131B2E]">
                                      <span className={`w-1.5 h-1.5 rounded-full ${m.active ? 'bg-[#881337]' : 'bg-gray-400'}`} />
                                      {m.name}
                                    </span>
                                    <span className="text-gray-400 font-mono">{m.date}</span>
                                  </div>
                                ))}
                              </div>

                              {/* Card Footer */}
                              <div className="pt-1 flex items-center justify-between border-t border-gray-100">
                                <div className="flex -space-x-1.5">
                                  <span className="w-6 h-6 rounded-full bg-[#881337] text-white font-bold text-[10px] flex items-center justify-center">AS</span>
                                  <span className="w-6 h-6 rounded-full bg-slate-600 text-white font-bold text-[10px] flex items-center justify-center">KL</span>
                                  <span className="w-6 h-6 rounded-full bg-gray-200 text-gray-700 font-bold text-[10px] flex items-center justify-center">+10</span>
                                </div>
                                <button
                                  onClick={() => {
                                    setSelectedProd(prod);
                                    setPhoneScreen('production_details');
                                  }}
                                  className="text-xs text-[#881337] font-bold flex items-center gap-1 hover:underline"
                                >
                                  Manage Production <ArrowRight className="w-3.5 h-3.5" />
                                </button>
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* ==================== 4. STITCH PRODUCTION DETAILS ==================== */}
                  {phoneScreen === 'production_details' && (
                    <div className="space-y-3">
                      {/* Hero Header Card */}
                      <div className={`p-4 rounded-xl border space-y-2 ${surfaceWhite}`}>
                        <div className="flex items-center justify-between">
                          <span className="text-[10px] font-bold uppercase tracking-wider text-[#881337]">
                            Active Production • {selectedProd.venue}
                          </span>
                          <span className="text-xs font-bold text-gray-400">⋮</span>
                        </div>
                        <h2 className="text-xl font-bold text-[#131B2E] font-serif">{selectedProd.title}</h2>
                        <p className="text-xs text-[#574144]">{selectedProd.playwright}</p>

                        <div className="bg-gray-50 rounded-lg p-2.5 grid grid-cols-2 gap-2 text-xs border border-gray-100">
                          <div>
                            <span className="text-[10px] text-gray-400 block">Run Dates</span>
                            <span className="font-bold text-[#131B2E]">{selectedProd.dates}</span>
                          </div>
                          <div>
                            <span className="text-[10px] text-gray-400 block">Director</span>
                            <span className="font-bold text-[#131B2E]">{selectedProd.director}</span>
                          </div>
                        </div>
                      </div>

                      {/* 3 Tabs: Roles & Cast, Schedule & Calls, Auditions */}
                      <div className="grid grid-cols-3 gap-1 bg-gray-100 p-1 rounded-xl text-xs font-bold text-center">
                        <button
                          onClick={() => setProdDetailsTab('roles')}
                          className={`py-1.5 rounded-lg transition ${
                            prodDetailsTab === 'roles' ? 'bg-white text-[#131B2E] shadow-xs' : 'text-gray-500'
                          }`}
                        >
                          Roles &amp; Cast
                        </button>
                        <button
                          onClick={() => setProdDetailsTab('schedule')}
                          className={`py-1.5 rounded-lg transition ${
                            prodDetailsTab === 'schedule' ? 'bg-white text-[#131B2E] shadow-xs' : 'text-gray-500'
                          }`}
                        >
                          Schedule
                        </button>
                        <button
                          onClick={() => setProdDetailsTab('auditions')}
                          className={`py-1.5 rounded-lg transition ${
                            prodDetailsTab === 'auditions' ? 'bg-white text-[#131B2E] shadow-xs' : 'text-gray-500'
                          }`}
                        >
                          Auditions (8)
                        </button>
                      </div>

                      {/* Tab 1: Roles */}
                      {prodDetailsTab === 'roles' && (
                        <div className="space-y-2">
                          <div className="flex items-center justify-between">
                            <span className="text-xs font-bold text-[#131B2E]">Character Roster (14 Roles)</span>
                            <button className="text-[11px] bg-[#881337] text-white px-2 py-0.5 rounded-lg font-bold flex items-center gap-1 shadow-xs">
                              <Plus className="w-3 h-3" /> Add Role
                            </button>
                          </div>

                          <div className="space-y-2">
                            {INITIAL_ROLES.map(r => (
                              <div key={r.id} className={`p-3 rounded-xl border space-y-1.5 ${surfaceWhite}`}>
                                <div className="flex items-start justify-between">
                                  <div className="flex items-center gap-2.5">
                                    <div className="w-8 h-8 rounded-full bg-red-100 text-[#881337] font-bold text-xs flex items-center justify-center">
                                      {r.character.slice(0, 2).toUpperCase()}
                                    </div>
                                    <div>
                                      <div className="flex items-center gap-1.5">
                                        <h4 className="text-xs font-bold text-[#131B2E]">{r.character}</h4>
                                        <span className="text-[10px] px-1.5 rounded bg-gray-100 text-gray-600">{r.type}</span>
                                      </div>
                                      <div className="text-xs text-[#574144]">
                                        {r.assigned ? r.actorName : <span className="text-amber-600 font-semibold">Unassigned</span>}
                                      </div>
                                    </div>
                                  </div>

                                  <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                                    r.assigned ? 'bg-emerald-50 text-emerald-700' : 'bg-blue-50 text-blue-700'
                                  }`}>
                                    {r.assigned ? '• Assigned' : '• Open Audition'}
                                  </span>
                                </div>

                                {r.conflict && (
                                  <div className="p-2 rounded bg-red-50 border border-red-200 text-red-700 text-[11px] flex items-center justify-between">
                                    <span className="flex items-center gap-1 truncate">
                                      <AlertTriangle className="w-3.5 h-3.5 shrink-0" />
                                      {r.conflict}
                                    </span>
                                    <button
                                      onClick={() => setConflictModalOpen(true)}
                                      className="text-[10px] font-bold text-red-800 underline ml-2"
                                    >
                                      Resolve
                                    </button>
                                  </div>
                                )}

                                {!r.assigned && (
                                  <div className="pt-1 flex items-center justify-between text-xs">
                                    <span className="text-[11px] text-gray-500">{r.candidatesCount} Candidates shortlisted</span>
                                    <button className="px-2.5 py-1 bg-[#881337] text-white rounded text-xs font-bold shadow-xs">
                                      Assign Cast
                                    </button>
                                  </div>
                                )}
                              </div>
                            ))}
                          </div>
                        </div>
                      )}

                      {/* Tab 2: Schedule */}
                      {prodDetailsTab === 'schedule' && (
                        <div className="space-y-2">
                          <span className="text-xs font-bold text-[#131B2E]">Scheduled Calls for {selectedProd.title}</span>
                          <div className="p-3 bg-gray-50 rounded-xl border border-gray-200 text-xs text-gray-600 space-y-2">
                            <div>• Oct 12, 10:00 AM – Act II Blocking (Main Auditorium)</div>
                            <div>• Oct 13, 6:00 PM – Full Run Act I &amp; II (Main Auditorium)</div>
                            <div>• Oct 18, 7:00 PM – Final Dress Rehearsal</div>
                          </div>
                        </div>
                      )}

                      {/* Tab 3: Auditions */}
                      {prodDetailsTab === 'auditions' && (
                        <div className="space-y-2">
                          <span className="text-xs font-bold text-[#131B2E]">Audition Sessions</span>
                          <div className={`p-3 rounded-xl border space-y-2 ${surfaceWhite}`}>
                            <div className="flex justify-between items-center">
                              <span className="text-xs font-bold text-[#131B2E]">Open Audition: Claudius &amp; Ensemble</span>
                              <span className="text-[10px] px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 font-bold">Open</span>
                            </div>
                            <p className="text-xs text-[#574144]">September 20 • 3:00 PM Call • Room 201</p>
                            <button
                              onClick={() => setPhoneScreen('auditions')}
                              className="w-full py-1.5 rounded-lg bg-[#881337] text-white font-bold text-xs shadow-xs"
                            >
                              Go to Auditions Board →
                            </button>
                          </div>
                        </div>
                      )}
                    </div>
                  )}

                  {/* ==================== 5. STITCH AUDITIONS SCREEN ==================== */}
                  {phoneScreen === 'auditions' && (
                    <div className="space-y-3">
                      <div className="flex items-center justify-between">
                        <div>
                          <h2 className="text-lg font-bold text-[#131B2E]">Auditions</h2>
                          <p className="text-[10px] text-[#574144]">Casting calls &amp; active sign-up rosters</p>
                        </div>
                        <button className="w-8 h-8 rounded-xl bg-gray-100 flex items-center justify-center text-gray-700">
                          <SlidersHorizontal className="w-4 h-4" />
                        </button>
                      </div>

                      {/* Segmented Filter Switch: Upcoming vs My Signups */}
                      <div className="grid grid-cols-2 gap-1 bg-gray-100 p-1 rounded-xl text-xs font-bold text-center">
                        <button
                          onClick={() => setAuditionsTab('upcoming')}
                          className={`py-1.5 rounded-lg transition ${
                            auditionsTab === 'upcoming' ? 'bg-white text-[#131B2E] shadow-xs' : 'text-gray-500'
                          }`}
                        >
                          Upcoming
                        </button>
                        <button
                          onClick={() => setAuditionsTab('my_signups')}
                          className={`py-1.5 rounded-lg transition flex items-center justify-center gap-1 ${
                            auditionsTab === 'my_signups' ? 'bg-white text-[#131B2E] shadow-xs' : 'text-gray-500'
                          }`}
                        >
                          <span>My Signups</span>
                          <span className="px-1.5 py-0.2 rounded-full bg-[#881337] text-white text-[10px]">1</span>
                        </button>
                      </div>

                      {/* Quick Callout Banner */}
                      <div className="p-2.5 rounded-xl bg-gray-100 flex items-center justify-between text-xs">
                        <div className="flex items-center gap-2">
                          <Info className="w-4 h-4 text-[#881337]" />
                          <span className="text-[11px] text-[#131B2E]">Sides &amp; cold readings released 24h before call time.</span>
                        </div>
                        <span className="text-[10px] font-bold text-[#881337] cursor-pointer">Rules</span>
                      </div>

                      {/* Card 1: Hamlet (Director Perspective) */}
                      <div className={`p-3.5 rounded-xl border relative overflow-hidden space-y-2.5 ${surfaceWhite}`}>
                        <div className="absolute left-0 top-0 bottom-0 w-1.5 bg-[#881337]" />
                        <div className="pl-1 space-y-2">
                          <div className="flex items-start justify-between">
                            <div className="flex items-center gap-2">
                              <div className="w-10 h-12 rounded-lg bg-gray-100 flex flex-col items-center justify-center font-bold">
                                <span className="text-[9px] text-[#881337]">SEP</span>
                                <span className="text-sm text-[#131B2E]">20</span>
                              </div>
                              <div>
                                <div className="flex items-center gap-1.5">
                                  <h4 className="text-sm font-bold text-[#131B2E]">Hamlet</h4>
                                  <span className="text-[9px] px-1.5 py-0.5 rounded bg-gray-100 text-gray-600">Mainstage</span>
                                </div>
                                <span className="text-xs text-[#574144]">3:00 PM Call</span>
                              </div>
                            </div>
                            <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-amber-50 text-amber-800 border border-amber-200">
                              • Director View
                            </span>
                          </div>

                          {/* Room Banner */}
                          <div className="h-20 rounded-lg bg-slate-900 relative overflow-hidden flex items-end p-2 text-white">
                            <img
                              src="https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?w=600&auto=format&fit=crop&q=80"
                              alt="Room 201"
                              className="absolute inset-0 w-full h-full object-cover opacity-50"
                            />
                            <div className="relative text-xs font-bold flex items-center gap-1">
                              <MapPin className="w-3 h-3 text-red-400" /> Room 201 • Rehearsal Wing B
                            </div>
                          </div>

                          {/* Grid Specs */}
                          <div className="grid grid-cols-2 gap-2 text-xs">
                            <div className="p-2 rounded-lg bg-gray-50">
                              <span className="text-[10px] text-gray-500 block">Role Openings</span>
                              <span className="font-bold text-[#131B2E]">Claudius, Ensemble</span>
                            </div>
                            <div className="p-2 rounded-lg bg-gray-50">
                              <span className="text-[10px] text-gray-500 block">Submissions</span>
                              <span className="font-bold text-[#131B2E]">8 applicants</span>
                            </div>
                          </div>

                          <div className="flex items-center justify-between text-xs pt-1">
                            <div className="flex -space-x-1.5">
                              {['EL', 'MK', 'JS', '+5'].map((x, i) => (
                                <span key={i} className="w-6 h-6 rounded-full bg-slate-700 text-white font-bold text-[9px] flex items-center justify-center ring-1 ring-white">
                                  {x}
                                </span>
                              ))}
                            </div>
                            <span className="text-[10px] text-gray-500">Round 1 Cut-off 18:00</span>
                          </div>

                          <button className="w-full py-2 bg-[#881337] hover:bg-[#6e0f2b] text-white rounded-lg text-xs font-bold flex items-center justify-center gap-1 shadow-xs">
                            View Applicants <ArrowRight className="w-3.5 h-3.5" />
                          </button>
                        </div>
                      </div>

                      {/* Card 2: The Tempest (Performer Perspective with Toggle) */}
                      <div className={`p-3.5 rounded-xl border relative overflow-hidden space-y-2.5 ${surfaceWhite}`}>
                        <div className="absolute left-0 top-0 bottom-0 w-1.5 bg-amber-500" />
                        <div className="pl-1 space-y-2">
                          <div className="flex items-start justify-between">
                            <div className="flex items-center gap-2">
                              <div className="w-10 h-12 rounded-lg bg-gray-100 flex flex-col items-center justify-center font-bold">
                                <span className="text-[9px] text-amber-700">OCT</span>
                                <span className="text-sm text-[#131B2E]">13</span>
                              </div>
                              <div>
                                <div className="flex items-center gap-1.5">
                                  <h4 className="text-sm font-bold text-[#131B2E]">The Tempest</h4>
                                  <span className="text-[9px] px-1.5 py-0.5 rounded bg-blue-50 text-blue-700">Shakespeare Lab</span>
                                </div>
                                <span className="text-xs text-[#574144]">11:00 AM – 1:30 PM</span>
                              </div>
                            </div>
                            <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-purple-50 text-purple-700">
                              Audition Slot: 11:45 AM
                            </span>
                          </div>

                          <div className="grid grid-cols-2 gap-2 text-xs">
                            <div className="p-2 rounded-lg bg-gray-50">
                              <span className="text-[10px] text-gray-500 block">Open Roles</span>
                              <span className="font-bold text-[#131B2E]">Caliban &amp; Ariel</span>
                            </div>
                            <div className="p-2 rounded-lg bg-gray-50">
                              <span className="text-[10px] text-gray-500 block">Prepared Material</span>
                              <span className="font-bold text-[#131B2E]">2-Min Monologue</span>
                            </div>
                          </div>

                          {/* Cast Member Toggle Button State */}
                          <button
                            onClick={() => setTempestSignedUp(!tempestSignedUp)}
                            className={`w-full py-2.5 rounded-lg text-xs font-bold flex items-center justify-center gap-1.5 transition shadow-xs ${
                              tempestSignedUp
                                ? 'bg-purple-100 text-[#881337] border border-purple-200'
                                : 'bg-[#881337] text-white hover:bg-[#6e0f2b]'
                            }`}
                          >
                            <CheckCircle className="w-4 h-4" />
                            <span>{tempestSignedUp ? '✓ Signed Up' : 'Sign Up for Audition'}</span>
                          </button>
                          <p className="text-[10px] text-gray-400 text-center">
                            {tempestSignedUp ? 'Confirmed for 11:45 AM slot • Tap to manage or withdraw' : 'Tap to register for Caliban/Ariel call'}
                          </p>
                        </div>
                      </div>

                      {/* General Guidelines Card */}
                      <div className="p-3 bg-gray-50 rounded-xl border border-gray-200 text-xs space-y-1">
                        <div className="flex justify-between items-center font-bold text-[#131B2E]">
                          <span>General Audition Guidelines</span>
                          <span className="text-[10px] text-[#881337]">Equity &amp; Non-Eq</span>
                        </div>
                        <p className="text-[11px] text-gray-600">
                          Please arrive at least 15 minutes ahead of your reserved time slot. Bring two physical headshots with updated resumes.
                        </p>
                      </div>
                    </div>
                  )}

                  {/* ==================== 6. STITCH CREATE EVENT SCREEN ==================== */}
                  {phoneScreen === 'create_event' && (
                    <div className="space-y-3">
                      <div>
                        <div className="flex items-center justify-between text-[10px] text-gray-500 uppercase tracking-wider font-bold">
                          <span>Production Operations</span>
                          <span className="text-[#881337] flex items-center gap-1">
                            <span className="w-1.5 h-1.5 rounded-full bg-[#881337] animate-pulse" />
                            Drafting Call
                          </span>
                        </div>
                        <h2 className="text-xl font-bold text-[#131B2E] font-serif">Create Event</h2>
                        <p className="text-xs text-[#574144]">Log an official rehearsal call or callboard event.</p>
                      </div>

                      {/* Visual Banner */}
                      <div className="h-24 rounded-xl relative overflow-hidden bg-slate-900 flex items-end p-3 text-white">
                        <img
                          src="https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?w=600&auto=format&fit=crop&q=80"
                          alt="Banner"
                          className="absolute inset-0 w-full h-full object-cover opacity-60"
                        />
                        <div className="relative">
                          <span className="text-[10px] uppercase font-bold text-red-300">Active Repertory</span>
                          <div className="text-sm font-bold">Hamlet (Oct 1 – Oct 20)</div>
                        </div>
                      </div>

                      {/* Event Type Grid */}
                      <div className="space-y-1 text-xs">
                        <label className="font-bold text-[#131B2E]">Event Type</label>
                        <div className="grid grid-cols-2 gap-1.5 p-1 bg-gray-100 rounded-xl font-semibold">
                          {(['Rehearsal', 'Performance', 'Audition', 'Prod Meeting'] as const).map(t => (
                            <button
                              key={t}
                              type="button"
                              onClick={() => setFormEventType(t)}
                              className={`py-1.5 rounded-lg text-xs transition ${
                                formEventType === t ? 'bg-white text-[#881337] shadow-xs' : 'text-gray-500 hover:text-gray-900'
                              }`}
                            >
                              {t}
                            </button>
                          ))}
                        </div>
                      </div>

                      {/* Production Dropdown */}
                      <div className="space-y-1 text-xs">
                        <label className="font-bold text-[#131B2E]">Production</label>
                        <select
                          value={formProd}
                          onChange={e => setFormProd(e.target.value)}
                          className="w-full p-2.5 rounded-xl border border-gray-200 bg-white text-xs text-[#131B2E]"
                        >
                          <option>Hamlet (Oct 1 – Oct 20)</option>
                          <option>The Tempest (Nov 20 – Dec 5)</option>
                        </select>
                      </div>

                      {/* Date */}
                      <div className="space-y-1 text-xs">
                        <label className="font-bold text-[#131B2E]">Date</label>
                        <input
                          type="text"
                          value={formDate}
                          onChange={e => setFormDate(e.target.value)}
                          className="w-full p-2.5 rounded-xl border border-gray-200 bg-white text-xs text-[#131B2E]"
                        />
                      </div>

                      {/* Time Row */}
                      <div className="grid grid-cols-2 gap-2 text-xs">
                        <div>
                          <label className="font-bold text-[#131B2E] block mb-1">Start Time</label>
                          <input
                            type="time"
                            value={formStartTime}
                            onChange={e => setFormStartTime(e.target.value)}
                            className="w-full p-2 rounded-xl border border-gray-200 bg-white font-mono text-xs"
                          />
                        </div>
                        <div>
                          <label className="font-bold text-[#131B2E] block mb-1">End Time</label>
                          <input
                            type="time"
                            value={formEndTime}
                            onChange={e => setFormEndTime(e.target.value)}
                            className="w-full p-2 rounded-xl border border-gray-200 bg-white font-mono text-xs"
                          />
                        </div>
                      </div>

                      {/* Venue */}
                      <div className="space-y-1 text-xs">
                        <div className="flex justify-between">
                          <label className="font-bold text-[#131B2E]">Venue</label>
                          <span className="text-[10px] text-emerald-700 font-bold">• Available</span>
                        </div>
                        <select
                          value={formVenue}
                          onChange={e => setFormVenue(e.target.value)}
                          className="w-full p-2.5 rounded-xl border border-gray-200 bg-white text-xs text-[#131B2E]"
                        >
                          <option value="Main Auditorium">Main Auditorium (Hamlet&apos;s Stage)</option>
                          <option value="Studio B">Studio B</option>
                          <option value="Green Room">Green Room Annex</option>
                        </select>
                      </div>

                      {/* Cast Chips */}
                      <div className="space-y-1 text-xs">
                        <div className="flex justify-between">
                          <label className="font-bold text-[#131B2E]">Called Cast Members (3)</label>
                          <span className="text-[10px] text-gray-500">Act 1 Roster</span>
                        </div>
                        <div className="flex flex-wrap gap-1.5 pt-1">
                          {formCast.map((c, i) => (
                            <span key={i} className="px-2.5 py-1 rounded-full bg-purple-50 text-[#881337] border border-purple-200 text-[11px] font-semibold flex items-center gap-1">
                              ✓ {c}
                            </span>
                          ))}
                        </div>
                      </div>

                      {/* Notes */}
                      <div className="space-y-1 text-xs">
                        <label className="font-bold text-[#131B2E]">Rehearsal &amp; Callboard Notes</label>
                        <textarea
                          rows={2}
                          value={formNotes}
                          onChange={e => setFormNotes(e.target.value)}
                          className="w-full p-2.5 rounded-xl border border-gray-200 bg-white text-xs text-[#131B2E] resize-none"
                        />
                      </div>

                      {/* Immediate Sync Notice */}
                      <div className="p-2.5 bg-gray-50 rounded-xl border border-gray-200 text-[11px] text-gray-600 flex items-center gap-2">
                        <Bell className="w-4 h-4 text-[#881337] shrink-0" />
                        <span>Creating this call will notify summoned cast and update their personal rehearsal calendar.</span>
                      </div>

                      {/* Submit */}
                      <div className="pt-2 space-y-2">
                        <button
                          type="button"
                          onClick={() => {
                            if (!checkConflict()) {
                              alert('Event created successfully with zero conflicts!');
                              setPhoneScreen('schedule');
                            }
                          }}
                          className="w-full py-3 bg-[#881337] hover:bg-[#6e0f2b] text-white rounded-xl text-xs font-bold shadow-md transition"
                        >
                          Create Event
                        </button>
                        <button
                          type="button"
                          onClick={() => setPhoneScreen('home')}
                          className="w-full py-2 text-xs font-semibold text-gray-600 hover:text-black"
                        >
                          Cancel
                        </button>
                      </div>
                    </div>
                  )}

                  {/* ==================== 7. STITCH PROFILE SCREEN ==================== */}
                  {phoneScreen === 'profile' && (
                    <div className="space-y-4">
                      {/* Profile Card */}
                      <div className={`p-4 rounded-xl border space-y-3 ${surfaceWhite}`}>
                        <div className="flex items-center gap-3">
                          <div className="relative">
                            <img
                              src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&auto=format&fit=crop&q=80"
                              alt="Ananya Sharma"
                              className="w-14 h-14 rounded-full object-cover shadow-sm"
                            />
                            <span className="w-3.5 h-3.5 rounded-full bg-emerald-500 border-2 border-white absolute bottom-0 right-0" />
                          </div>
                          <div>
                            <div className="flex items-center gap-2">
                              <h3 className="text-base font-bold text-[#131B2E]">Ananya Sharma</h3>
                              <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-purple-100 text-[#881337]">Director</span>
                            </div>
                            <p className="text-xs text-[#574144]">ananya@example.com</p>
                            <p className="text-[10px] text-gray-500 mt-0.5">Winter Repertory Season &apos;25</p>
                          </div>
                        </div>
                      </div>

                      {/* Next Call Banner */}
                      <div className="p-3 bg-purple-50 rounded-xl border border-purple-100 flex items-center justify-between text-xs">
                        <div className="flex items-center gap-2">
                          <div className="w-8 h-8 rounded-lg bg-[#881337]/10 text-[#881337] flex items-center justify-center font-bold">
                            <Bell className="w-4 h-4" />
                          </div>
                          <div>
                            <div className="font-bold text-[#131B2E]">Next Call: Tech Cue Run</div>
                            <div className="text-[10px] text-[#574144]">Main Stage • 14:30 today</div>
                          </div>
                        </div>
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-purple-200 text-[#881337]">Active Callboard</span>
                      </div>

                      {/* Appearance / Theme Selector */}
                      <div className={`p-4 rounded-xl border space-y-2.5 ${surfaceWhite}`}>
                        <div className="flex items-center justify-between">
                          <span className="text-xs font-bold text-[#131B2E]">Appearance</span>
                          <span className="text-[10px] text-gray-500">Stage Optimized</span>
                        </div>
                        <p className="text-[11px] text-[#574144]">
                          Adjust brightness for high-contrast backstage navigation or daylit production meetings.
                        </p>

                        <div className="grid grid-cols-3 gap-1.5 p-1 bg-gray-100 rounded-xl text-xs font-semibold">
                          <button
                            onClick={() => setThemeMode('light')}
                            className={`py-2 rounded-lg flex items-center justify-center gap-1.5 transition ${
                              themeMode === 'light' ? 'bg-white text-[#131B2E] shadow-sm font-bold' : 'text-gray-500'
                            }`}
                          >
                            <Sun className="w-3.5 h-3.5 text-amber-500" /> Light
                          </button>
                          <button
                            onClick={() => setThemeMode('dark')}
                            className={`py-2 rounded-lg flex items-center justify-center gap-1.5 transition ${
                              themeMode === 'dark' ? 'bg-white text-[#131B2E] shadow-sm font-bold' : 'text-gray-500'
                            }`}
                          >
                            <Moon className="w-3.5 h-3.5 text-indigo-500" /> Dark
                          </button>
                          <button
                            onClick={() => setThemeMode('system')}
                            className={`py-2 rounded-lg flex items-center justify-center gap-1.5 transition ${
                              themeMode === 'system' ? 'bg-white text-[#131B2E] shadow-sm font-bold' : 'text-gray-500'
                            }`}
                          >
                            <Monitor className="w-3.5 h-3.5 text-gray-600" /> System
                          </button>
                        </div>
                      </div>

                      {/* Production Settings Group */}
                      <div className={`rounded-xl border overflow-hidden ${surfaceWhite} divide-y divide-gray-100 text-xs`}>
                        <div className="p-3 font-bold text-gray-400 text-[10px] uppercase tracking-wider">
                          Production Settings
                        </div>
                        <div className="p-3 flex items-center justify-between hover:bg-gray-50 cursor-pointer">
                          <div>
                            <div className="font-bold text-[#131B2E]">Notifications</div>
                            <div className="text-[10px] text-gray-500">Rehearsal notices, callboard updates</div>
                          </div>
                          <ChevronRight className="w-4 h-4 text-gray-400" />
                        </div>
                        <div className="p-3 flex items-center justify-between hover:bg-gray-50 cursor-pointer">
                          <div>
                            <div className="font-bold text-[#131B2E]">Change Password</div>
                            <div className="text-[10px] text-gray-500">Security, 2FA &amp; keycard authorization</div>
                          </div>
                          <ChevronRight className="w-4 h-4 text-gray-400" />
                        </div>
                        <div className="p-3 flex items-center justify-between hover:bg-gray-50 cursor-pointer">
                          <div>
                            <div className="font-bold text-[#131B2E]">About StageSync</div>
                            <div className="text-[10px] text-gray-500">v1.0 Production Release</div>
                          </div>
                          <span className="text-[10px] font-mono bg-gray-100 px-1.5 py-0.5 rounded text-gray-600">v1.0</span>
                        </div>
                      </div>

                      {/* Active Company Credentials */}
                      <div className="p-4 rounded-xl bg-[#881337] text-white space-y-1 shadow-md">
                        <div className="flex justify-between items-center text-[10px] font-semibold text-red-200 uppercase tracking-wider">
                          <span>Active Company Credentials</span>
                          <CheckCircle className="w-3.5 h-3.5" />
                        </div>
                        <div className="text-base font-bold">Royal Lyceum Theatre</div>
                        <p className="text-[11px] text-red-100">
                          Equity Contract #ST-8842 • Full Script &amp; Cue Edit Access
                        </p>
                      </div>

                      {/* Log Out Button */}
                      <button
                        onClick={() => alert('Signed out of StageSync')}
                        className="w-full py-2.5 rounded-xl border border-red-200 bg-white text-red-600 font-bold text-xs hover:bg-red-50 transition shadow-xs"
                      >
                        Log Out
                      </button>
                    </div>
                  )}

                </div>

                {/* Bottom Navigation Bar (Matching Stitch Design) */}
                <div className={`${isDark ? 'bg-[#181720] border-white/10' : 'bg-white border-[#EAE8EE]'} border-t px-4 py-2 flex justify-around items-center`}>
                  <button
                    onClick={() => setPhoneScreen('home')}
                    className={`flex flex-col items-center gap-0.5 text-[10px] transition ${
                      phoneScreen === 'home' ? 'text-[#881337] font-bold' : 'text-gray-400 hover:text-gray-700'
                    }`}
                  >
                    <Theater className="w-4 h-4" />
                    <span>Home</span>
                  </button>
                  <button
                    onClick={() => setPhoneScreen('schedule')}
                    className={`flex flex-col items-center gap-0.5 text-[10px] transition ${
                      phoneScreen === 'schedule' ? 'text-[#881337] font-bold' : 'text-gray-400 hover:text-gray-700'
                    }`}
                  >
                    <Calendar className="w-4 h-4" />
                    <span>Schedule</span>
                  </button>
                  <button
                    onClick={() => setPhoneScreen('productions')}
                    className={`flex flex-col items-center gap-0.5 text-[10px] transition ${
                      ['productions', 'production_details'].includes(phoneScreen) ? 'text-[#881337] font-bold' : 'text-gray-400 hover:text-gray-700'
                    }`}
                  >
                    <Layers className="w-4 h-4" />
                    <span>Productions</span>
                  </button>
                  <button
                    onClick={() => setPhoneScreen('profile')}
                    className={`flex flex-col items-center gap-0.5 text-[10px] transition ${
                      phoneScreen === 'profile' ? 'text-[#881337] font-bold' : 'text-gray-400 hover:text-gray-700'
                    }`}
                  >
                    <UserCheck className="w-4 h-4" />
                    <span>Profile</span>
                  </button>
                </div>

              </div>
            </div>
          </div>
        )}

        {/* Tab 2: Conflict Lab */}
        {activeTab === 'conflict_lab' && (
          <div className="max-w-4xl mx-auto space-y-6">
            <div className="bg-[#171620] border border-white/10 rounded-2xl p-6 shadow-xl space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-lg font-bold text-white flex items-center gap-2">
                    <AlertTriangle className="w-5 h-5 text-amber-400" />
                    StageSync Conflict Protection Engine Lab
                  </h2>
                  <p className="text-xs text-gray-400 mt-1">
                    Strict overlap math: <code className="text-amber-300 font-mono">startA &lt; endB &amp;&amp; endA &gt; startB</code> across venues and actors.
                  </p>
                </div>
                <button
                  onClick={() => setConflictModalOpen(true)}
                  className="px-4 py-2 bg-[#881337] text-white rounded-xl text-xs font-bold shadow-md hover:bg-[#6e0f2b]"
                >
                  Trigger Stitch Conflict Dialog
                </button>
              </div>

              <div className="p-4 bg-black/40 rounded-xl border border-white/5 text-xs space-y-2">
                <span className="font-bold text-white">Active Rehearsal in System:</span>
                <div className="flex justify-between items-center text-gray-300">
                  <span>Hamlet — Rehearsal</span>
                  <span className="font-mono text-amber-400">18:00 – 20:00 (Main Auditorium)</span>
                  <span>Cast: Sarah Jenkins, John Smith</span>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Tab 3: Code Browser */}
        {activeTab === 'code_browser' && (
          <div className="max-w-4xl mx-auto bg-[#171620] border border-white/10 rounded-2xl p-6 shadow-xl space-y-4">
            <h2 className="text-lg font-bold text-white flex items-center gap-2">
              <FileCode className="w-5 h-5 text-[#881337]" />
              Production Flutter Engine Specifications
            </h2>
            <p className="text-xs text-gray-400">
              The Dart files in <code className="text-[#FFB2BD]">lib/</code> contain the actual GoRouter, Provider, Firestore security rules, and conflict detection services.
            </p>
          </div>
        )}

        {/* Tab 4: Unit Test Suite */}
        {activeTab === 'test_runner' && (
          <div className="max-w-4xl mx-auto bg-[#171620] border border-white/10 rounded-2xl p-6 shadow-xl space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-bold text-white flex items-center gap-2">
                <ShieldCheck className="w-5 h-5 text-emerald-400" />
                Conflict &amp; Authorization Test Runner
              </h2>
              <span className="text-xs font-bold px-3 py-1 bg-emerald-950/60 border border-emerald-500/50 text-emerald-400 rounded-full">
                10 Passed • 0 Failed
              </span>
            </div>
          </div>
        )}
      </main>

      {/* ==================== STITCH VENUE CONFLICT DIALOG MODAL ==================== */}
      {conflictModalOpen && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl border border-gray-200 overflow-hidden text-[#131B2E] space-y-3">
            {/* Header */}
            <div className="p-4 pb-0 flex items-start justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-red-100 text-red-600 flex items-center justify-center shrink-0">
                  <AlertTriangle className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-bold text-[#131B2E]">{conflictData.title}</h3>
                  <p className="text-xs text-gray-500">{conflictData.subtitle}</p>
                </div>
              </div>
              <button
                onClick={() => setConflictModalOpen(false)}
                className="w-7 h-7 rounded-full flex items-center justify-center text-gray-400 hover:bg-gray-100"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="px-4 space-y-3">
              {/* Venue Banner */}
              <div className="p-3 bg-gray-50 rounded-xl flex items-center gap-3 border border-gray-100">
                <div className="w-12 h-12 rounded-lg bg-slate-900 text-white flex items-center justify-center text-xs font-bold shrink-0">
                  STAGE
                </div>
                <div>
                  <span className="text-[10px] font-bold text-[#881337] uppercase">Venue Booked</span>
                  <div className="text-sm font-bold text-[#131B2E]">Main Auditorium</div>
                  <div className="text-[10px] text-gray-500">Capacity: 450 Seats • Proscenium</div>
                </div>
              </div>

              {/* Conflicting Production Details */}
              <div className="p-3.5 rounded-xl border border-gray-100 bg-white shadow-xs space-y-2 text-xs">
                <div className="flex justify-between items-center text-[10px] font-bold">
                  <span className="text-gray-400 uppercase">Conflicting Production</span>
                  <span className="px-2 py-0.5 rounded-full bg-gray-100 text-gray-700">Confirmed</span>
                </div>
                <div>
                  <div className="text-sm font-bold text-[#131B2E]">{conflictData.conflictingProduction}</div>
                  <div className="text-xs text-[#574144]">Production: {conflictData.productionSeries}</div>
                </div>

                <div className="space-y-1 pt-1 text-xs">
                  <div className="flex items-center gap-2 text-red-600 font-semibold">
                    <Clock className="w-3.5 h-3.5" />
                    <span>{conflictData.timeRange}</span>
                  </div>
                  <div className="flex items-center gap-2 text-gray-600">
                    <MapPin className="w-3.5 h-3.5" />
                    <span>{conflictData.venue}</span>
                  </div>
                  <div className="flex items-center gap-2 text-gray-600">
                    <UserCheck className="w-3.5 h-3.5" />
                    <span>Booked by: <strong className="text-gray-800">{conflictData.bookedBy}</strong></span>
                  </div>
                </div>
              </div>

              {/* Resolution Guidance Box */}
              <div className="p-2.5 rounded-xl bg-red-50 border border-red-100 flex items-start gap-2 text-xs text-red-900">
                <Info className="w-4 h-4 text-red-600 shrink-0 mt-0.5" />
                <p className="leading-tight text-[11px]">{conflictData.suggestion}</p>
              </div>
            </div>

            {/* Modal Actions */}
            <div className="p-4 pt-2 flex gap-2 border-t border-gray-100">
              <button
                onClick={() => setConflictModalOpen(false)}
                className="flex-1 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold rounded-xl text-xs transition"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  setConflictModalOpen(false);
                  setPhoneScreen('create_event');
                }}
                className="flex-1 py-2.5 bg-[#881337] hover:bg-[#6e0f2b] text-white font-bold rounded-xl text-xs shadow-md transition"
              >
                Edit Event
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
