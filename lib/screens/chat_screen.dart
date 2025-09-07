import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/chat_provider.dart';
import '../widgets/loading_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io' show File;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

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
      style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          final uri = Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
    );
  }

  InlineSpan _plainSpan(String text, {TextStyle? style}) => TextSpan(text: text, style: style);

  // Very lightweight parser for markdown links [label](url) and bare URLs
  List<InlineSpan> _linkify(String input, {TextStyle? style}) {
    final List<InlineSpan> spans = [];
    final markdownRegex = RegExp(r"\[([^\]]+)\]\((https?:[^)]+)\)");
    final urlRegex = RegExp(r"(https?:\/\/[^\s)]+)");

    int index = 0;
    for (final match in markdownRegex.allMatches(input)) {
      if (match.start > index) {
        spans.add(_plainSpan(input.substring(index, match.start), style: style));
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
          spans.add(_plainSpan(remainder.substring(rIndex, m.start), style: style));
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
    final runtimeKey = const String.fromEnvironment('IMGBB_API_KEY');
    final apiKey = runtimeKey.isNotEmpty ? runtimeKey : Env.imgbbKey;
    if (apiKey.isEmpty) return null;
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final b64 = base64Encode(bytes);
    final response = await http.post(uri, body: {
      'image': b64,
      'name': filename,
    });
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      final data = jsonMap['data'] as Map<String, dynamic>?;
      return data?['url'] as String?;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initializeChat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        title: const Text('Coach Celia', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'Save Chat',
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () async {
              final ok = await context.read<ChatProvider>().saveCurrentConversation();
              if (!context.mounted) return;
              final messenger = ScaffoldMessenger.of(context);
              messenger.clearSnackBars();
              messenger.showSnackBar(SnackBar(content: Text(ok ? 'Conversation saved' : 'Nothing to save yet')));
            },
          ),
          IconButton(
            tooltip: 'New Chat',
            icon: const Icon(Icons.add_comment, color: Colors.white),
            onPressed: () async {
              final chat = context.read<ChatProvider>();
              // Save current conversation before resetting; show result
              final saved = await chat.saveCurrentConversation();
              await chat.restartConversation();
              await chat.startNewConversation();
              if (!context.mounted) return;
              final messenger = ScaffoldMessenger.of(context);
              messenger.clearSnackBars();
              messenger.showSnackBar(SnackBar(content: Text(saved ? 'Saved and started a new chat' : 'Started a new chat')));
            },
          ),
          
          IconButton(
            tooltip: 'Retrieve Chat',
            icon: const Icon(Icons.folder_open, color: Colors.white),
            onPressed: () async {
              final provider = Provider.of<ChatProvider>(context, listen: false);
              await provider.loadConversationHistory();
              if (!context.mounted) return;
              final rootMessenger = ScaffoldMessenger.of(context);
              // open lightweight picker dialog
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                builder: (sheetContext) {
                  return Consumer<ChatProvider>(
                    builder: (innerContext, chat, __) {
                      final ui = chat.uiState;
                      if (ui.isLoadingHistory) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: LoadingIndicator(message: 'Loading...')),
                        );
                      }
                      if (ui.conversationHistory.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.folder_off_outlined, size: 48, color: Colors.black54),
                                SizedBox(height: 12),
                                Text('No saved conversations yet', style: TextStyle(fontSize: 16)),
                                SizedBox(height: 8),
                                Text('Tap the bookmark icon to save a chat', style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                        );
                      }
                      return SafeArea(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: ui.conversationHistory.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final item = ui.conversationHistory[idx];
                            return ListTile(
                              title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(item.lastMessage, maxLines: 2, overflow: TextOverflow.ellipsis),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  await chat.deleteConversationById(item.id);
                                  if (!sheetContext.mounted) return;
                                  Navigator.of(sheetContext).pop();
                                  rootMessenger.clearSnackBars();
                                  rootMessenger.showSnackBar(const SnackBar(content: Text('Conversation deleted')));
                                },
                              ),
                              onTap: () async {
                                await chat.loadConversationFromHistory(item);
                                if (!sheetContext.mounted) return;
                                Navigator.of(sheetContext).pop();
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chat, child) {
          final ui = chat.uiState;
          
          if (ui.isLoadingInitial) {
            return const Center(child: LoadingIndicator(message: 'Initializing chat...'));
          }
          
          return Column(
            children: [
              Expanded(
                child: ui.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/logo_the_fit.png',
                                height: 140,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stack) {
                                  return Image.asset(
                                    'assets/images/logo_the_fit.jpg',
                                    height: 140,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error2, stack2) => const Icon(Icons.self_improvement, size: 96, color: Color(0xFFFF9800)),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'How can I help you get fit today?',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  itemCount: ui.messages.length,
                  itemBuilder: (context, index) {
                    final msg = ui.messages[index];
                    final provider = Provider.of<ChatProvider>(context, listen: false);
                    // Use the reliable message direction tracking from ChatProvider
                    final isUser = provider.isUserMessage(msg.id);
                    
                    Widget bubble;
                    if (msg.type == 'image' && (msg.imageUrl ?? '').isNotEmpty) {
                      final cacheW = (MediaQuery.of(context).size.width * 2).toInt();
                      bubble = ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          msg.imageUrl!,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          cacheWidth: cacheW,
                          headers: const { 'Accept': 'image/*' },
                          errorBuilder: (context, error, stack) {
                            final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: isUser ? Colors.white : Colors.black87);
                            return InkWell(
                              onTap: () => launchUrl(Uri.parse(msg.imageUrl!), mode: LaunchMode.externalApplication),
                              child: Text(msg.imageUrl!, style: baseStyle),
                            );
                          },
                        ),
                      );
                    } else if (msg.type == 'button' || msg.type == 'choice' || msg.type == 'dropdown') {
                      final options = msg.options ?? [];
                      final hasInteracted = context.watch<ChatProvider>().hasMessageBeenInteracted(msg.id);
                      bubble = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((msg.text ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                msg.text!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isUser ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: options.map((opt) => OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: hasInteracted ? Colors.grey : (isUser ? Colors.white : Colors.deepPurple),
                                side: BorderSide(color: hasInteracted ? Colors.grey : const Color(0xFFBDBDBD)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              onPressed: hasInteracted
                                  ? null
                                  : () async {
                                      await context.read<ChatProvider>().sendMessageWithInteraction(opt.value, msg.id);
                                    },
                              child: Text(opt.label),
                            )).toList(),
                          )
                        ],
                      );
                    } else {
                      final text = msg.text ?? '';
                      final shouldUseMarkdown = _looksLikeMarkdown(text);
                      // If message is a direct image URL, render inline
                      final isDirectImage = Uri.tryParse(text)?.hasAbsolutePath == true &&
                        (text.endsWith('.png') || text.endsWith('.jpg') || text.endsWith('.jpeg') || text.endsWith('.gif') || text.contains('i.imgur.com') || text.contains('imgbb.com') || text.contains('images.') );
                      if (isDirectImage) {
                        final cacheW = (MediaQuery.of(context).size.width * 2).toInt();
                        bubble = ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            text,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            cacheWidth: cacheW,
                            headers: const { 'Accept': 'image/*' },
                            errorBuilder: (_, __, ___) {
                              final style = Theme.of(context).textTheme.bodyMedium?.copyWith(color: isUser ? Colors.white : Colors.black87);
                              return InkWell(onTap: () => launchUrl(Uri.parse(text), mode: LaunchMode.externalApplication), child: Text(text, style: style));
                            },
                          ),
                        );
                      } else if (shouldUseMarkdown) {
                        final baseColor = isUser ? Colors.white : Colors.black87;
                        bubble = MarkdownBody(
                          data: text,
                          onTapLink: (label, href, title) {
                            if (href != null) {
                              launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
                            }
                          },
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            p: Theme.of(context).textTheme.bodyMedium?.copyWith(color: baseColor, height: 1.5, fontSize: 16, fontWeight: FontWeight.bold),
                            h1: Theme.of(context).textTheme.headlineMedium?.copyWith(color: baseColor, fontWeight: FontWeight.bold),
                            h2: Theme.of(context).textTheme.headlineSmall?.copyWith(color: baseColor, fontWeight: FontWeight.bold),
                            h3: Theme.of(context).textTheme.titleLarge?.copyWith(color: baseColor, fontWeight: FontWeight.bold),
                            strong: TextStyle(fontWeight: FontWeight.bold, color: baseColor),
                            em: TextStyle(fontStyle: FontStyle.italic, color: baseColor),
                            a: TextStyle(color: isUser ? Colors.white70 : Colors.blue.shade700, decoration: TextDecoration.underline),
                            listBullet: Theme.of(context).textTheme.bodyMedium?.copyWith(color: baseColor),
                          ),
                        );
                      } else {
                        final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        );
                        bubble = RichText(text: TextSpan(style: textStyle, children: _linkify(text, style: textStyle)));
                      }
                    }

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          // Make bubbles feel larger, close to full width
                          maxWidth: MediaQuery.of(context).size.width * 0.95,
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFFF57C00) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: DefaultTextStyle.merge(
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isUser ? Colors.white : Colors.black87,
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
              if (ui.error != null && !ui.error!.toLowerCase().contains('not a participant'))
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(ui.error!, style: const TextStyle(color: Colors.red)),
                ),
              // Save button fixed at bottom (optional explicit save)
              // moved Save action to app bar; removed bottom button
              // inline history panel removed; retrieval now via bottom sheet picker
              SafeArea(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Type a message',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: 'Attach file',
                          icon: const Icon(Icons.attach_file, color: Colors.black87),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true, allowMultiple: false);
                              if (result == null || result.files.isEmpty) return;
                              final file = result.files.first;
                              final bytes = file.bytes ?? await File(file.path!).readAsBytes();
                              final url = await _uploadImageToImgbb(bytes, file.name);
                              if (url == null) {
                                messenger.showSnackBar(const SnackBar(content: Text('Image upload failed')));
                                return;
                              }
                              if (!context.mounted) return;
                              final provider = context.read<ChatProvider>();
                              final ui = provider.uiState;
                              if (!ui.hasActiveConversation) {
                                await provider.startNewConversation();
                              }
                              await provider.sendMessage(url);
                            } on FirebaseException catch (e) {
                              messenger.showSnackBar(SnackBar(content: Text('Storage error: ${e.code}')));
                            } catch (_) {
                              messenger.showSnackBar(const SnackBar(content: Text('Upload error')));
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'Camera',
                          icon: const Icon(Icons.photo_camera, color: Colors.black87),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
                              if (picked == null) return;
                              final bytes = await picked.readAsBytes();
                              final url = await _uploadImageToImgbb(bytes, picked.name);
                              if (url == null) {
                                messenger.showSnackBar(const SnackBar(content: Text('Image upload failed')));
                                return;
                              }
                              if (!context.mounted) return;
                              final provider = context.read<ChatProvider>();
                              final ui = provider.uiState;
                              if (!ui.hasActiveConversation) {
                                await provider.startNewConversation();
                              }
                              await provider.sendMessage(url);
                            } catch (_) {
                              messenger.showSnackBar(const SnackBar(content: Text('Camera error')));
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF9800),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: ui.isSendingMessage
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.send, color: Colors.white),
                            onPressed: ui.isSendingMessage
                                ? null
                                : () async {
                                    final text = _controller.text.trim();
                                    if (text.isEmpty) return;
                                    if (!ui.hasActiveConversation) {
                                      await chat.startNewConversation();
                                    }
                                    await chat.sendMessage(text);
                                    _controller.clear();
                                    await chat.saveCurrentConversation();
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
      // Floating action button removed per request
    );
  }
}


