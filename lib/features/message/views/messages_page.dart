import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../core/constants/app_colors.dart';
import '../../../data/models/message_model.dart';
import '../providers/messages_provider.dart';
import '../providers/send_message_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class MessagesPage extends StatefulWidget {
  final int caseId;
  const MessagesPage({super.key, required this.caseId});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordingPath;
  String? _currentPlayingUrl;

  @override
  void initState() {
    super.initState();
    _initializeMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initializeMessages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AllMessagesProvider>().fetchMessages(widget.caseId);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<AllMessagesProvider>().fetchMoreMessages(widget.caseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 1,
        title: Text(
          'Messages',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.titleText,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: AppColors.charcoalGrey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Consumer<AllMessagesProvider>(
      builder: (context, provider, child) {
        if (provider.status == AllMessagesStatus.loading &&
            provider.messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }

        if (provider.status == AllMessagesStatus.error &&
            provider.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.message_minus,
                  size: 64,
                  color: AppColors.mediumGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load messages',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? 'Unknown error occurred',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.mediumGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchMessages(widget.caseId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.message, size: 64, color: AppColors.mediumGrey),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start the conversation by sending a message',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.mediumGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount:
              provider.messages.length + (provider.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.messages.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ),
              );
            }

            final message = provider.messages[index];
            return _buildMessageBubble(message);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final currentUser = context.read<AuthProvider>().user;
    final isMe = currentUser?.id == message.sender;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryBlue : AppColors.pureWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoalGrey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe) ...[
                    Text(
                      message.senderName,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (message.type == 'text' && message.content != null)
                    _buildTextMessage(message.content!, isMe)
                  else if (message.type == 'voice')
                    _buildVoiceMessage(message, isMe),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.createdAt),
                    style: TextStyle(
                      color: isMe
                          ? AppColors.pureWhite.withValues(alpha: 0.7)
                          : AppColors.mediumGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.tealGreen.withValues(alpha: 0.1),
              child: Text(
                currentUser?.name?.isNotEmpty == true
                    ? currentUser!.name![0].toUpperCase()
                    : 'M',
                style: const TextStyle(
                  color: AppColors.tealGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextMessage(String content, bool isMe) {
    return Text(
      content,
      style: TextStyle(
        color: isMe ? AppColors.pureWhite : AppColors.charcoalGrey,
        fontSize: 14,
      ),
    );
  }

  Widget _buildVoiceMessage(MessageModel message, bool isMe) {
    final isCurrentlyPlaying =
        _currentPlayingUrl == message.voiceFileUrl && _isPlaying;
    final hasValidUrl =
        message.voiceFileUrl != null && message.voiceFileUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.pureWhite.withValues(alpha: 0.2)
            : AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: hasValidUrl
                ? () => _toggleAudioPlayback(message.voiceFileUrl)
                : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasValidUrl
                    ? (isMe ? AppColors.pureWhite : AppColors.primaryBlue)
                    : AppColors.mediumGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCurrentlyPlaying ? Iconsax.pause : Iconsax.play,
                color: hasValidUrl
                    ? (isMe ? AppColors.primaryBlue : AppColors.pureWhite)
                    : AppColors.pureWhite,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.microphone_2,
                      color: isMe ? AppColors.pureWhite : AppColors.primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Voice message',
                      style: TextStyle(
                        color: isMe
                            ? AppColors.pureWhite
                            : AppColors.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (!hasValidUrl) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Audio file unavailable',
                    style: TextStyle(
                      color: isMe
                          ? AppColors.pureWhite.withValues(alpha: 0.7)
                          : AppColors.mediumGrey,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isCurrentlyPlaying) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isMe ? AppColors.pureWhite : AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoalGrey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppColors.mediumGrey.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    IconButton(
                      onPressed: _pickAudioFile,
                      icon: const Icon(
                        Iconsax.attach_circle,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Consumer<SendMessageProvider>(
              builder: (context, sendProvider, child) {
                if (sendProvider.isLoading) {
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.pureWhite,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                }

                return Row(
                  children: [
                    GestureDetector(
                      onLongPressStart: (_) => _startRecording(),
                      onLongPressEnd: (_) => _stopRecording(),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? AppColors.red
                              : AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isRecording ? Iconsax.stop : Iconsax.microphone,
                          color: AppColors.pureWhite,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendTextMessage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.tealGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.send_1,
                          color: AppColors.pureWhite,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAudioPlayback(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio file not available'),
            backgroundColor: AppColors.red,
          ),
        );
      }
      return;
    }

    try {
      if (_currentPlayingUrl == audioUrl && _isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        // Stop any currently playing audio
        if (_isPlaying) {
          await _audioPlayer.stop();
        }

        // Set up the new audio URL
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();

        setState(() {
          _currentPlayingUrl = audioUrl;
          _isPlaying = true;
        });

        // Listen for completion
        _audioPlayer.playerStateStream.listen((state) {
          if (mounted && state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlaying = false;
              _currentPlayingUrl = null;
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        _isPlaying = false;
        _currentPlayingUrl = null;
      });

      if (mounted) {
        String errorMessage = 'Error playing audio';
        if (e.toString().contains('Cleartext HTTP traffic not permitted')) {
          errorMessage =
              'Audio playback requires secure connection. Please check network settings.';
        } else if (e.toString().contains('Unable to connect')) {
          errorMessage =
              'Unable to connect to audio server. Please check your internet connection.';
        } else if (e.toString().contains('404') ||
            e.toString().contains('not found')) {
          errorMessage = 'Audio file not found on server.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppColors.pureWhite,
              onPressed: () => _toggleAudioPlayback(audioUrl),
            ),
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Microphone permission is required to record audio',
              ),
              backgroundColor: AppColors.red,
            ),
          );
        }
        return;
      }

      final directory = await getTemporaryDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _recordingPath = path.join(directory.path, fileName);

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath!,
      );

      setState(() {
        _isRecording = true;
       
      });

      HapticFeedback.lightImpact();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting recording: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      HapticFeedback.lightImpact();

      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await _sendVoiceMessage(file);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping recording: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await _sendVoiceMessage(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking audio file: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendTextMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    final sendProvider = context.read<SendMessageProvider>();
    await sendProvider.sendTextMessage(widget.caseId, content);

    if (sendProvider.status == SendMessageStatus.sent &&
        sendProvider.sentMessage != null) {
      if (mounted) {
        context.read<AllMessagesProvider>().addNewMessage(
          sendProvider.sentMessage!,
        );
        _scrollToBottom();
      }
    } else if (sendProvider.status == SendMessageStatus.error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sendProvider.errorMessage ?? 'Failed to send message',
            ),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendVoiceMessage(File audioFile) async {
    final sendProvider = context.read<SendMessageProvider>();
    await sendProvider.sendVoiceMessage(widget.caseId, audioFile);

    if (sendProvider.status == SendMessageStatus.sent &&
        sendProvider.sentMessage != null) {
      if (mounted) {
        context.read<AllMessagesProvider>().addNewMessage(
          sendProvider.sentMessage!,
        );
        _scrollToBottom();
      }
    } else if (sendProvider.status == SendMessageStatus.error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sendProvider.errorMessage ?? 'Failed to send voice message',
            ),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }

    // Clean up temporary file if it was a recording
    if (_recordingPath != null && audioFile.path == _recordingPath) {
      try {
        await audioFile.delete();
        _recordingPath = null;
      } catch (e) {
        // Ignore cleanup errors
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
