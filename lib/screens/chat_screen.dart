import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/nutrition_profile_provider.dart';
import '../providers/nutrition_tracker_provider.dart';
import '../providers/routine_provider.dart';
import '../providers/theme_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/animated_gradient_border.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/loading_indicator.dart';
import 'routines/routine_detail_screen.dart';
import 'tools/calorie_scanner_screen.dart';

/// Things Celia can actually do, offered up front so the abilities are
/// discoverable instead of hidden behind knowing what to ask.
List<String> _suggestions(AppLocalizations l10n) => <String>[
  l10n.chatSuggestionHiit,
  l10n.chatSuggestionDinner,
  l10n.chatSuggestionProgress,
  l10n.chatSuggestionIngredients,
];

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _publishUserState();
      context.read<NutritionTrackerProvider>().refresh();
      final userId = context.read<AuthProvider>().uiState.currentUser?.uid;
      if (userId != null) {
        context.read<RoutineProvider>().loadUserRoutines(userId);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Hands Celia the profile numbers she cannot read from the backend.
  void _publishUserState() {
    final user = context.read<AuthProvider>().uiState.currentUser;
    final name = user?.displayName?.trim();
    context.read<ChatProvider>().setUserState(
      buildUserState(
        displayName: name != null && name.isNotEmpty
            ? name
            : user?.email?.split('@').first,
        profile: context.read<NutritionProfileProvider>().profile,
      ),
    );
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _publishUserState();
    _controller.clear();
    _scrollToEnd();
    await context.read<ChatProvider>().sendMessage(text);
    if (!mounted) return;
    // A routine Celia just saved should show up in the library straight away.
    final userId = context.read<AuthProvider>().uiState.currentUser?.uid;
    if (userId != null) {
      context.read<RoutineProvider>().loadUserRoutines(userId);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _openRoutine(String routineId) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final routine = await SupabaseService.instance.getRoutine(routineId);
      if (routine == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.chatCouldNotOpenRoutine)),
        );
        return;
      }
      await navigator.push(
        MaterialPageRoute(builder: (_) => RoutineDetailScreen(routine: routine)),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.chatCouldNotOpenRoutine)),
      );
    }
  }

  Future<void> _showHistory() async {
    final chat = context.read<ChatProvider>();
    await chat.loadHistory();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _HistorySheet(
        onOpen: (id) async {
          Navigator.of(sheetContext).pop();
          await chat.openConversation(id);
          _scrollToEnd();
        },
        onDelete: chat.deleteConversation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: theme.isDarkMode
                  ? theme.background.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.accentOrange.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_icon_foreground.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.chatTitle,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.chatHistory,
            icon: Icon(Icons.history, color: theme.textPrimary),
            onPressed: _showHistory,
          ),
          IconButton(
            tooltip: l10n.chatNew,
            icon: Icon(Icons.add_comment, color: theme.textPrimary),
            onPressed: () => context.read<ChatProvider>().startNewConversation(),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chat, child) {
          if (chat.isLoadingConversation) {
            return Center(
              child: LoadingIndicator(message: l10n.chatOpening),
            );
          }

          return Column(
            children: [
              Expanded(
                child: chat.hasMessages
                    ? ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        itemCount: chat.messages.length,
                        itemBuilder: (context, index) => ChatMessageBubble(
                          message: chat.messages[index],
                          onApproval: (approvalId, approved) {
                            chat.respondToApproval(
                              approvalId: approvalId,
                              approved: approved,
                            );
                            _scrollToEnd();
                          },
                          onOpenRoutine: _openRoutine,
                        ),
                      )
                    : _EmptyState(onSuggestion: _send),
              ),
              if (chat.error != null)
                _ErrorBanner(
                  message: chat.error!,
                  onDismiss: chat.clearError,
                ),
              _Composer(
                controller: _controller,
                focusNode: _focusNode,
                isBusy: chat.isStreaming,
                onSend: () => _send(_controller.text),
                onScanMeal: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CalorieScannerScreen()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSuggestion});

  final Future<void> Function(String prompt) onSuggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final tracker = context.watch<NutritionTrackerProvider>();
    final hint = tracker.todayCalories > 0
        ? l10n.chatLoggedToday(tracker.todayCalories.round())
        : l10n.chatEmptySubtitle;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: theme.accentOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/app_icon_foreground.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.chatEmptyPrompt,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            hint,
            style: TextStyle(fontSize: 15, color: theme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final prompt in _suggestions(l10n))
                ActionChip(
                  label: Text(prompt),
                  labelStyle: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 13.5,
                  ),
                  backgroundColor: theme.isDarkMode
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  side: BorderSide(
                    color: theme.accentOrange.withValues(alpha: 0.3),
                  ),
                  shape: const StadiumBorder(),
                  onPressed: () => onSuggestion(prompt),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade400, fontSize: 13),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.red.shade400),
            onPressed: onDismiss,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.isBusy,
    required this.onSend,
    required this.onScanMeal,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isBusy;
  final VoidCallback onSend;
  final VoidCallback onScanMeal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      // 100 clears the bottom nav bar when the keyboard is closed.
      padding: EdgeInsets.only(bottom: keyboard > 0 ? keyboard + 8 : 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: AnimatedGradientBorder(
          isFocused: focusNode.hasFocus,
          glowColor: theme.accentOrange,
          idleBorderColor: theme.isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          backgroundColor: theme.isDarkMode
              ? const Color(0xFF1E2235).withValues(alpha: 0.6)
              : Colors.white,
          borderRadius: 32,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                padding: const EdgeInsets.only(bottom: 4, left: 8),
                // Celia's model cannot see photos, so a picture goes to the
                // scanner, which reads it and logs the meal she can then talk
                // about.
                tooltip: l10n.chatScanAMeal,
                icon: Icon(
                  Icons.photo_camera_outlined,
                  size: 24,
                  color: theme.isDarkMode ? Colors.white54 : Colors.black54,
                ),
                onPressed: onScanMeal,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => isBusy ? null : onSend(),
                  style: TextStyle(color: theme.textPrimary, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: l10n.chatInputHint,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    hintStyle: TextStyle(color: theme.textSecondary),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 4),
                child: isBusy
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.accentOrange,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.send,
                          color: theme.accentOrange,
                          size: 24,
                        ),
                        onPressed: onSend,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistorySheet extends StatelessWidget {
  const _HistorySheet({required this.onOpen, required this.onDelete});

  final Future<void> Function(String id) onOpen;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();

    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode ? const Color(0xFF15182A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Consumer<ChatProvider>(
        builder: (context, chat, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.chatYourChats,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (chat.isLoadingHistory)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (chat.history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    l10n.chatNoSavedChats,
                    style: TextStyle(color: theme.textSecondary),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: chat.history.length,
                    itemBuilder: (context, index) {
                      final conversation = chat.history[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          conversation.title,
                          style: TextStyle(color: theme.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _relativeTime(l10n, conversation.updatedAt),
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: theme.textSecondary,
                          ),
                          onPressed: () => onDelete(conversation.id),
                        ),
                        onTap: () => onOpen(conversation.id),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _relativeTime(AppLocalizations l10n, DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return l10n.chatJustNow;
    if (diff.inHours < 1) return l10n.chatMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.chatHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.chatDaysAgo(diff.inDays);
    return '${time.day}/${time.month}/${time.year}';
  }
}
