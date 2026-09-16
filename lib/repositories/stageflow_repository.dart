import '../models/production.dart';
import '../models/event.dart';
import '../models/cast_member.dart';
import '../models/venue.dart';
import '../models/conflict.dart';
import '../models/audition.dart';

abstract class IStageFlowRepository {
  Future<List<Production>> getProductions();
  Future<Production?> getProductionById(String id);
  Future<List<ScheduleEvent>> getEvents();
  Future<ScheduleEvent?> getEventById(String id);
  Future<List<CastMember>> getCastMembers(String productionId);
  Future<List<Venue>> getVenues();
  Future<List<ScheduleConflict>> getConflicts();
  Future<bool> resolveConflict(String conflictId, String resolution);
  Future<List<AuditionCandidate>> getAuditions();
  Future<void> addEvent(ScheduleEvent event);
  Future<void> addProduction(Production production);
}

class MockStageFlowRepository implements IStageFlowRepository {
  static final MockStageFlowRepository _instance = MockStageFlowRepository._internal();
  factory MockStageFlowRepository() => _instance;

  MockStageFlowRepository._internal() {
    _initMockData();
  }

  late List<Production> _productions;
  late List<ScheduleEvent> _events;
  late List<CastMember> _castMembers;
  late List<Venue> _venues;
  late List<ScheduleConflict> _conflicts;
  late List<AuditionCandidate> _auditions;

  void _initMockData() {
    _productions = [
      const Production(
        id: 'hamlet-1',
        title: 'Hamlet',
        status: 'In Rehearsal',
        director: 'Eleanor Vance',
        openingDate: 'Oct 15, 2026',
        venue: 'Main Stage',
        totalCast: 18,
        totalCues: 142,
        progress: 0.65,
        imageUrl: 'https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?auto=format&fit=crop&w=600&q=80',
        description: 'Tragedy by William Shakespeare. Set in a modern corporate kingdom, exploring revenge, madness, and corruption.',
      ),
      const Production(
        id: 'macbeth-1',
        title: 'Macbeth',
        status: 'Tech Week',
        director: 'Julian Croft',
        openingDate: 'Nov 02, 2026',
        venue: 'Main Stage',
        totalCast: 14,
        totalCues: 98,
        progress: 0.85,
        imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=600&q=80',
        description: 'A dark tale of ambition, prophecy, and blood-soaked tyranny in medieval Scotland.',
      ),
      const Production(
        id: 'tempest-1',
        title: 'The Tempest',
        status: 'Pre-Production',
        director: 'Miriam Hastings',
        openingDate: 'Dec 10, 2026',
        venue: 'Studio Theatre',
        totalCast: 12,
        totalCues: 64,
        progress: 0.30,
        imageUrl: 'https://images.unsplash.com/photo-1469488865564-c2de10f69f96?auto=format&fit=crop&w=600&q=80',
        description: 'An enchanted island, storms, sorcery, and reconciliation in Shakespeare\'s final romance.',
      ),
      const Production(
        id: 'romeo-1',
        title: 'Romeo & Juliet',
        status: 'Auditions Open',
        director: 'Arjun Patel',
        openingDate: 'Jan 20, 2027',
        venue: 'Black Box Theatre',
        totalCast: 20,
        totalCues: 110,
        progress: 0.15,
        imageUrl: 'https://images.unsplash.com/photo-1518834107812-67b0b7c58434?auto=format&fit=crop&w=600&q=80',
        description: 'Feuding families in Fair Verona set the stage for star-crossed lovers.',
      ),
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _events = [
      ScheduleEvent(
        id: 'evt-1',
        title: 'Act 1 Scene 2 Rehearsal',
        productionId: 'hamlet-1',
        productionTitle: 'Hamlet',
        type: 'Rehearsal',
        startTime: today.add(const Duration(hours: 14)), // 2:00 PM
        endTime: today.add(const Duration(hours: 16)), // 4:00 PM
        venueName: 'Main Stage',
        requiredRoles: ['Hamlet', 'Claudius', 'Gertrude'],
        requiredCast: ['Eleanor Vance', 'Arjun Patel', 'Miriam Hastings'],
        hasConflict: true,
        status: 'Conflict',
        notes: 'Stage conflict detected with Macbeth tech setup.',
      ),
      ScheduleEvent(
        id: 'evt-2',
        title: 'Macbeth Lighting Focus & Sound Cue Run',
        productionId: 'macbeth-1',
        productionTitle: 'Macbeth',
        type: 'Tech Call',
        startTime: today.add(const Duration(hours: 14, minutes: 30)), // 2:30 PM
        endTime: today.add(const Duration(hours: 17)), // 5:00 PM
        venueName: 'Main Stage',
        requiredRoles: ['Stage Manager', 'Lighting Designer', 'Macbeth'],
        requiredCast: ['Julian Croft', 'Leo Harris', 'Eleanor Vance'],
        hasConflict: true,
        status: 'Conflict',
        notes: 'Requires exclusive access to Main Stage soundboard.',
      ),
      ScheduleEvent(
        id: 'evt-3',
        title: 'Ophelia Costume Fitting',
        productionId: 'hamlet-1',
        productionTitle: 'Hamlet',
        type: 'Fitting',
        startTime: today.add(const Duration(hours: 10)), // 10:00 AM
        endTime: today.add(const Duration(hours: 11, minutes: 30)), // 11:30 AM
        venueName: 'Rehearsal Room A',
        requiredRoles: ['Ophelia', 'Costume Head'],
        requiredCast: ['Miriam Hastings'],
        hasConflict: false,
        status: 'Confirmed',
        notes: 'Final gown adjustments and movement check.',
      ),
      ScheduleEvent(
        id: 'evt-4',
        title: 'The Tempest Vocal Warmup & Table Read',
        productionId: 'tempest-1',
        productionTitle: 'The Tempest',
        type: 'Rehearsal',
        startTime: today.add(const Duration(hours: 11)), // 11:00 AM
        endTime: today.add(const Duration(hours: 13)), // 1:00 PM
        venueName: 'Rehearsal Room B',
        requiredRoles: ['Prospero', 'Ariel', 'Caliban'],
        requiredCast: ['Leo Harris', 'Julian Croft'],
        hasConflict: false,
        status: 'Confirmed',
        notes: 'Focus on verse speaking and projection.',
      ),
    ];

    _castMembers = [
      const CastMember(
        id: 'cast-1',
        name: 'Eleanor Vance',
        role: 'Hamlet / Director',
        productionId: 'hamlet-1',
        email: 'eleanor.vance@stageflow.org',
        phone: '+1 (555) 234-5678',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
        status: 'On Stage',
        isAvailable: true,
      ),
      const CastMember(
        id: 'cast-2',
        name: 'Arjun Patel',
        role: 'Claudius',
        productionId: 'hamlet-1',
        email: 'arjun.patel@stageflow.org',
        phone: '+1 (555) 345-6789',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        status: 'Confirmed',
        isAvailable: true,
      ),
      const CastMember(
        id: 'cast-3',
        name: 'Julian Croft',
        role: 'Polonius / Director',
        productionId: 'hamlet-1',
        email: 'julian.croft@stageflow.org',
        phone: '+1 (555) 456-7890',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
        status: 'Called Away',
        isAvailable: false,
      ),
      const CastMember(
        id: 'cast-4',
        name: 'Miriam Hastings',
        role: 'Gertrude / Ophelia',
        productionId: 'hamlet-1',
        email: 'miriam.h@stageflow.org',
        phone: '+1 (555) 567-8901',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
        status: 'Confirmed',
        isAvailable: true,
      ),
      const CastMember(
        id: 'cast-5',
        name: 'Leo Harris',
        role: 'Laertes / Understudy',
        productionId: 'hamlet-1',
        email: 'leo.harris@stageflow.org',
        phone: '+1 (555) 678-9012',
        avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=300&q=80',
        status: 'Understudy',
        isAvailable: true,
      ),
    ];

    _venues = [
      const Venue(
        id: 'ven-1',
        name: 'Main Stage',
        capacity: 450,
        location: 'Building A - Main Hall',
        status: 'Conflict',
        currentBooking: 'Double Booking: Hamlet vs Macbeth',
        techSpecs: ['Proscenium Arch', 'Fly System', '48-Ch Lighting Console', 'Dolby Surround'],
        imageUrl: 'https://images.unsplash.com/photo-1469488865564-c2de10f69f96?auto=format&fit=crop&w=600&q=80',
      ),
      const Venue(
        id: 'ven-2',
        name: 'Studio Theatre',
        capacity: 120,
        location: 'Building B - Level 2',
        status: 'Available',
        currentBooking: 'Free until 4:00 PM',
        techSpecs: ['Flexible Seating', 'LED Grid Rig', 'Acoustic Panels'],
        imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=600&q=80',
      ),
      const Venue(
        id: 'ven-3',
        name: 'Rehearsal Room A',
        capacity: 40,
        location: 'Building A - Lower Level',
        status: 'Occupied',
        currentBooking: 'Hamlet Costume Fitting (10:00 - 11:30 AM)',
        techSpecs: ['Sprung Wood Floor', 'Full Mirror Wall', 'Upright Piano'],
        imageUrl: 'https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?auto=format&fit=crop&w=600&q=80',
      ),
      const Venue(
        id: 'ven-4',
        name: 'Rehearsal Room B',
        capacity: 35,
        location: 'Building A - Lower Level',
        status: 'Available',
        currentBooking: 'Free for booking',
        techSpecs: ['Soundproof Insulation', 'Portable AV Rack', 'Rehearsal Blocks'],
        imageUrl: 'https://images.unsplash.com/photo-1518834107812-67b0b7c58434?auto=format&fit=crop&w=600&q=80',
      ),
    ];

    _conflicts = [
      ScheduleConflict(
        id: 'conf-1',
        title: 'Main Stage Double Booking',
        type: 'Venue Double Booking',
        who: 'Hamlet Cast ↔ Macbeth Tech Crew',
        what: 'Main Stage Auditorium requested by two productions simultaneously',
        when: 'Today, 2:00 PM - 4:00 PM',
        where: 'Main Stage Auditorium',
        primaryProduction: 'Hamlet',
        conflictingProduction: 'Macbeth',
        primaryEventTitle: 'Act 1 Scene 2 Rehearsal',
        conflictingEventTitle: 'Macbeth Lighting Focus & Sound Cue Run',
        resolutionOptions: [
          'Relocate Macbeth Tech Run to Studio Theatre',
          'Shift Hamlet Rehearsal to Rehearsal Room A',
          'Adjust Macbeth Tech Run to start at 4:15 PM',
        ],
        isResolved: false,
      ),
      ScheduleConflict(
        id: 'conf-2',
        title: 'Cast Double Booking: Eleanor Vance',
        type: 'Cast Double Booking',
        who: 'Eleanor Vance',
        what: 'Required as Lead Director in Hamlet & Actor call in Macbeth',
        when: 'Today, 2:30 PM - 4:00 PM',
        where: 'Main Stage / Rehearsal Room A',
        primaryProduction: 'Hamlet',
        conflictingProduction: 'Macbeth',
        primaryEventTitle: 'Act 1 Scene 2 Directing',
        conflictingEventTitle: 'Macbeth Act 2 Scene 3 Call',
        resolutionOptions: [
          'Substitute Understudy Leo Harris in Macbeth',
          'Reschedule Hamlet Directing session to tomorrow',
        ],
        isResolved: false,
      ),
    ];

    _auditions = [
      const AuditionCandidate(
        id: 'aud-1',
        candidateName: 'Clara Oswald',
        roleApplied: 'Juliet Capulet',
        productionTitle: 'Romeo & Juliet',
        timeSlot: 'Slot #4 - 10:30 AM',
        status: 'Called Back',
        headshotUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
        rating: 4.8,
        directorNotes: 'Exceptional emotional range in Act 2 monologue. Strong chemistry with Romeo candidates.',
        phone: '+1 (555) 901-2345',
        email: 'clara.o@acting.com',
      ),
      const AuditionCandidate(
        id: 'aud-2',
        candidateName: 'Marcus Vance',
        roleApplied: 'Romeo Montague',
        productionTitle: 'Romeo & Juliet',
        timeSlot: 'Slot #7 - 11:45 AM',
        status: 'Under Review',
        headshotUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        rating: 4.2,
        directorNotes: 'Good stage presence, needs work on Shakespearean diction.',
        phone: '+1 (555) 890-1234',
        email: 'marcus.v@acting.com',
      ),
      const AuditionCandidate(
        id: 'aud-3',
        candidateName: 'Siddharth Rao',
        roleApplied: 'Mercutio',
        productionTitle: 'Romeo & Juliet',
        timeSlot: 'Slot #9 - 2:00 PM',
        status: 'Cast',
        headshotUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
        rating: 5.0,
        directorNotes: 'Brilliant comedic timing and swordplay experience!',
        phone: '+1 (555) 789-0123',
        email: 'siddharth.r@acting.com',
      ),
    ];
  }

  @override
  Future<List<Production>> getProductions() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _productions;
  }

  @override
  Future<Production?> getProductionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _productions.firstWhere((p) => p.id == id);
    } catch (_) {
      return _productions.first;
    }
  }

  @override
  Future<List<ScheduleEvent>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _events;
  }

  @override
  Future<ScheduleEvent?> getEventById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return _events.first;
    }
  }

  @override
  Future<List<CastMember>> getCastMembers(String productionId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _castMembers;
  }

  @override
  Future<List<Venue>> getVenues() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _venues;
  }

  @override
  Future<List<ScheduleConflict>> getConflicts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _conflicts;
  }

  @override
  Future<bool> resolveConflict(String conflictId, String resolution) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _conflicts.indexWhere((c) => c.id == conflictId);
    if (index != -1) {
      _conflicts[index].isResolved = true;
    }
    // Update venue status
    final venueIndex = _venues.indexWhere((v) => v.id == 'ven-1');
    if (venueIndex != -1) {
      _venues[venueIndex] = Venue(
        id: _venues[venueIndex].id,
        name: _venues[venueIndex].name,
        capacity: _venues[venueIndex].capacity,
        location: _venues[venueIndex].location,
        status: 'Available',
        currentBooking: 'Hamlet Act 1 Scene 2 Rehearsal (2:00 PM - 4:00 PM)',
        techSpecs: _venues[venueIndex].techSpecs,
        imageUrl: _venues[venueIndex].imageUrl,
      );
    }
    // Update events
    for (int i = 0; i < _events.length; i++) {
      if (_events[i].hasConflict) {
        _events[i] = ScheduleEvent(
          id: _events[i].id,
          title: _events[i].title,
          productionId: _events[i].productionId,
          productionTitle: _events[i].productionTitle,
          type: _events[i].type,
          startTime: _events[i].startTime,
          endTime: _events[i].endTime,
          venueName: _events[i].id == 'evt-2' ? 'Studio Theatre' : 'Main Stage',
          requiredRoles: _events[i].requiredRoles,
          requiredCast: _events[i].requiredCast,
          hasConflict: false,
          status: 'Confirmed',
          notes: 'Conflict resolved: ${_events[i].id == 'evt-2' ? 'Moved to Studio Theatre' : 'Confirmed on Main Stage'}',
        );
      }
    }
    return true;
  }

  @override
  Future<List<AuditionCandidate>> getAuditions() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _auditions;
  }

  @override
  Future<void> addEvent(ScheduleEvent event) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _events.insert(0, event);
  }

  @override
  Future<void> addProduction(Production production) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _productions.insert(0, production);
  }
}
