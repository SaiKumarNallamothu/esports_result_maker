import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class HiveService {
  static const String _tournamentsBoxName = 'tournaments_box';
  static const String _presetsBoxName = 'presets_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Hive Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TeamAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PointSystemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MatchResultAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TournamentAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(MatchAdapter());
    }

    // Open boxes
    await Hive.openBox<Tournament>(_tournamentsBoxName);
    await Hive.openBox<PointSystem>(_presetsBoxName);
  }

  // --- Tournament CRUD ---

  Box<Tournament> get _tournamentsBox => Hive.box<Tournament>(_tournamentsBoxName);

  List<Tournament> getAllTournaments() {
    final list = _tournamentsBox.values.toList();
    // Sort by creation date descending (newest first)
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> saveTournament(Tournament tournament) async {
    await _tournamentsBox.put(tournament.id, tournament);
  }

  Future<void> deleteTournament(String id) async {
    await _tournamentsBox.delete(id);
  }

  // --- Point System Presets CRUD ---

  Box<PointSystem> get _presetsBox => Hive.box<PointSystem>(_presetsBoxName);

  List<PointSystem> getAllPresets() {
    // Return custom presets combined with default presets
    final customPresets = _presetsBox.values.toList();
    return [
      PointSystem.bgmiDefault,
      PointSystem.bgisNew,
      PointSystem.pubgDefault,
      ...customPresets,
    ];
  }

  Future<void> savePreset(PointSystem preset) async {
    await _presetsBox.put(preset.id, preset);
  }

  Future<void> deletePreset(String id) async {
    await _presetsBox.delete(id);
  }
}
