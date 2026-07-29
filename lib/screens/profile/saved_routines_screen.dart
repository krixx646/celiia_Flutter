import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/routine.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/supabase_service.dart';
import '../routines/routine_detail_screen.dart';

class SavedRoutinesScreen extends StatefulWidget {
  final bool showFavoritesOnly;
  final SupabaseService? supabase;
  final Widget Function(Routine routine)? routineDetailBuilder;

  const SavedRoutinesScreen({
    super.key,
    this.showFavoritesOnly = false,
    this.supabase,
    this.routineDetailBuilder,
  });

  @override
  State<SavedRoutinesScreen> createState() => _SavedRoutinesScreenState();
}

class _SavedRoutinesScreenState extends State<SavedRoutinesScreen> {
  late final SupabaseService _supabase;
  final Map<String, String> _titleCache = {};

  @override
  void initState() {
    super.initState();
    _supabase = widget.supabase ?? SupabaseService.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = context.read<AuthProvider>().uiState.currentUser;
      if (user == null) return;
      await context.read<RoutineProvider>().loadUserRoutines(user.uid);
    });
  }

  Future<void> _openRoutine(String routineId) async {
    final Routine? routine = await _supabase.getRoutine(routineId);
    if (!mounted) return;
    if (routine == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Routine not found')));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            widget.routineDetailBuilder?.call(routine) ??
            RoutineDetailScreen(routine: routine),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final rp = context.watch<RoutineProvider>();
    final items = widget.showFavoritesOnly
        ? rp.userRoutines.where((r) => r.isFavorite).toList()
        : rp.userRoutines;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.showFavoritesOnly ? 'Favorite Routines' : 'Saved Routines',
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: rp.isLoadingUserRoutines
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(theme.accentOrange),
              ),
            )
          : items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  widget.showFavoritesOnly
                      ? 'No favorite routines yet.'
                      : 'No saved routines yet.',
                  style: TextStyle(color: theme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                final user = context.read<AuthProvider>().uiState.currentUser;
                if (user == null) return;
                await context.read<RoutineProvider>().loadUserRoutines(
                  user.uid,
                );
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    Divider(color: theme.border.withValues(alpha: 0.4)),
                itemBuilder: (context, idx) {
                  final ur = items[idx];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: FutureBuilder<String>(
                      future: _titleForRoutine(ur.routineId),
                      builder: (context, snap) {
                        return Text(
                          snap.data ?? 'Loading…',
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    subtitle: Text(
                      'Completed ${ur.timesCompleted}x',
                      style: TextStyle(color: theme.textSecondary),
                    ),
                    trailing: IconButton(
                      tooltip: ur.isFavorite ? 'Unfavorite' : 'Favorite',
                      icon: Icon(
                        ur.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: ur.isFavorite
                            ? Colors.redAccent
                            : theme.textSecondary,
                      ),
                      onPressed: () async {
                        await context
                            .read<RoutineProvider>()
                            .toggleFavoriteByRoutineId(ur.routineId);
                      },
                    ),
                    onTap: () => _openRoutine(ur.routineId),
                  );
                },
              ),
            ),
    );
  }

  Future<String> _titleForRoutine(String routineId) async {
    final cached = _titleCache[routineId];
    if (cached != null) return cached;
    final routine = await _supabase.getRoutine(routineId);
    final title = routine?.title ?? routineId;
    _titleCache[routineId] = title;
    return title;
  }
}
