import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/celia_chat_message.dart';
import '../providers/theme_provider.dart';

/// Renders one turn of the conversation: Celia's text, whatever she looked up
/// while answering, any permission she is waiting on, and links to things she
/// created.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.onApproval,
    required this.onOpenRoutine,
  });

  final CeliaMessage message;
  final void Function(String approvalId, bool approved) onApproval;
  final void Function(String routineId) onOpenRoutine;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    if (message.isUser) {
      return _Bubble(
        alignment: Alignment.centerRight,
        color: const Color(0xFFF57C00),
        child: Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.45,
          ),
        ),
      );
    }

    final textColor = theme.isDarkMode ? Colors.white : Colors.black87;
    final approval = message.pendingApproval;
    final routine = message.createdRoutine;
    final activity = _visibleActivity(message.toolCalls);

    return _Bubble(
      alignment: Alignment.centerLeft,
      color: theme.isDarkMode ? const Color(0xFF1A1D2D) : Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final call in activity) _ToolActivityRow(call: call),
          if (activity.isNotEmpty && message.text.trim().isNotEmpty)
            const SizedBox(height: 10),
          if (message.text.trim().isNotEmpty)
            _MarkdownText(text: message.text, color: textColor),
          if (message.isStreaming && message.isEmpty)
            _ThinkingDots(color: theme.textSecondary),
          if (approval != null) ...[
            const SizedBox(height: 14),
            _ApprovalCard(
              call: approval,
              onDecision: (approved) =>
                  onApproval(approval.approvalId!, approved),
            ),
          ],
          if (routine != null) ...[
            const SizedBox(height: 14),
            _RoutineCard(
              title: routine.title,
              onOpen: () => onOpenRoutine(routine.routineId),
            ),
          ],
          if (message.error != null) ...[
            const SizedBox(height: 10),
            Text(
              message.error!,
              style: TextStyle(color: Colors.red.shade400, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  /// Reads are only interesting while they run; once Celia has answered, the
  /// answer speaks for itself. Writes stay visible so there is a record of what
  /// was changed or declined.
  List<ChatToolCall> _visibleActivity(List<ChatToolCall> calls) {
    final streaming = message.isStreaming;
    return calls.where((call) {
      switch (call.phase) {
        case ToolPhase.preparing:
        case ToolPhase.running:
          return streaming;
        case ToolPhase.awaitingApproval:
          return false; // Shown as the approval card instead.
        case ToolPhase.denied:
        case ToolPhase.failed:
          return true;
        case ToolPhase.done:
          return _isWrite(call.toolName);
      }
    }).toList();
  }

  bool _isWrite(String toolName) => const {
    'create_routine',
    'log_meal',
    'save_routine',
  }.contains(toolName);
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.alignment,
    required this.color,
    required this.child,
  });

  final Alignment alignment;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.92,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MarkdownText extends StatelessWidget {
  const _MarkdownText({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: color,
      fontSize: 16,
      height: 1.45,
    );

    return MarkdownBody(
      data: text,
      selectable: true,
      onTapLink: (label, href, title) {
        if (href == null) return;
        launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
      },
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: base,
        listBullet: base,
        h1: base?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        h2: base?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        h3: base?.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
        strong: TextStyle(fontWeight: FontWeight.bold, color: color),
        em: TextStyle(fontStyle: FontStyle.italic, color: color),
        a: TextStyle(
          color: Colors.blue.shade400,
          decoration: TextDecoration.underline,
        ),
        blockSpacing: 10,
      ),
    );
  }
}

/// A single line of "what Celia is doing", so a pause of several seconds is
/// legible rather than looking stuck.
class _ToolActivityRow extends StatelessWidget {
  const _ToolActivityRow({required this.call});

  final ChatToolCall call;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final (icon, color) = switch (call.phase) {
      ToolPhase.done => (Icons.check_circle_outline, theme.accentOrange),
      ToolPhase.denied => (Icons.block, theme.textSecondary),
      ToolPhase.failed => (Icons.error_outline, Colors.red.shade400),
      _ => (null, theme.textSecondary),
    };

    final label = switch (call.phase) {
      ToolPhase.done => _pastTense(call),
      ToolPhase.denied => 'Cancelled',
      ToolPhase.failed => '${call.activityLabel} — that did not work',
      _ => '${call.activityLabel}…',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          if (icon == null)
            SizedBox(
              width: 13,
              height: 13,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: theme.accentOrange,
              ),
            )
          else
            Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _pastTense(ChatToolCall call) {
    switch (call.toolName) {
      case 'create_routine':
        final failed = call.output?['created'] == false;
        return failed ? 'Could not save the routine' : 'Saved to your library';
      case 'log_meal':
        return 'Added to today\'s log';
      case 'save_routine':
        return 'Added to your library';
      default:
        return call.activityLabel;
    }
  }
}

/// Celia asks before she changes anything the user owns.
class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({required this.call, required this.onDecision});

  final ChatToolCall call;
  final void Function(bool approved) onDecision;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final exercises = call.proposedExercises;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.accentOrange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.accentOrange.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            call.approvalPrompt,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (exercises.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final name in exercises.take(6))
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '• $name',
                  style: TextStyle(color: theme.textSecondary, fontSize: 13),
                ),
              ),
            if (exercises.length > 6)
              Text(
                '+ ${exercises.length - 6} more',
                style: TextStyle(color: theme.textSecondary, fontSize: 13),
              ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.accentOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => onDecision(true),
                  child: const Text('Yes, do it'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textSecondary,
                    side: BorderSide(
                      color: theme.textSecondary.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => onDecision(false),
                  child: const Text('Not now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.title, required this.onOpen});

  final String title;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.accentOrange.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_fill, color: theme.accentOrange, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Tap to open',
                    style: TextStyle(color: theme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ThinkingDots extends StatefulWidget {
  const _ThinkingDots({required this.color});

  final Color color;

  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Staggered so the dots rise and fall in sequence.
            final phase = (_controller.value - i * 0.18) % 1.0;
            final lift = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Opacity(
                opacity: 0.35 + lift * 0.65,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
