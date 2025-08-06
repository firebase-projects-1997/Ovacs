import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:new_ovacs/common/widgets/rounded_container.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/app_sizes.dart';
import '../../../data/models/message_model.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/edit_delete_message_provider.dart';
import '../providers/messages_provider.dart';
import '../providers/send_message_provider.dart';

class MessagesPage extends StatefulWidget {
  final int caseId;

  const MessagesPage({super.key, required this.caseId});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _textController = TextEditingController();
  final _recorder = AudioRecorder();

  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(
    Duration.zero,
  );

  bool _isRecording = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _recordingFilePath;
  int? _playingMessageId;

  late Stopwatch _stopwatch;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();

    Future.microtask(() {
      context.read<AllMessagesProvider>().fetchMessages(widget.caseId);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        context.read<AllMessagesProvider>().fetchMoreMessages(widget.caseId);
      }
    });

    _audioPlayer.positionStream
        .throttleTime(const Duration(milliseconds: 100))
        .listen((pos) => _positionNotifier.value = pos);
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _recordingTimer?.cancel();
    _scrollController.dispose();
    _audioPlayer.dispose();
    _textController.dispose();
    _positionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.messages,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AllMessagesProvider>(
              builder: (context, provider, _) {
                if (provider.status == AllMessagesStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.status == AllMessagesStatus.error) {
                  return Center(
                    child: Text(
                      provider.errorMessage ??
                          AppLocalizations.of(context)!.errorLoadingMessages,
                    ),
                  );
                }

                return ListView.separated(
                  controller: _scrollController,
                  reverse: true,
                  itemCount:
                      provider.messages.length + (provider.hasMore ? 1 : 0),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == provider.messages.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final message = provider.messages[index];
                    return GestureDetector(
                      onLongPress: () => _showMessageOptions(message),
                      child: _buildMessageItem(message),
                    );
                  },
                );
              },
            ),
          ),
          if (_isUploading)
            LinearProgressIndicator(value: _uploadProgress, minHeight: 2),
          _buildInputField(),
        ],
      ),
    );
  }

  Future<File?> convertToMp3(File inputFile) async {
    final dir = await getTemporaryDirectory();
    final outputPath = p.join(
      dir.path,
      '${DateTime.now().millisecondsSinceEpoch}.mp3',
    );

    final command =
        '-i "${inputFile.path}" -vn -ar 44100 -ac 2 -b:a 192k "$outputPath"';

    final session = await FFmpegKit.execute(command);

    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return File(outputPath);
    } else {
      // Handle conversion failure

      return null;
    }
  }

  Future<void> _startRecording() async {
    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context)!.microphonePermissionRequired,
      );
      openAppSettings();
      return;
    }

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/${const Uuid().v4()}.m4a';

    try {
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      _recordingFilePath = filePath;
      _stopwatch
        ..reset()
        ..start();
      _recordingTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() {}),
      );
      setState(() => _isRecording = true);
    } catch (e) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context)!.failedToStartRecording,
      );
    }
  }

  Future<void> _stopRecording({bool send = true}) async {
    if (!_isRecording) return;

    try {
      final path = await _recorder.stop();
      _recordingTimer?.cancel();
      _stopwatch.stop();
      setState(() => _isRecording = false);

      if (!send) return;

      if (path != null && await File(path).exists()) {
        final originalFile = File(path);
        if (await originalFile.length() > 0) {
          final mp3File = await convertToMp3(originalFile);
          if (mp3File != null && await mp3File.exists()) {
            await _sendAudioMessage(mp3File);
            unawaited(originalFile.delete()); // delete original file
          } else {
            showAppSnackBar(
              context,
              AppLocalizations.of(context)!.failedToConvertAudioToMp3,
            );
          }
        } else {
          showAppSnackBar(
            context,
            AppLocalizations.of(context)!.emptyAudioFile,
          );
        }
      }
    } catch (e) {
      showAppSnackBar(context, AppLocalizations.of(context)!.recordingError);
    } finally {
      _recordingFilePath = null;
    }
  }

  Future<void> _cancelRecording() async {
    await _stopRecording(send: false);
    if (_recordingFilePath != null) {
      final file = File(_recordingFilePath!);
      if (await file.exists()) await file.delete();
    }
    showAppSnackBar(context, AppLocalizations.of(context)!.recordingCancelled);
  }

  Future<void> _sendAudioMessage(File file) async {
    final provider = context.read<SendMessageProvider>();
    double currentProgress = 0.0;

    void progressListener() {
      final newProgress = provider.uploadProgress.value;
      if (mounted && newProgress != currentProgress) {
        currentProgress = newProgress;
        setState(() => _uploadProgress = newProgress);
      }
    }

    provider.uploadProgress.addListener(progressListener);
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      await provider.sendVoiceMessage(widget.caseId, file);
    } finally {
      provider.uploadProgress.removeListener(progressListener);
    }

    setState(() => _isUploading = false);

    if (provider.status == SendMessageStatus.sent) {
      context.read<AllMessagesProvider>().addNewMessage(provider.sentMessage!);
      unawaited(file.delete());
    } else {
      showAppSnackBar(
        context,
        provider.errorMessage ?? AppLocalizations.of(context)!.sendFailed,
      );
    }
  }

  Future<void> _pickAndSendAudio() async {
    final mic = await Permission.audio.request();
    final storage = await Permission.storage.request();

    if (!mic.isGranted && !storage.isGranted) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context)!.microphoneAndStoragePermissionsRequired,
      );
      openAppSettings();
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      if (await file.exists()) {
        await _sendAudioMessage(file);
      } else {
        showAppSnackBar(context, AppLocalizations.of(context)!.fileNotFound);
      }
    }
  }

  String _recordingTimerText() {
    final seconds = _stopwatch.elapsed.inSeconds;
    return '00:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildInputField() {
    final isTextNotEmpty = _textController.text.trim().isNotEmpty;

    return Padding(
      padding: AppSizes.noAppBarPadding(context),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Iconsax.folder_open),
            onPressed: _pickAndSendAudio,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _textController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _isRecording
                    ? _recordingTimerText()
                    : AppLocalizations.of(context)!.enterMessage,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _isRecording
                    ? const Icon(Icons.circle, color: Colors.red, size: 10)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_isRecording) ...[
            CircleAvatar(
              backgroundColor: Colors.red,
              child: IconButton(
                icon: const Icon(Iconsax.close_circle, color: Colors.white),
                onPressed: _cancelRecording,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green,
              child: IconButton(
                icon: const Icon(Iconsax.send_2, color: Colors.white),
                onPressed: () => _stopRecording(send: true),
              ),
            ),
          ] else
            CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: IconButton(
                icon: Icon(
                  isTextNotEmpty ? Iconsax.send1 : Iconsax.microphone,
                  color: Colors.white,
                ),
                onPressed: isTextNotEmpty ? _sendMessage : _startRecording,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final provider = context.read<SendMessageProvider>();
    final content = _textController.text.trim();
    if (content.isEmpty) return;

    _textController.clear();
    await provider.sendTextMessage(widget.caseId, content);

    if (!mounted) return;

    if (provider.status == SendMessageStatus.sent) {
      context.read<AllMessagesProvider>().addNewMessage(provider.sentMessage!);
    } else {
      showAppSnackBar(
        context,
        provider.errorMessage ?? AppLocalizations.of(context)!.sendFailed,
      );
    }
  }

  Widget _buildMessageItem(MessageModel message) {
    final isVoice = message.type == 'voice';

    return RoundedContainer(
      backgroundColor: AppColors.mediumGrey.withOpacity(0.1),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.senderName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          if (isVoice)
            _buildVoicePlayer(message)
          else
            Text(
              message.content ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              _formatTime(message.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoicePlayer(MessageModel message) {
    final isPlaying = _playingMessageId == message.id;

    return ValueListenableBuilder<Duration>(
      valueListenable: _positionNotifier,
      builder: (context, position, _) {
        final duration = _audioPlayer.duration ?? Duration.zero;
        final displayPos = isPlaying ? position : duration;

        return Row(
          children: [
            IconButton(
              iconSize: 30,
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: Colors.blueAccent,
              ),
              onPressed: () async {
                if (isPlaying) {
                  await _audioPlayer.pause();
                  if (mounted) setState(() => _playingMessageId = null);
                } else {
                  await _playVoice(message.voiceFileUrl ?? '', message.id);
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    value: displayPos.inMilliseconds.toDouble().clamp(
                      0,
                      duration.inMilliseconds.toDouble(),
                    ),
                    max: duration.inMilliseconds.toDouble().clamp(
                      1,
                      double.infinity,
                    ),
                    onChanged: (v) =>
                        _audioPlayer.seek(Duration(milliseconds: v.toInt())),
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.grey.shade300,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(displayPos),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _formatDuration(duration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _playVoice(String url, int messageId) async {
    if (url.isEmpty) {
      showAppSnackBar(context, AppLocalizations.of(context)!.audioUrlMissing);
      return;
    }

    try {
      await _audioPlayer.setUrl(url);
      setState(() => _playingMessageId = messageId);
      await _audioPlayer.play();

      _audioPlayer.playerStateStream.listen((state) {
        if (!state.playing && _playingMessageId == messageId && mounted) {
          setState(() => _playingMessageId = null);
        }
      });
    } catch (e) {
      if (mounted) setState(() => _playingMessageId = null);
      showAppSnackBar(context, AppLocalizations.of(context)!.playbackError);
    }
  }

  void _showMessageOptions(MessageModel message) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            if (message.type == 'text')
              ListTile(
                leading: const Icon(Iconsax.edit),
                title: Text(
                  AppLocalizations.of(context)!.edit,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(message);
                },
              ),
            ListTile(
              leading: const Icon(Iconsax.trash),
              title: Text(
                AppLocalizations.of(context)!.delete,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(message.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final time = TimeOfDay.fromDateTime(dateTime.toLocal());
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _editMessage(MessageModel message) async {
    final provider = context.read<EditDeleteMessageProvider>();
    final controller = TextEditingController(text: message.content);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.editMessageTitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.writeNewMessage,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: () async {
              await provider.editMessage(message.id, controller.text);
              if (provider.status == EditDeleteStatus.success && mounted) {
                context.read<AllMessagesProvider>().updateMessage(
                  provider.updatedMessage!,
                );
                Navigator.pop(context);
              } else {
                showAppSnackBar(
                  context,
                  provider.errorMessage ??
                      AppLocalizations.of(context)!.failedToEditMessage,
                );
              }
            },
            child: Text(
              AppLocalizations.of(context)!.save,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMessage(int messageId) async {
    final provider = context.read<EditDeleteMessageProvider>();
    await provider.deleteMessage(messageId);

    if (provider.status == EditDeleteStatus.success) {
      context.read<AllMessagesProvider>().removeMessage(messageId);
    } else {
      showAppSnackBar(context, provider.errorMessage);
    }
  }
}
