import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/theme.dart';

/// « En train d'écrire… » + trois points animés (sans Lottie).
class TypingDotsIndicator extends StatefulWidget {
  const TypingDotsIndicator({super.key});

  @override
  State<TypingDotsIndicator> createState() => _TypingDotsIndicatorState();
}

class _TypingDotsIndicatorState extends State<TypingDotsIndicator> {
  int _tick = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) setState(() => _tick = (_tick + 1) % 3);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'En train d\'écrire',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: DefaultColors.blueBackground.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(width: 2),
        ...List.generate(3, (i) {
          final active = i <= _tick;
          return Padding(
            padding: const EdgeInsets.only(left: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? DefaultColors.blueBackground
                    : DefaultColors.blueBackground.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ],
    );
  }
}
