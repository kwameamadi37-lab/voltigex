import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show listEquals, setEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/media_path_utils.dart';
import 'package:voltigex/core/network/connectivity_bloc.dart';
import 'package:voltigex/core/network/socket_service.dart';
import 'package:voltigex/core/widgets/custom_user_avatar.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/selected_file.dart';
import 'package:voltigex/features/chatting/chat/presentation/bloc/chat_bloc.dart';
import 'package:voltigex/features/chatting/chat/presentation/bloc/chat_event.dart';
import 'package:voltigex/features/chatting/chat/presentation/bloc/chat_state.dart';
import 'package:voltigex/features/chatting/chat/presentation/widgets/chat_bubble_frame.dart';
import 'package:voltigex/features/chatting/chat/presentation/widgets/chat_list_layout.dart';
import 'package:voltigex/features/chatting/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:voltigex/features/chatting/chat/presentation/widgets/chat_message_list_keys.dart';
import 'package:voltigex/features/chatting/chat/presentation/widgets/chat_status_view.dart';
import 'package:voltigex/features/chatting/chat/presentation/widgets/sent_read_receipt_ui.dart';
import 'package:voltigex/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';

class ChatPage extends StatefulWidget {
  /// Vide si nouvelle conversation (premier envoi via [recipientUserId]).
  final String conversationId;
  final String mate;
  /// URL brute ou absente (voir [CustomUserAvatar]).
  final String? profilePhotoUrl;
  final String? participantRole;
  /// Utilisateur cible lorsque [conversationId] est vide.
  final String? recipientUserId;

  const ChatPage({
    super.key,
    this.conversationId = '',
    required this.mate,
    this.profilePhotoUrl,
    this.participantRole,
    this.recipientUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>  with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  static const List<String> _kChatDocumentExtensions = [
    'jpeg',
    'png',
    'jpg',
    'gif',
    'webp',
    'mp4',
    'mov',
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'txt',
    'zip',
    'rar',
    'csv',
  ];

  static String _extensionForPickedFile(PlatformFile file) {
    var ext = (file.extension ?? '')
        .replaceFirst('.', '')
        .toLowerCase();
    if (ext.isEmpty) {
      ext = p.extension(file.name).replaceFirst('.', '').toLowerCase();
    }
    return ext;
  }

  static bool _isAllowedDocumentExtension(String ext) =>
      _kChatDocumentExtensions.contains(ext.toLowerCase());

  @override
  bool get wantKeepAlive => true;

  /// Id conversation pour API (widget ou premier message synchronisé).
  String? _effectiveConversationId(ChatLoadedState state) {
    if (widget.conversationId.trim().isNotEmpty) {
      return widget.conversationId.trim();
    }
    for (final m in state.messages) {
      if (m.conversationId.trim().isNotEmpty) {
        return m.conversationId.trim();
      }
    }
    return null;
  }

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  ChatBloc? _chatBloc;
  String botId = '00000000-0000-0000-0000-000000000000';
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _connectivitySyncRetryDebounce;
  List<ConnectivityResult>? _lastConnectivityResults;
  Timer? _typingIdleFalseTimer;
  Timer? _typingTrueHeartbeatTimer;

  static const Duration _kConnectivitySyncRetryDebounce = Duration(seconds: 2);
  /// Au plus un POST `typing: true` toutes les 3 s pendant la saisie (réduit fortement le trafic).
  static const Duration _kTypingTrueHeartbeat = Duration(seconds: 3);
  /// Frappe considérée terminée : `is_typing: false` pour couper l’animation chez le partenaire.
  static const Duration _kTypingIdleBeforeFalse = Duration(milliseconds: 1500);

  List<SelectedMedia> _selectedFiles = [];
  final ImagePicker _imagePicker = ImagePicker();
  // Déclare une variable pour l'image sélectionnée en grand
  Uint8List? _selectedPreviewBytes;

  /// Liste inversée : l’utilisateur a remonté dans l’historique (s’éloigne du dernier message).
  bool _showJumpToLatestFab = false;
  static const double _kScrollAwayFromLatestPx = 88;

  Future<void> _appendPickedMedia(List<XFile> files) async {
    if (files.isEmpty) return;
    final picked = <SelectedMedia>[];
    for (final file in files) {
      final bytes = await file.readAsBytes();
      final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
      picked.add(
        SelectedMedia(
          name: p.basename(file.path),
          path: file.path,
          bytes: bytes,
          extension: ext.isEmpty ? null : ext,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _selectedFiles = [..._selectedFiles, ...picked];
    });
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = <SelectedMedia>[];
    var unsupportedCount = 0;

    for (final file in result.files) {
      final ext = _extensionForPickedFile(file);
      if (ext.isEmpty || !_isAllowedDocumentExtension(ext)) {
        unsupportedCount++;
        continue;
      }

      String? path = file.path;
      if (path == null || path.trim().isEmpty) {
        final bytes = file.bytes;
        if (bytes == null || bytes.isEmpty) continue;
        final tempDir = await getTemporaryDirectory();
        final safeExt = ext.startsWith('.') ? ext : '.$ext';
        final stamped =
            'chat_pick_${DateTime.now().millisecondsSinceEpoch}$safeExt';
        final out = File(p.join(tempDir.path, stamped));
        await out.writeAsBytes(bytes);
        path = out.path;
      }

      picked.add(
        SelectedMedia(
          name: file.name,
          path: path,
          bytes: file.bytes,
          extension: ext,
        ),
      );
    }

    if (!mounted) return;

    if (unsupportedCount > 0) {
      final l10n = AppLocalizations.of(context)!;
      TopSnackBar.show(
        context,
        l10n.chatErrorUnsupportedFormat,
        type: TopSnackBarType.error,
        title: l10n.chatFileSnackTitle,
      );
    }

    if (picked.isEmpty) return;
    setState(() {
      _selectedFiles = [..._selectedFiles, ...picked];
    });
  }

  Future<void> _pickFromCamera() async {
    final file = await _imagePicker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    await _appendPickedMedia([file]);
  }

  Future<void> _pickFromGallery() async {
    final files = await _imagePicker.pickMultiImage();
    await _appendPickedMedia(files);
  }

  Future<void> _openMediaPickerSheet() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.chatMediaCamera),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.chatMediaGallery),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close_rounded),
                title: Text(l10n.chatMediaCancel),
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  static bool _isHttpOrHttpsUrl(String s) {
    final t = s.trim().toLowerCase();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  static bool _isChatMediaMessage(MessageEntity message) {
    if (message.type.toUpperCase() == 'MEDIA') return true;
    final url = message.mediaUrl?.trim();
    return url != null && url.isNotEmpty;
  }

  static String _resolveMediaDisplayName(MessageEntity message) {
    final name = message.mediaName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final url = message.mediaUrl?.trim();
    if (url != null && url.isNotEmpty) {
      final base = p.basename(MediaPathUtils.pathForExtension(url));
      if (base.isNotEmpty && base != '.') return base;
    }
    return 'Fichier';
  }

  static bool _messageMediaIsImagePreview(MessageEntity message, String ext) {
    final mt = (message.mediaType ?? '').toLowerCase();
    if (mt == 'image') return true;
    if (mt == 'document' || mt == 'video' || mt == 'audio') return false;
    const img = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return img.contains(ext);
  }

  /// Fichier local (cache file_picker, chemin absolu Android/iOS, `file://`, `content://`, lecteur Windows).
  static bool _isLocalFilesystemPath(String s) {
    final t = s.trim();
    if (t.isEmpty) return false;
    if (t.toLowerCase().startsWith('content://')) return true;
    if (t.startsWith('file://')) return true;
    if (t.startsWith('/')) return true;
    if (t.length >= 3 && t[1] == ':' && (t[2] == r'\' || t[2] == '/')) {
      return true;
    }
    return false;
  }

  static String _localPathFromMediaUrl(String mediaUrl) {
    final t = mediaUrl.trim();
    if (t.startsWith('file://')) {
      return Uri.parse(t).toFilePath();
    }
    return t;
  }

  String _buildFullUrl(String? mediaUrl) =>
      MediaPathUtils.resolveApiMediaUrlForDisplay(mediaUrl ?? '');

  /// Octets du document : URL absolue, chemin local, ou chemin relatif API (`storage/...`).
  Future<Uint8List> _loadDocumentBytes(String mediaUrl) async {
    final t = mediaUrl.trim();
    if (t.isEmpty) {
      throw StateError('Chemin ou URL du document vide');
    }
    if (_isHttpOrHttpsUrl(t)) {
      final uri = Uri.parse(t.replaceAll(' ', '%20'));
      return http.readBytes(uri);
    }
    if (_isLocalFilesystemPath(t)) {
      final path = _localPathFromMediaUrl(t);
      if (path.toLowerCase().startsWith('content://')) {
        return XFile(path).readAsBytes();
      }
      return File(path).readAsBytes();
    }
    final base = Constants.baseUrl.replaceAll(RegExp(r'/$'), '');
    final rel = t.replaceFirst(RegExp(r'^/+'), '');
    final uri = Uri.parse('$base/$rel'.replaceAll(' ', '%20'));
    return http.readBytes(uri);
  }

  /// Ouvre le média avec l’app système (Photos, PDF, etc.) : fichier local si présent, sinon cache temporaire.
  Future<void> _openMediaWithNativeViewer(
    BuildContext context,
    String pathOrUrl, {
    String? fileExtension,
  }) async {
    try {
      final trimmed = pathOrUrl.trim();
      if (trimmed.isEmpty) return;

      String ext = fileExtension ?? '';
      if (ext.isNotEmpty && !ext.startsWith('.')) {
        ext = '.$ext';
      }
      if (ext.isEmpty) {
        ext = p.extension(trimmed);
      }
      if (ext.isEmpty) {
        ext = '.bin';
      }

      if (_isLocalFilesystemPath(trimmed)) {
        final localPath = _localPathFromMediaUrl(trimmed);
        if (localPath.toLowerCase().startsWith('content://')) {
          final tempDir = await getTemporaryDirectory();
          final outFile = File(
            p.join(
              tempDir.path,
              'chat_open_${DateTime.now().millisecondsSinceEpoch}$ext',
            ),
          );
          final bytes = await XFile(localPath).readAsBytes();
          await outFile.writeAsBytes(bytes);
          final result = await OpenFilex.open(outFile.path);
          if (!context.mounted) return;
          if (result.type != ResultType.done) {
            final l10n = AppLocalizations.of(context)!;
            TopSnackBar.show(
              context,
              result.type == ResultType.noAppToOpen
                  ? l10n.chatErrorNoAppFound
                  : l10n.chatFileOpenError,
              type: TopSnackBarType.error,
              title: l10n.chatFileSnackTitle,
            );
          }
          return;
        }
        final f = File(localPath);
        if (await f.exists()) {
          print('[DEBUG] Tentative d\'ouverture de : $localPath');
          final result = await OpenFilex.open(localPath);
          if (!context.mounted) return;
          if (result.type != ResultType.done) {
            final l10n = AppLocalizations.of(context)!;
            TopSnackBar.show(
              context,
              result.type == ResultType.noAppToOpen
                  ? l10n.chatErrorNoAppFound
                  : l10n.chatFileOpenError,
              type: TopSnackBarType.error,
              title: l10n.chatFileSnackTitle,
            );
          }
          return;
        }
      }

      final bytes = await _loadDocumentBytes(trimmed);
      final tempDir = await getTemporaryDirectory();
      final outFile = File(
        p.join(
          tempDir.path,
          'chat_open_${DateTime.now().millisecondsSinceEpoch}$ext',
        ),
      );
      await outFile.writeAsBytes(bytes);
      print('[DEBUG] Tentative d\'ouverture de : ${outFile.path}');
      final result = await OpenFilex.open(outFile.path);
      if (!context.mounted) return;
      if (result.type != ResultType.done) {
        final l10n = AppLocalizations.of(context)!;
        TopSnackBar.show(
          context,
          result.type == ResultType.noAppToOpen
              ? l10n.chatErrorNoAppFound
              : l10n.chatFileOpenError,
          type: TopSnackBarType.error,
          title: l10n.chatFileSnackTitle,
        );
      }
    } catch (_) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        TopSnackBar.show(
          context,
          l10n.chatFileOpenError,
          type: TopSnackBarType.error,
          title: l10n.chatFileSnackTitle,
        );
      }
    }
  }



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // <-- Inscription au cycle de vie
    _scrollController.addListener(_onScrollChatPosition);

    _scrollController.addListener(_onScrollChatPosition);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final uid = SessionController.instance.userId ?? '';
      final bloc = context.read<ChatBloc>();
      // Onglet principal (IndexedStack) : cache Hive + Pusher sans API au démarrage.
      // Route poussée (ex. admin) : chargement complet immédiat.
      if (Navigator.of(context).canPop()) {
        bloc.add(
          LoadMessagesEvent(
            widget.conversationId,
            currentUserId: uid.isNotEmpty ? uid : null,
            recipientUserId: widget.recipientUserId,
          ),
        );
      } else {
        bloc.add(
          HydrateChatFromCacheEvent(
            widget.conversationId,
            currentUserId: uid.isNotEmpty ? uid : null,
          ),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _setupConnectivitySyncRetryListener();
    });
  }

  bool _connectivityOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  void _setupConnectivitySyncRetryListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChangedForDeltaSync);
  }

  void _onConnectivityChangedForDeltaSync(List<ConnectivityResult> results) {
    if (!mounted) return;
    if (!_connectivityOnline(results)) {
      _connectivitySyncRetryDebounce?.cancel();
      _connectivitySyncRetryDebounce = null;
      _lastConnectivityResults = null;
      return;
    }
    if (listEquals(results, _lastConnectivityResults)) return;
    _lastConnectivityResults = List<ConnectivityResult>.from(results);

    final bloc = _chatBloc ?? (mounted ? context.read<ChatBloc>() : null);
    if (bloc == null) return;
    final state = bloc.state;
    if (state is! ChatLoadedState ||
        !state.syncFailed ||
        state.deltaSyncInProgress) {
      return;
    }

    _connectivitySyncRetryDebounce?.cancel();
    _connectivitySyncRetryDebounce = Timer(_kConnectivitySyncRetryDebounce, () {
      if (!mounted) return;
      final b = _chatBloc ?? context.read<ChatBloc>();
      final s = b.state;
      if (s is! ChatLoadedState ||
          !s.syncFailed ||
          s.deltaSyncInProgress) {
        return;
      }

      final uid = SessionController.instance.userId ?? '';
      SocketService.instance
          .reconnectAfterNetworkRestore()
          .catchError((_, __) {})
          .whenComplete(() {
        if (!mounted) return;
        _chatBloc?.add(
          LoadMessagesEvent(
            widget.conversationId,
            currentUserId: uid.isNotEmpty ? uid : null,
            recipientUserId: widget.recipientUserId,
          ),
        );
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatBloc ??= BlocProvider.of<ChatBloc>(context);
  }

  void _onScrollChatPosition() {
    if (!mounted || !_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final away = pos.pixels > _kScrollAwayFromLatestPx;
    if (away != _showJumpToLatestFab) {
      setState(() => _showJumpToLatestFab = away);
    }

    // reverse: true → le haut (messages plus anciens) correspond à maxScrollExtent.
    final maxExtent = pos.maxScrollExtent;
    if (maxExtent > 0 && pos.pixels >= maxExtent * 0.9) {
      final st = _chatBloc?.state;
      if (st is ChatLoadedState) {
        final cid = _effectiveConversationId(st);
        if (cid != null && cid.isNotEmpty) {
          _chatBloc?.add(LoadOlderMessagesEvent(cid));
        }
      }
    }
  }

  Future<void> _scrollToLatestAnimated() async {
    if (!_scrollController.hasClients) return;
    // Avec reverse: true, l’offset 0 correspond au bas du fil (messages les plus récents).
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  String _localizeChatError(AppLocalizations l10n, String codeOrMessage) {
    switch (codeOrMessage) {
      case 'chat.error.loadFailed':
        return l10n.chatErrorLoadFailed;
      case 'chat.error.readUpdateFailed':
        return l10n.chatErrorReadUpdateFailed;
      default:
        return codeOrMessage;
    }
  }


  List<String> getMessagesReadId(List<MessageEntity> messagesId, String currentUserId) {
    final List<String> finalList = [];
    for (final msg in messagesId) {
      if (currentUserId.isNotEmpty && msg.isRead == 0 && msg.senderId != currentUserId) {
        finalList.add(msg.id);
      }
    }
    return finalList;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // <-- Désinscription
    _typingIdleFalseTimer?.cancel();
    _typingTrueHeartbeatTimer?.cancel();
    _connectivitySyncRetryDebounce?.cancel();
    _connectivitySubscription?.cancel();
    _chatBloc?.add(ChatConversationUiClosedEvent());
    _scrollController.removeListener(_onScrollChatPosition);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // L'application revient en avant-plan : recharger/synchroniser la conversation
      final uid = SessionController.instance.userId ?? '';
      final bloc = _chatBloc ?? context.read<ChatBloc>();
      
      // Reconnexion forcée du socket pour être sûr que le canal est actif
      SocketService.instance.reconnectAfterNetworkRestore().catchError((_, __) {});

      // Déclenche le rechargement/delta sync des messages
      bloc.add(
        LoadMessagesEvent(
          widget.conversationId,
          currentUserId: uid.isNotEmpty ? uid : null,
          recipientUserId: widget.recipientUserId,
        ),
      );
    }
  }

  void _stopTypingEmitAndCancelTimers() {
    _typingIdleFalseTimer?.cancel();
    _typingIdleFalseTimer = null;
    _typingTrueHeartbeatTimer?.cancel();
    _typingTrueHeartbeatTimer = null;
  }

  void _emitTypingFalseForActiveConversation() {
    if (!mounted) return;
    final st = context.read<ChatBloc>().state;
    if (st is! ChatLoadedState) return;
    final cid = _effectiveConversationId(st);
    if (cid == null || cid.isEmpty) return;
    context.read<ChatBloc>().add(
          ChatTypingEvent(
            conversationId: cid,
            isTyping: false,
          ),
        );
  }

  void _onComposerTextChanged() {
    if (!mounted) return;
    final st = context.read<ChatBloc>().state;
    if (st is! ChatLoadedState) return;
    final cid = _effectiveConversationId(st);
    if (cid == null || cid.isEmpty) return;

    _typingIdleFalseTimer?.cancel();

    final hasText = _messageController.text.isNotEmpty;
    if (!hasText) {
      _stopTypingEmitAndCancelTimers();
      context.read<ChatBloc>().add(
            ChatTypingEvent(
              conversationId: cid,
              isTyping: false,
            ),
          );
      return;
    }

    void emitTrue() {
      if (!mounted) return;
      if (_messageController.text.isEmpty) return;
      context.read<ChatBloc>().add(
            ChatTypingEvent(
              conversationId: cid,
              isTyping: true,
            ),
          );
    }

    if (_typingTrueHeartbeatTimer == null) {
      emitTrue();
      _typingTrueHeartbeatTimer = Timer.periodic(_kTypingTrueHeartbeat, (_) {
        emitTrue();
      });
    }

    _typingIdleFalseTimer = Timer(_kTypingIdleBeforeFalse, () {
      if (!mounted) return;
      _stopTypingEmitAndCancelTimers();
      context.read<ChatBloc>().add(
            ChatTypingEvent(
              conversationId: cid,
              isTyping: false,
            ),
          );
    });
  }

  void _sendMessage() async{
    if (_messageController.text.isEmpty && _selectedFiles.isEmpty) {
      return; // rien à envoyer
    }

    HapticFeedback.lightImpact();

    final content = _messageController.text.trim();

    _stopTypingEmitAndCancelTimers();
    _emitTypingFalseForActiveConversation();

    // Son d'envoi de message
    final player = AudioPlayer();
      BlocProvider.of<ChatBloc>(context).add(
            SendMessageEvent(
              content,
              _selectedFiles,
              conversationId: widget.conversationId,
              recipientUserId: widget.recipientUserId,
            ),
          );
      await player.play(AssetSource('sounds/message_sent_sound.mp3'), volume: 0.07);

      _messageController.clear();

      setState(() {
        _selectedFiles.clear();
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // important pour keepAlive
    final l10n = AppLocalizations.of(context)!;
    final localeTag = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleSpacing: -15.5,
        title: Row(
          children: [
            SizedBox(width: 10,),
            Padding(padding: EdgeInsets.only(left: SessionController.instance.isAdminSupport ? 0 : 20),
            child: SizedBox(
              height: 28,
              width: 28,
              child: CustomUserAvatar(
                profilePhotoUrl: widget.profilePhotoUrl,
                role: widget.participantRole,
                radius: 14,
              ),
            )
            ),
            SizedBox(width: 4,),
            Text(
              widget.mate,
              style: GoogleFonts.inter(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.8,
                )
              )
            )
          ],
        ),
        foregroundColor: DefaultColors.blackColor,
        automaticallyImplyLeading: SessionController.instance.isAdminSupport,
        leading: SessionController.instance.isAdminSupport
          ? IconButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 22,
              ),
            )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocListener <ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatErrorState) {
                  // cet espace est nécessaire pour afficher le SnackBar

                  // Si il y a exception par faute de connexion (internet surtout)
                  final err = state.error;
                  if (err is DioException && err.type == DioExceptionType.connectionError) {
                    final l10n = AppLocalizations.of(context)!;
                    TopSnackBar.show(
                      context,
                      l10n.chatNetworkErrorBody,
                      type: TopSnackBarType.error,
                      title: l10n.chatNetworkSnackTitle,
                    );
                  } else {
                    final l10n = AppLocalizations.of(context)!;
                    TopSnackBar.show(
                      context,
                      _localizeChatError(l10n, state.message),
                      type: TopSnackBarType.error,
                      title: l10n.errorTitle,
                    );
                  }
                }
                if (state is ChatLoadedState) {
                  final listOfIds = getMessagesReadId(state.messages, state.currentUserId);
                  final cid = _effectiveConversationId(state);
                  if (listOfIds.isNotEmpty &&
                      cid != null &&
                      cid.isNotEmpty) {
                    context.read<ChatBloc>().add(
                          UpdateReadStatusEvent(cid, listOfIds),
                        );
                  }
                }
              },
              child: BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (prev, curr) {
                  if (prev.runtimeType != curr.runtimeType) return true;
                  if (prev is! ChatLoadedState || curr is! ChatLoadedState) {
                    return true;
                  }
                  final a = prev;
                  final b = curr;
                  return a.partnerLastSeenMessageId != b.partnerLastSeenMessageId ||
                      a.messages.length != b.messages.length ||
                      !identical(a.messages, b.messages) ||
                      a.currentUserId != b.currentUserId ||
                      a.loadingOlderMessages != b.loadingOlderMessages ||
                      a.deltaSyncInProgress != b.deltaSyncInProgress ||
                      a.syncFailed != b.syncFailed ||
                      a.isPartnerTyping != b.isPartnerTyping ||
                      a.retryingSendClientIds.length !=
                          b.retryingSendClientIds.length ||
                      !setEquals(a.retryingSendClientIds, b.retryingSendClientIds);
                },
                builder: (context, state){
                  if(state is ChatLoadingState){
                    return loader();
                  }
                  else if (state is ChatLoadedState) {
                    if(state.messages.isNotEmpty) {

                      if (state.currentUserId.isEmpty) {
                        return Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: loader(compact: true),
                            ),
                          ),
                        );
                      }

                      final listBuild = buildChatListItems(
                        messages: state.messages,
                        userId: state.currentUserId,
                        botId: botId,
                        localeTag: localeTag,
                        todayLabel: l10n.chatDateToday,
                        yesterdayLabel: l10n.chatDateYesterday,
                        partnerLastSeenMessageId: state.partnerLastSeenMessageId,
                      );
                      final listToDisplay = listBuild.items;
                      final showOlderLoader = state.loadingOlderMessages;
                      final listItemCount = listToDisplay.length + (showOlderLoader ? 1 : 0);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _connectivityOfflineBannerAboveList(),
                          // affichage de la barre de progression lors de la synchronisation avec l'API pour nouveaux messages

                          // if (state.deltaSyncInProgress)
                          //   SizedBox(
                          //     height: 2,
                          //     child: LinearProgressIndicator(
                          //       minHeight: 2,
                          //       backgroundColor: Colors.white.withValues(alpha: 0.06),
                          //       color: DefaultColors.buttonColor.withValues(alpha: 0.85),
                          //     ),
                          //   ),
                          
                          if (state.syncFailed || state.deltaSyncInProgress)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (state.deltaSyncInProgress)
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: loader(
                                          compact: true,
                                          color: DefaultColors.buttonColor
                                              .withValues(alpha: 0.85),
                                          size: 18,
                                        ),
                                      ),
                                    )
                                  else
                                    Icon(Icons.cloud_off, size: 15, color: Colors.orange.shade300),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.deltaSyncInProgress
                                          ? l10n.chatSyncInProgress
                                          : l10n.chatSyncNoInternet,
                                      style: GoogleFonts.inter(
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ListView.builder(
                            key: ValueKey(
                              'chat_list_${state.messages.length}_${state.messages.isNotEmpty ? state.messages.last.id : ''}',
                            ),
                            reverse: true,
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            itemCount: listItemCount,
                            itemBuilder: (context, index) {
                              if (showOlderLoader && index == listToDisplay.length) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: loader(
                                          compact: true,
                                          color: DefaultColors.buttonColor
                                              .withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final item = listToDisplay[index];
                              final rowKey = chatListItemStableKey(item, index);
                              if (item.isDate) {
                                return RepaintBoundary(
                                  key: rowKey,
                                  child: _buildDateChip(item.dateLabel!),
                                );
                              }
                              final message = item.message!;
                              if (item.isBot) {
                                return RepaintBoundary(
                                  key: rowKey,
                                  child: _buildDailyQuestionMessage(context, message),
                                );
                              }
                              if (item.isSent) {
                                return RepaintBoundary(
                                  key: rowKey,
                                  child: _buildSentMessage(
                                    context,
                                    message,
                                    bubbleRadius: item.bubbleRadius,
                                    showTimestamp: item.showTimestamp,
                                    partnerLastSeenMessageId:
                                        state.partnerLastSeenMessageId,
                                    bubbleTopMargin: item.bubbleTopMargin,
                                    retryingSendClientIds:
                                        state.retryingSendClientIds,
                                  ),
                                );
                              }
                              return RepaintBoundary(
                                key: rowKey,
                                  child: _buildReceivedMessage(
                                  context,
                                  message,
                                  bubbleRadius: item.bubbleRadius,
                                  showAvatarAndName: item.showAvatarAndName,
                                  showTimestamp: item.showTimestamp,
                                  bubbleTopMargin: item.bubbleTopMargin,
                                ),
                              );
                            },
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: AnimatedOpacity(
                              opacity: _showJumpToLatestFab ? 1 : 0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              child: IgnorePointer(
                                ignoring: !_showJumpToLatestFab,
                                child: Tooltip(
                                  message: l10n.chatJumpToLatestTooltip,
                                  child: Material(
                                    elevation: 6,
                                    shadowColor: Colors.black54,
                                    shape: const CircleBorder(),
                                    color: DefaultColors.scafoldColor,
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: _scrollToLatestAnimated,
                                      child: const Padding(
                                        padding: EdgeInsets.all(7),
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: DefaultColors.greyText,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _connectivityOfflineBannerAboveList(),
                        if (state.syncFailed || state.deltaSyncInProgress)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (state.deltaSyncInProgress)
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: loader(
                                        compact: true,
                                        color: DefaultColors.buttonColor
                                            .withValues(alpha: 0.85),
                                        size: 18,
                                      ),
                                    ),
                                  )
                                else
                                  Icon(Icons.cloud_off, size: 15, color: Colors.orange.shade300),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    state.deltaSyncInProgress
                                        ? l10n.chatSyncInProgress
                                        : l10n.chatSyncUnavailable,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: Colors.grey.shade500,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.tag_faces_sharp,
                                color: Colors.grey.shade800,
                                size: 50.0,
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Text(
                                  l10n.chatFirstMessagePrompt,
                                  style: GoogleFonts.inter(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  else if(state is ChatErrorState){
                    return _noDataToDisplay();
                  }

                  // Autre state...
                  return Container();
                }
              )
            )

          ),
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (prev, curr) {
              final wasTyping = prev is ChatLoadedState && prev.isPartnerTyping;
              final isTyping = curr is ChatLoadedState && curr.isPartnerTyping;
              return wasTyping != isTyping;
            },
            builder: (context, state) {
              final isPartnerTyping =
                  state is ChatLoadedState && state.isPartnerTyping;
              final showTypingIndicator = isPartnerTyping &&
                  SessionController.instance.isAdminSupport;
              return SafeArea(
                top: false,
                left: false,
                right: false,
                bottom: false,
                minimum: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showTypingIndicator)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 16, 2),
                        child: LoadingAnimationWidget.waveDots(
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    _buildMessageInput(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _noDataToDisplay(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.playlist_remove_sharp,
          color: Colors.grey.shade700,
          size: 100.0,
        ),
        SizedBox(height: 10,),
        Center(
            child: Text(
              AppLocalizations.of(context)!.chatNoDataAvailable,
              style: GoogleFonts.inter(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
                fontSize: 15.0,
              ),
            )
        )
      ],
    );
  }

  Widget _buildDateChip(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            date,
            style: GoogleFonts.inter(
              color: DefaultColors.blackColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(
    BuildContext context,
    MessageEntity message, {
    required BorderRadius bubbleRadius,
    required bool showAvatarAndName,
    required bool showTimestamp,
    required double bubbleTopMargin,
  }) {
    final text = message.content;
    final sendAt = message.createdAt;
    final mediaName = message.mediaName;
    final mediaUrl = message.mediaUrl;
    final mediaWidth = message.mediaWidth;
    final mediaHeight = message.mediaHeight;
    final mediaBlurHash = message.mediaBlurhash;

    // CODE SÉCURISÉ :
    DateTime parsedDate;

    if (sendAt.toString().trim().isNotEmpty) {
      // tryParse évite de lever une Exception si le format est invalide
      parsedDate = DateTime.tryParse(sendAt.toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final localTime = parsedDate.toLocal();
    final formattedTime = DateFormat('HH:mm').format(localTime);
    const isSentMessage = false;

    return Padding(
      padding: EdgeInsets.only(
        bottom: showTimestamp ? 2 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: showAvatarAndName
                ? CustomUserAvatar(
                    profilePhotoUrl: widget.profilePhotoUrl,
                    role: widget.participantRole,
                    radius: 14,
                  )
                : const SizedBox.shrink(),
          ),
          SizedBox(width: 6,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: bubbleTopMargin),
                  child: ChatBubbleFrame(
                    isMe: false,
                    child: _isChatMediaMessage(message)
                        ? ClipRRect(
                            borderRadius: bubbleRadius,
                            child: _buildMedia(
                              context,
                              message,
                              widget.mate,
                              _resolveMediaDisplayName(message),
                              mediaUrl ?? '',
                              mediaWidth,
                              mediaHeight,
                              mediaBlurHash,
                              formattedTime,
                              isSentMessage,
                              1,
                              clipRadius: bubbleRadius,
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: bubbleRadius,
                              color: DefaultColors.receiverMessage,
                            ),
                            child: Text(
                              text ?? '',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: DefaultColors.blackColor,
                                  ),
                            ),
                          ),
                  ),
                ),
                if (showTimestamp) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      formattedTime,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w300,
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                SizedBox(height: 12,)
                ],
                SizedBox(height: 5,)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentMessage(
    BuildContext context,
    MessageEntity message, {
    required BorderRadius bubbleRadius,
    required bool showTimestamp,
    required String? partnerLastSeenMessageId,
    required double bubbleTopMargin,
    required Set<String> retryingSendClientIds,
  }) {
    final text = message.content;
    final sendAt = message.createdAt;
    final isSaved = message.isSaved;
    final mediaName = message.mediaName;
    final mediaUrl = message.mediaUrl;
    final mediaWidth = message.mediaWidth;
    final mediaHeight = message.mediaHeight;
    final mediaBlurHash = message.mediaBlurhash;

    final utcTime = DateTime.parse(sendAt);
    final localTime = utcTime.toLocal();
    final formattedTime = DateFormat('HH:mm').format(localTime);
    const isSentMessage = true;
    var receiptUi = resolveSentReadReceiptForOutgoingMessage(
      msg: message,
      partnerLastSeenMessageId: partnerLastSeenMessageId,
    );
    if (message.isRead == 1 && receiptUi == SentReadReceiptUi.deliveredCheck) {
      receiptUi = SentReadReceiptUi.none;
    }
    final showReceiptSlot = receiptUi == SentReadReceiptUi.deliveredCheck ||
        receiptUi == SentReadReceiptUi.sending ||
        receiptUi == SentReadReceiptUi.readRecipientAvatar ||
        receiptUi == SentReadReceiptUi.sendFailed;
    final showStatusRow = showTimestamp || showReceiptSlot;

    final Widget bubbleMain = Container(
      margin: EdgeInsets.only(top: bubbleTopMargin),
      child: _isChatMediaMessage(message)
          ? ClipRRect(
              borderRadius: bubbleRadius,
              child: _buildMedia(
                context,
                message,
                null,
                _resolveMediaDisplayName(message),
                mediaUrl ?? '',
                mediaWidth,
                mediaHeight,
                mediaBlurHash,
                formattedTime,
                isSentMessage,
                isSaved,
                clipRadius: bubbleRadius,
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: bubbleRadius,
                color: DefaultColors.senderMessage,
              ),
              child: Text(
                text ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: showStatusRow ? 2 : 0,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: ChatBubbleFrame(
          isMe: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              bubbleMain,
              if (showStatusRow) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (showTimestamp)
                      Text(
                        formattedTime,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w300,
                          fontSize: 11,
                          color: DefaultColors.blackColor,
                        ),
                      ),
                    if (showTimestamp && showReceiptSlot) const SizedBox(width: 6),
                    if (showReceiptSlot)
                      ChatMessengerReadReceiptSlot(
                        ui: receiptUi,
                        profilePhotoUrl: widget.profilePhotoUrl,
                        participantRole: widget.participantRole,
                        messageId: message.id,
                        effectivePartnerLastSeenMessageId:
                            partnerLastSeenMessageId,
                        readReceiptHeroTag: widget.conversationId.trim().isNotEmpty
                            ? 'chat_partner_read_${widget.conversationId.trim()}'
                            : null,
                        messageIsRead: message.isRead,
                        switchKey:
                            '${message.id}_${message.clientId}_${receiptUi.name}_${partnerLastSeenMessageId ?? ''}',
                        onRetrySendFailed: message.isSaved == 0 &&
                                message.clientId.isNotEmpty
                            ? () => context.read<ChatBloc>().add(
                                  RetrySendMessageEvent(message),
                                )
                            : null,
                        isRetryingSend: retryingSendClientIds
                            .contains(message.clientId),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyQuestionMessage(BuildContext context, MessageEntity message) {
    final text = message.content ?? '';
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: ChatBubbleFrame.maxBubbleWidth(context)),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: DefaultColors.dailyQuestionColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            '${AppLocalizations.of(context)!.chatDailyQuestionPrefix} $text',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  /// Même emplacement / style que le bandeau sync ([syncFailed]), au-dessus du fil de messages.
  Widget _connectivityOfflineBannerAboveList() {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      buildWhen: (prev, curr) =>
          (prev is ConnectivityOffline) != (curr is ConnectivityOffline),
      builder: (context, connState) {
        final offline = connState is ConnectivityOffline;
        return AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          child: offline
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 15,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.chatOfflineBanner,
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity, height: 0),
        );
      },
    );
  }

  Widget _buildMessageInput(){
    final l10n = AppLocalizations.of(context)!;

    return CustomPaint(
      painter: _selectedFiles.isNotEmpty ?  _GradientBorderPainter() : null,
      child: Container(
        decoration: _selectedFiles.isNotEmpty ? BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30),),
          
          color: Colors.white.withOpacity(0),
        ) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_selectedFiles.isNotEmpty)
              Column(
                children: [
                  // Affichage de l'image en grand si sélectionnée
                  if (_selectedPreviewBytes != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.transparent,
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _selectedPreviewBytes!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPreviewBytes = null; // Fermer le grand aperçu
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black45,
                                ),
                                child: Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Liste horizontale des miniatures
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _selectedFiles.map((file) {
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // setState(() {
                                //   _selectedPreviewBytes = file.bytes; // Afficher en grand
                                // });

                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ['pdf', 'docx', 'doc'].contains(file.extension)
                                      ? Container(
                                    color: DefaultColors.receiverMessage,
                                    padding: EdgeInsets.only(top: 5, bottom: 5, left: 6, right: 22),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          file.extension == "pdf" ? "assets/images/svg/pdf.svg" : "assets/images/svg/fichier-docx.svg",
                                          colorFilter: ColorFilter.mode(file.extension == "pdf" ? Colors.red : Colors.blue, BlendMode.srcIn),
                                          semanticsLabel: l10n.chatPdfFileSemantics,
                                          width: 30,
                                        ),
                                        SizedBox(width: 5,),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                          maxWidth:  MediaQuery.of(context).size.width * 0.5,
                                          // largeur maximale = 50 % de l’écran
                                        ),
                                        child: Text(
                                          file.name,
                                          style: GoogleFonts.inter(
                                            textStyle: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13.5,
                                              color: DefaultColors.blackColor,
                                            ),
                                          ),
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: false, // empêche le retour à la ligne
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                      : Image.memory(
                                    file.bytes!,
                                    height: 63,
                                    width: 63,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            // Bouton de suppression
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFiles.remove(file);
                                    if (_selectedPreviewBytes == file.bytes) _selectedPreviewBytes = null;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: DefaultColors.blueBackground,
                                    border: Border.all(color: DefaultColors.whiteText, width: 0.5),
                                  ),
                                  child: Icon(Icons.close, size: 13, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
            ),
            // _selectedFiles.isEmpty ?
            Row(
              children: [
                SizedBox(width: 10,),
                Tooltip(
                  message: l10n.chatMediaDocument,
                  child: GestureDetector(
                    onTap: _pickDocuments,
                    child: Icon(
                      Icons.attach_file_rounded,
                      color: DefaultColors.blueBackground,
                      size: 25,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: l10n.chatMediaImage,
                  child: GestureDetector(
                    onTap: _openMediaPickerSheet,
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: DefaultColors.blueBackground,
                      size: 23,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: DefaultColors.receiverMessage,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      controller: _messageController,
                      onChanged: (_) => _onComposerTextChanged(),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                        hintText: l10n.chatMessageInputHint,
                        hintStyle: const TextStyle(color: DefaultColors.blackColor),
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      style: const TextStyle(color: DefaultColors.blackColor),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Icon(
                    Icons.send,
                    color: DefaultColors.blueBackground,
                  ),
                ),
                SizedBox(width: 15,),
          
              ],
            )
            ],
        ),
      ),
    ) ;
  }

  Widget _buildMedia(
      BuildContext context,
      MessageEntity message,
      String? senderName,
      String mediaName,
      String mediaUrl,
      int? mediaWidth,
      int? mediaHeight,
      String? mediaBlurHash,
      String time,
      bool isSentMessage,
      int? isSaved, {
      BorderRadius? clipRadius,
      }) {
    final borderRadius = clipRadius ?? BorderRadius.circular(12);
    final pathForExt = MediaPathUtils.pathForExtension(mediaUrl);
    final ext = p.extension(pathForExt).toLowerCase();

    final isDocument = !_messageMediaIsImagePreview(message, ext);
    final aspect = (mediaWidth != null && mediaHeight != null && mediaHeight > 0)
        ? mediaWidth / mediaHeight
        : 1.0;
    final thumbHeight = 115 / aspect;

    final Widget mediaPreview;
    if (isDocument) {
      mediaPreview = Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          // color: isSentMessage ? DefaultColors.senderMessage : DefaultColors.receiverMessage,
          color: DefaultColors.receiverMessage,
          borderRadius: borderRadius,
          border: const Border(
            bottom: BorderSide(width: 1, color: Colors.white),
          ),
        ),
        padding: const EdgeInsets.only(right: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 57,
              width: 48,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: DefaultColors.receiverMessage,
              ),
              child: ext == '.pdf'
                  ? SvgPicture.asset(
                      'assets/images/svg/PDF_file_icon.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.red,
                        BlendMode.srcIn,
                      ),
                      width: 30,
                    )
                  : (ext == '.doc' || ext == '.docx')
                      ? SvgPicture.asset(
                          'assets/images/svg/fichier-docx.svg',
                          colorFilter: const ColorFilter.mode(
                            Colors.blue,
                            BlendMode.srcIn,
                          ),
                          width: 30,
                        )
                      : Icon(
                          (message.mediaType ?? '').toLowerCase() == 'video'
                              ? Icons.videocam_rounded
                              : Icons.insert_drive_file_rounded,
                          color: DefaultColors.blueBackground,
                          size: 28,
                        ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                mediaName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: DefaultColors.blackColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.5
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: isSentMessage ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
      );
    } else {
      mediaPreview = _LockedChatImagePreview(
        message: message,
        thumbHeight: thumbHeight,
        buildFullUrl: _buildFullUrl,
      );
    }

    final openPath = () {
      final lp = message.metadata?['localFilePath']?.toString();
      if (lp != null && lp.isNotEmpty && File(lp).existsSync()) {
        return lp;
      }
      return mediaUrl;
    }();
    return ClipRRect(
      borderRadius: borderRadius,
      child: GestureDetector(
        onTap: () async {
          await _openMediaWithNativeViewer(context, openPath, fileExtension: ext);
        },
        child: Hero(
          tag: message.clientId.isNotEmpty ? message.clientId : message.id,
          child: mediaPreview,
        ),
      ),
    );
  }


// Widget _buildMedia(BuildContext context, String? senderName, String mediaUrl, String time, bool isSentMessage, int? isSaved) {
  //   // if (medias.isEmpty) return SizedBox.shrink();
  //
  //   final borderRadius = BorderRadius.circular(12);
  //   final ext = p.extension(mediaUrl).toLowerCase();
  //
  //   return ClipRRect(
  //     borderRadius: borderRadius,
  //     child: GestureDetector(
  //       onTap: () async{  ['.pdf'].contains(ext) ? _openPdf(context, mediaUrl) :
  //         _openImage(context, senderName, mediaUrl, time, isSentMessage, isSaved);
  //       },
  //       child: Hero(
  //         tag: mediaUrl,
  //         child: ['.pdf', '.doc', '.docx'].contains(ext) ?
  //         ConstrainedBox(
  //           constraints: BoxConstraints(
  //             maxWidth:  MediaQuery.of(context).size.width * 0.50 + 40,
  //           ),
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color: DefaultColors.senderMessage,
  //                 // borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), ),
  //                 border: Border(
  //                   bottom: BorderSide(
  //                     width: 1,
  //                     color: Colors.white,
  //                   )
  //                 )
  //               ),
  //               child: Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   Container(
  //                     height: 57,
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       // borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10),),
  //                     ),
  //                     padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
  //                     child: SvgPicture.asset(
  //                       ext == ".pdf" ?  "assets/images/svg/PDF_file_icon.svg" : "assets/images/svg/fichier-docx.svg",
  //                       colorFilter:  ColorFilter.mode(ext == ".pdf" ? Colors.red : Colors.blue, BlendMode.srcIn),
  //                       semanticsLabel: 'Red dash paths',
  //                       width: 30,
  //                     ),
  //                   ),
  //                   Container(
  //                     width: MediaQuery.of(context).size.width * 0.50,
  //                     color: Colors.red,
  //                     padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
  //                     child: Text(
  //                       p.basename(mediaUrl),
  //                       style:  GoogleFonts.inter(
  //                         textStyle: TextStyle(
  //                           fontWeight: FontWeight.w500,
  //                           fontSize: 14.0,
  //                         ),
  //                       ),
  //                       textAlign: isSentMessage ? TextAlign.right : TextAlign.left,
  //                       overflow: TextOverflow.ellipsis,
  //                       maxLines: 2,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ):
  //         (isSaved == null || isSaved == 0 ? Image.file(
  //           File(mediaUrl),
  //           width: 115,
  //         ) :
  //         CachedNetworkImage(
  //           key: ValueKey(mediaUrl),
  //           cacheKey: mediaUrl, // assure une entrée unique dans le cache
  //           memCacheWidth: 400, // optimise taille mémoire
  //           imageUrl: '${Constants.backendServerAddress}/$mediaUrl',
  //           placeholder: (context, url) => LoadingAnimationWidget.dotsTriangle(
  //             color: Colors.white,
  //             size: 21.5,
  //           ), // Pendant le chargement
  //           errorWidget: (context, url, error) => Icon(Icons.error),   // Si erreur
  //           fit: BoxFit.cover,
  //           width: 115,
  //         )
  //         ),
  //       ),
  //     ),
  //   );
  //
  // }

}

/// Prévisualisation image avec verrou du chemin local (évite le clignotement au swap id / rebuild).
class _LockedChatImagePreview extends StatefulWidget {
  const _LockedChatImagePreview({
    required this.message,
    required this.thumbHeight,
    required this.buildFullUrl,
  });

  final MessageEntity message;
  final double thumbHeight;
  final String Function(String? url) buildFullUrl;

  @override
  State<_LockedChatImagePreview> createState() =>
      _LockedChatImagePreviewState();
}

class _LockedChatImagePreviewState extends State<_LockedChatImagePreview> {
  String? _lockedLocalPath;

  void _refreshLock() {
    final String? localPath =
        widget.message.metadata?['localFilePath']?.toString();
    if (localPath != null &&
        localPath.isNotEmpty &&
        File(localPath).existsSync()) {
      _lockedLocalPath = localPath;
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshLock();
  }

  @override
  void didUpdateWidget(covariant _LockedChatImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshLock();
  }

  @override
  Widget build(BuildContext context) {
    final String? localPath =
        widget.message.metadata?['localFilePath']?.toString();
    final String? networkUrl = widget.message.mediaUrl;

    late final Widget mediaWidget;

    final pathForFile = (localPath != null &&
            localPath.isNotEmpty &&
            File(localPath).existsSync())
        ? localPath
        : (_lockedLocalPath != null &&
                _lockedLocalPath!.isNotEmpty &&
                File(_lockedLocalPath!).existsSync())
            ? _lockedLocalPath
            : null;

    if (pathForFile != null) {
      mediaWidget = Image.file(
        File(pathForFile),
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    } else if (networkUrl != null && networkUrl.isNotEmpty) {
      mediaWidget = CachedNetworkImage(
        imageUrl: widget.buildFullUrl(networkUrl),
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
      );
    } else {
      mediaWidget = Container(color: Colors.grey[300]);
    }

    return SizedBox(
      width: 115,
      height: widget.thumbHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: mediaWidget,
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = borderRadius.toRRect(rect);

    final paint = Paint()
      ..shader =  LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey.withOpacity(0.4), Colors.transparent],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}