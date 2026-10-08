import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:voltigex/core/timeago.dart';

/// Affiche un timeago qui se met à jour seul (timer local, pas de rebuild de la page entière).
class ConversationTimeAgo extends StatefulWidget {
  final DateTime utcTime;
  final TextStyle? style;

  const ConversationTimeAgo({
    super.key,
    required this.utcTime,
    this.style,
  });

  @override
  State<ConversationTimeAgo> createState() => _ConversationTimeAgoState();
}

class _ConversationTimeAgoState extends State<ConversationTimeAgo> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = widget.utcTime.toLocal();
    final tag = appTimeagoLocaleForLanguageCode(
      Localizations.localeOf(context).languageCode,
    );
    return Text(
      timeago.format(local, locale: tag),
      style: widget.style ?? const TextStyle(color: Colors.grey),
    );
  }
}
