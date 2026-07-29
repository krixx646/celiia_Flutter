import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/chat_provider.dart';
import '../providers/nutrition_tracker_provider.dart';
import '../providers/routine_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/progress.dart';
import '../widgets/loading_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show File;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/chat_models.dart';
import '../utils/user_facing_error.dart';
import '../widgets/animated_gradient_border.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _coachContext(BuildContext context) {
    final tracker = context.read<NutritionTrackerProvider>();
    final routines = context.read<RoutineProvider>().userRoutines;
    final streakStats = computeActiveStreakStats(
      routines: routines,
      meals: tracker.meals,
    );
    return buildCoachContext(
      nutritionContext: tracker.chatContext,
      streakStats: streakStats,
    );
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().uiState.currentUser;
      final email = user?.email;
      final name = user?.displayName?.trim().isNotEmpty == true
          ? user!.displayName!.trim()
          : email?.split('@').first;
      context.read<ChatProvider>().initializeChat(
        firebaseUserId: user?.uid,
        name: name,
        email: email,
      );
      context.read<NutritionTrackerProvider>().refresh();
      final userId = user?.uid;
      if (userId != null) {
        context.read<RoutineProvider>().loadUserRoutines(userId);
      }
    });
  }

  bool _looksLikeMarkdown(String input) {
    if (input.isEmpty) return false;
    final patterns = <RegExp>[
      RegExp(r'(^|\n)#{1,6}\s'), // headers
      RegExp(r'\*\*[^\*]+\*\*'), // bold
      RegExp(r'(^|\n)[\-\*]\s+'), // bullet list
      RegExp(r'(^|\n)\d+\.\s+'), // ordered list
    ];
    return patterns.any((r) => r.hasMatch(input));
  }

  TextSpan _linkTextSpan(String text, String url) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          final uri = Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
    );
  }

  InlineSpan _plainSpan(String text, {TextStyle? style}) =>
      TextSpan(text: text, style: style);

  // Very lightweight parser for markdown links [label](url) and bare URLs
  List<InlineSpan> _linkify(String input, {TextStyle? style}) {
    final List<InlineSpan> spans = [];
    final markdownRegex = RegExp(r"\[([^\]]+)\]\((https?:[^)]+)\)");
    final urlRegex = RegExp(r"(https?:\/\/[^\s)]+)");

    int index = 0;
    for (final match in markdownRegex.allMatches(input)) {
      if (match.start > index) {
        spans.add(
          _plainSpan(input.substring(index, match.start), style: style),
        );
      }
      final label = match.group(1)!;
      final url = match.group(2)!;
      spans.add(_linkTextSpan(label, url));
      index = match.end;
    }
    if (index < input.length) {
      final remainder = input.substring(index);
      // Within the remainder, convert bare URLs
      int rIndex = 0;
      for (final m in urlRegex.allMatches(remainder)) {
        if (m.start > rIndex) {
          spans.add(
            _plainSpan(remainder.substring(rIndex, m.start), style: style),
          );
        }
        final url = m.group(0)!;
        spans.add(_linkTextSpan(url, url));
        rIndex = m.end;
      }
      if (rIndex < remainder.length) {
        spans.add(_plainSpan(remainder.substring(rIndex), style: style));
      }
    }
    return spans;
  }

  Future<String?> _uploadImageToImgbb(List<int> bytes, String filename) async {
    const apiKey = Env.imgbbKey;
    if (apiKey.isEmpty) return null;
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final b64 = base64Encode(bytes);
    final response = await http.post(
      uri,
      body: {'image': b64, 'name': filename},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      final data = jsonMap['data'] as Map<String, dynamic>?;
      return data?['url'] as String?;
    }
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'Coach Celia',
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
            tooltip: 'New Chat',
            icon: Icon(Icons.add_comment, color: theme.textPrimary),
            onPressed: () async {
              final chat = context.read<ChatProvider>();
              // Save current conversation before resetting; show result
              final saved = await chat.saveCurrentConversation();
              await chat.restartConversation();
              await chat.startNewConversation();
              if (!context.mounted) return;
              final messenger = ScaffoldMessenger.of(context);
              messenger.clearSnackBars();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    saved
                        ? 'Saved and started a new chat'
                        : 'Started a new chat',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chat, child) {
          final ui = chat.uiState;
          final tracker = context.watch<NutritionTrackerProvider>();
          final nutritionHint = tracker.todayCalories > 0
              ? 'You\'ve logged ${tracker.todayCalories.round()} kcal today. Ask Celia about your remaining budget.'
              : 'Ask about your form, diet, or routines.';

          if (ui.isLoadingInitial) {
            return const Center(
              child: LoadingIndicator(message: 'Initializing chat...'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ui.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: theme.accentOrange.withValues(
                                  alpha: 0.1,
                                ),
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
                              'How can I help you\nget fit today?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              nutritionHint,
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        itemCount: ui.messages.length,
                        itemBuilder: (context, index) {
                          final msg = ui.messages[index];
                          final provider = Provider.of<ChatProvider>(
                            context,
                            listen: false,
                          );
                          // Use the reliable message direction tracking from ChatProvider
                          final isUser = provider.isUserMessage(msg.id);
                          final botBubbleColor = theme.isDarkMode
                              ? const Color(0xFF1A1D2D)
                              : Colors.grey.shade200;
                          final botTextColor = theme.isDarkMode
                              ? Colors.white
                              : Colors.black87;

                          Widget bubble;
                          if (msg.type == 'image' &&
                              (msg.imageUrl ?? '').isNotEmpty) {
                            final cacheW =
                                (MediaQuery.of(context).size.width * 2).toInt();
                            bubble = ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                msg.imageUrl!,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                cacheWidth: cacheW,
                                headers: const {'Accept': 'image/*'},
                                errorBuilder: (context, error, stack) {
                                  final baseStyle = Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isUser
                                            ? Colors.white
                                            : botTextColor,
                                      );
                                  return InkWell(
                                    onTap: () => launchUrl(
                                      Uri.parse(msg.imageUrl!),
                                      mode: LaunchMode.externalApplication,
                                    ),
                                    child: Text(
                                      msg.imageUrl!,
                                      style: baseStyle,
                                    ),
                                  );
                                },
                              ),
                            );
                          } else if (msg.type == 'button' ||
                              msg.type == 'choice' ||
                              msg.type == 'dropdown') {
                            final options = msg.options ?? [];
                            final hasInteracted = context
                                .watch<ChatProvider>()
                                .hasMessageBeenInteracted(msg.id);
                            bubble = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((msg.text ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      msg.text!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: isUser
                                                ? Colors.white
                                                : (theme.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black87),
                                          ),
                                    ),
                                  ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: options
                                      .fold<
                                        Map<String, MessageOption>
                                      >(<String, MessageOption>{}, (map, opt) {
                                        final key = '${opt.label}|${opt.value}';
                                        map[key] =
                                            opt; // last one wins but keys unique
                                        return map;
                                      })
                                      .values
                                      .map(
                                        (opt) => OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: hasInteracted
                                                ? (theme.isDarkMode
                                                      ? Colors.white54
                                                      : Colors.grey.shade700)
                                                : (theme.isDarkMode
                                                      ? Colors.white
                                                      : Colors.deepPurple),
                                            backgroundColor: hasInteracted
                                                ? (theme.isDarkMode
                                                      ? Colors.white10
                                                      : Colors.grey.shade100)
                                                : (theme.isDarkMode
                                                      ? theme.accentOrange
                                                            .withValues(
                                                              alpha: 0.24,
                                                            )
                                                      : const Color(
                                                          0xFFF3E5F5,
                                                        )),
                                            side: BorderSide(
                                              color: hasInteracted
                                                  ? Colors.grey
                                                  : (theme.isDarkMode
                                                        ? theme.accentOrange
                                                              .withValues(
                                                                alpha: 0.7,
                                                              )
                                                        : const Color(
                                                            0xFFCE93D8,
                                                          )),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                          ),
                                          onPressed: hasInteracted
                                              ? null
                                              : () async {
                                                  await context
                                                      .read<ChatProvider>()
                                                      .sendMessageWithInteraction(
                                                        opt.value,
                                                        msg.id,
                                                        nutritionContext:
                                                            _coachContext(
                                                          context,
                                                        ),
                                                      );
                                                },
                                          child: Text(
                                            opt.label,
                                            style: TextStyle(
                                              color: hasInteracted
                                                  ? (theme.isDarkMode
                                                        ? Colors.white54
                                                        : Colors.grey.shade700)
                                                  : (theme.isDarkMode
                                                        ? Colors.white
                                                        : Colors.deepPurple),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            );
                          } else {
                            final text = msg.text ?? '';
                            final shouldUseMarkdown = _looksLikeMarkdown(text);
                            // If message is a direct image URL, render inline
                            final isDirectImage =
                                Uri.tryParse(text)?.hasAbsolutePath == true &&
                                (text.endsWith('.png') ||
                                    text.endsWith('.jpg') ||
                                    text.endsWith('.jpeg') ||
                                    text.endsWith('.gif') ||
                                    text.contains('i.imgur.com') ||
                                    text.contains('imgbb.com') ||
                                    text.contains('images.'));
                            if (isDirectImage) {
                              final cacheW =
                                  (MediaQuery.of(context).size.width * 2)
                                      .toInt();
                              bubble = ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  text,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                  cacheWidth: cacheW,
                                  headers: const {'Accept': 'image/*'},
                                  errorBuilder: (_, __, ___) {
                                    final style = Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isUser
                                              ? Colors.white
                                              : botTextColor,
                                        );
                                    return InkWell(
                                      onTap: () => launchUrl(
                                        Uri.parse(text),
                                        mode: LaunchMode.externalApplication,
                                      ),
                                      child: Text(text, style: style),
                                    );
                                  },
                                ),
                              );
                            } else if (shouldUseMarkdown) {
                              final baseColor = isUser
                                  ? Colors.white
                                  : botTextColor;
                              bubble = MarkdownBody(
                                data: text,
                                onTapLink: (label, href, title) {
                                  if (href != null) {
                                    launchUrl(
                                      Uri.parse(href),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                styleSheet:
                                    MarkdownStyleSheet.fromTheme(
                                      Theme.of(context),
                                    ).copyWith(
                                      p: Theme.of(context).textTheme.bodyMedium
                                          ?.copyWith(
                                            color: baseColor,
                                            height: 1.5,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      h1: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: baseColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      h2: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: baseColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      h3: Theme.of(context).textTheme.titleLarge
                                          ?.copyWith(
                                            color: baseColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      strong: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: baseColor,
                                      ),
                                      em: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: baseColor,
                                      ),
                                      a: TextStyle(
                                        color: isUser
                                            ? Colors.white70
                                            : Colors.blue.shade700,
                                        decoration: TextDecoration.underline,
                                      ),
                                      listBullet: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: baseColor),
                                    ),
                              );
                            } else {
                              final textStyle = Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isUser ? Colors.white : botTextColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    height: 1.5,
                                  );
                              bubble = RichText(
                                text: TextSpan(
                                  style: textStyle,
                                  children: _linkify(text, style: textStyle),
                                ),
                              );
                            }
                          }

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                // Make bubbles feel larger, close to full width
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.95,
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 6,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? const Color(0xFFF57C00)
                                      : botBubbleColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DefaultTextStyle.merge(
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isUser ? Colors.white : botTextColor,
                                    height: 1.5,
                                  ),
                                  child: bubble,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (ui.error != null &&
                  !ui.error!.toLowerCase().contains('not a participant') &&
                  !ui.error!.toLowerCase().contains('unavailable'))
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    toUserFriendlyMessage(
                      ui.error,
                      fallback: 'Something went wrong. Please try again.',
                    ),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              // Save button fixed at bottom (optional explicit save)
              // moved Save action to app bar; removed bottom button
              // inline history panel removed; retrieval now via bottom sheet picker
              // Chat Composer Area
              AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0
                      ? MediaQuery.of(context).viewInsets.bottom + 8
                      : 100, // 100 to clear the bottom nav bar when keyboard is closed
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: AnimatedGradientBorder(
                    isFocused: _focusNode.hasFocus,
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
                          tooltip: 'Attach file',
                          icon: Icon(
                            Icons.attach_file,
                            size: 24,
                            color: theme.isDarkMode
                                ? Colors.white54
                                : Colors.black54,
                          ),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final provider = Provider.of<ChatProvider>(
                              context,
                              listen: false,
                            );
                            try {
                              final result = await FilePicker.platform
                                  .pickFiles(
                                    type: FileType.image,
                                    withData: true,
                                    allowMultiple: false,
                                  );
                              if (result == null || result.files.isEmpty) {
                                return;
                              }
                              final file = result.files.first;
                              final bytes =
                                  file.bytes ??
                                  await File(file.path!).readAsBytes();
                              final url = await _uploadImageToImgbb(
                                bytes,
                                file.name,
                              );
                              if (url == null) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Image upload failed'),
                                  ),
                                );
                                return;
                              }
                              final ui = provider.uiState;
                              if (!ui.hasActiveConversation) {
                                await provider.startNewConversation();
                              }
                              await provider.sendMessage(url);
                            } catch (_) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Upload failed. Please try again.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            minLines: 1,
                            maxLines: 4,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Ask about your form, diet, or routines...',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              hintStyle: TextStyle(color: theme.textSecondary),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, right: 4),
                          child: ui.isSendingMessage
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.orange,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color: theme.accentOrange,
                                    size: 24,
                                  ),
                                  onPressed: () async {
                                    final text = _controller.text.trim();
                                    if (text.isEmpty) {
                                      return;
                                    }
                                    final coachContext = _coachContext(context);
                                    if (!ui.hasActiveConversation) {
                                      await chat.startNewConversation();
                                    }
                                    await chat.sendMessage(
                                      text,
                                      nutritionContext: coachContext,
                                    );
                                    _controller.clear();
                                    await chat.saveCurrentConversation();
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
