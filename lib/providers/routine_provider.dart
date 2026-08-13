import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/routine.dart';
import '../services/supabase_service.dart';
import '../utils/user_facing_error.dart';

/// Provider for managing routine state and operations
class RoutineProvider extends ChangeNotifier {
  @visibleForTesting
  static SupabaseService Function() defaultSupabase = () =>
      SupabaseService.instance;

  @visibleForTesting
  static String? Function() defaultCurrentUserId = () =>
      FirebaseAuth.instance.currentUser?.uid;

  final SupabaseService _supabase;
  final String? Function() _currentUserId;

  RoutineProvider({
    SupabaseService? supabase,
    String? Function()? currentUserId,
  }) : _supabase = supabase ?? defaultSupabase(),
       _currentUserId = currentUserId ?? defaultCurrentUserId;

  // State
  List<Routine> _routines = [];
  List<Routine> _curatedRoutines = [];
  List<Routine> _aiRoutines = [];
  List<UserRoutine> _userRoutines = [];
  Routine? _selectedRoutine;
  bool _isLoading = false;
  bool _isLoadingUserRoutines = false;
  bool _isGenerating = false;
  String? _error;

  // Getters
  List<Routine> get routines => _routines;
  List<Routine> get curatedRoutines => _curatedRoutines;
  List<Routine> get aiRoutines => _aiRoutines;
  List<UserRoutine> get userRoutines => _userRoutines;
  Routine? get selectedRoutine => _selectedRoutine;
  bool get isLoading => _isLoading;
  bool get isLoadingUserRoutines => _isLoadingUserRoutines;
  bool get isGenerating => _isGenerating;
  String? get error => _error;

  /// Load all published routines from Supabase
  Future<void> loadRoutines({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final published = await _supabase.getPublishedRoutines();

      // Merge in the signed-in user's private routines (created_by = uid, is_published = false)
      // so generated routines persist in the Library tab across restarts.
      final uid = _currentUserId();
      final mine = (uid == null || uid.isEmpty)
          ? <Routine>[]
          : await _supabase.getUserCreatedRoutines(userId: uid);

      // Prefer user-created routines over published ones if the same ID ever appears in both sets.
      final byId = <String, Routine>{};
      for (final r in [...published, ...mine]) {
        byId[r.id] = r;
      }
      _routines = byId.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _curatedRoutines = _routines.where((r) => r.isCurated).toList();
      _aiRoutines = _routines.where((r) => !r.isCurated).toList();
    } catch (e, st) {
      debugPrint('loadRoutines failed: $e');
      debugPrint('$st');
      _error = toUserFriendlyMessage(
        e,
        fallbackOf: (l10n) => l10n.errorLoadRoutines,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load routines filtered by category
  Future<void> loadRoutinesByCategory(RoutineCategory category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _routines = await _supabase.getPublishedRoutines(category: category);
      _curatedRoutines = _routines.where((r) => r.isCurated).toList();
      _aiRoutines = _routines.where((r) => !r.isCurated).toList();
    } catch (e, st) {
      debugPrint('loadRoutinesByCategory failed: $e');
      debugPrint('$st');
      _error = toUserFriendlyMessage(
        e,
        fallbackOf: (l10n) => l10n.errorLoadRoutines,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user's saved routines
  Future<void> loadUserRoutines(String userId) async {
    if (_isLoadingUserRoutines) return;
    _isLoadingUserRoutines = true;
    notifyListeners();
    try {
      _userRoutines = await _supabase.getUserRoutines(userId);
    } catch (e, st) {
      debugPrint('loadUserRoutines failed: $e');
      debugPrint('$st');
      _error = toUserFriendlyMessage(
        e,
        fallbackOf: (l10n) => l10n.errorLoadSavedRoutines,
      );
    } finally {
      _isLoadingUserRoutines = false;
      notifyListeners();
    }
  }

  /// Select a routine to view/play
  void selectRoutine(Routine routine) {
    _selectedRoutine = routine;
    notifyListeners();
  }

  /// Clear selected routine
  void clearSelection() {
    _selectedRoutine = null;
    notifyListeners();
  }

  /// Generate a new AI routine based on user request.
  ///
  /// Comes back flagged as pre-existing when the server recognised the request
  /// as one this user already has, in which case the original is returned.
  Future<GeneratedRoutine?> generateRoutine({
    required String request,
    int? durationMinutes,
    RoutineDifficulty? difficulty,
    List<String>? equipment,
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _supabase.generateRoutineOnServer(
        request: request,
        durationMinutes: durationMinutes ?? 15,
        difficulty: difficulty ?? RoutineDifficulty.medium,
        equipment: equipment ?? const ['None'],
      );

      // An existing routine may already be in these lists, and listing it twice
      // is the clutter this is meant to prevent.
      _addOrReplace(_aiRoutines, result.routine);
      _addOrReplace(_routines, result.routine);

      notifyListeners();
      return result;
    } catch (e, st) {
      debugPrint('generateRoutine failed: $e');
      debugPrint('$st');
      _error = toUserFriendlyMessage(
        e,
        fallbackOf: (l10n) => l10n.errorGenerateRoutine,
      );
      return null;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void _addOrReplace(List<Routine> list, Routine routine) {
    final index = list.indexWhere((existing) => existing.id == routine.id);
    if (index >= 0) {
      list[index] = routine;
      return;
    }
    list.insert(0, routine);
  }

  /// Save a routine to user's library
  Future<bool> saveRoutine(String userId, String routineId) async {
    try {
      final userRoutine = await _supabase.saveRoutine(userId, routineId);
      _userRoutines.insert(0, userRoutine);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to save routine: $e');
      return false;
    }
  }

  /// Remove a routine from user's library
  Future<bool> unsaveRoutine(String userId, String routineId) async {
    try {
      await _supabase.unsaveRoutine(userId, routineId);
      _userRoutines.removeWhere((ur) => ur.routineId == routineId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to unsave routine: $e');
      return false;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String userRoutineId) async {
    final index = _userRoutines.indexWhere((ur) => ur.id == userRoutineId);
    if (index == -1) return;

    final current = _userRoutines[index];
    final newFavorite = !current.isFavorite;

    try {
      await _supabase.toggleFavorite(userRoutineId, newFavorite);
      // Update local state
      _userRoutines[index] = UserRoutine(
        id: current.id,
        userId: current.userId,
        routineId: current.routineId,
        savedAt: current.savedAt,
        lastPlayedAt: current.lastPlayedAt,
        timesCompleted: current.timesCompleted,
        isFavorite: newFavorite,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to toggle favorite: $e');
    }
  }

  /// Toggle favorite status by routine id (convenience helper for UI)
  Future<void> toggleFavoriteByRoutineId(String routineId) async {
    final ur = getUserRoutine(routineId);
    if (ur == null) return;
    await toggleFavorite(ur.id);
  }

  /// Record routine completion.
  ///
  /// Throws if it could not be saved. A workout that quietly fails to count is
  /// worse than one that reports the problem: the player offers a retry, and
  /// the streak, workout total and level are all derived from this write, so
  /// swallowing the failure means the user's progress silently stops moving.
  Future<void> recordCompletion(String userRoutineId) async {
    try {
      await _supabase.recordCompletion(userRoutineId);
      // Refresh user routines to get updated count
      final index = _userRoutines.indexWhere((ur) => ur.id == userRoutineId);
      if (index != -1) {
        final current = _userRoutines[index];
        _userRoutines[index] = UserRoutine(
          id: current.id,
          userId: current.userId,
          routineId: current.routineId,
          savedAt: current.savedAt,
          lastPlayedAt: DateTime.now(),
          timesCompleted: current.timesCompleted + 1,
          isFavorite: current.isFavorite,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to record completion: $e');
      rethrow;
    }
  }

  /// Record a completion for a routine id (creates a user_routines row if needed).
  /// This is what makes streak/level real.
  Future<void> recordCompletionForRoutine({
    required String userId,
    required String routineId,
  }) async {
    // Ensure saved row exists so completion can be tracked.
    var ur = getUserRoutine(routineId);
    if (ur == null) {
      try {
        final created = await _supabase.saveRoutine(userId, routineId);
        _userRoutines.insert(0, created);
        ur = created;
        notifyListeners();
      } catch (e) {
        // The row may already exist (unique constraint), so reload before
        // giving up.
        debugPrint('Could not save routine before recording completion: $e');
        await loadUserRoutines(userId);
        ur = getUserRoutine(routineId);
      }
    }

    if (ur == null) {
      throw StateError(
        'Could not add this routine to your library, so the completion was '
        'not recorded',
      );
    }
    await recordCompletion(ur.id);
  }

  /// Check if a routine is saved by the user
  bool isRoutineSaved(String routineId) {
    return _userRoutines.any((ur) => ur.routineId == routineId);
  }

  /// Get user routine by routine ID
  UserRoutine? getUserRoutine(String routineId) {
    try {
      return _userRoutines.firstWhere((ur) => ur.routineId == routineId);
    } catch (_) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
