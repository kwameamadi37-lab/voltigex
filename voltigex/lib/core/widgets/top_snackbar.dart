import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/theme.dart';

enum TopSnackBarType {
  success,
  error,
}

abstract final class TopSnackBar {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context,
    String message, {
    TopSnackBarType type = TopSnackBarType.success,
    String? title,
    int durationSeconds = 4,
  }) {
    // Retirer le snackbar existant sans animation pour afficher immédiatement le nouveau
    _currentEntry?.remove();
    _currentEntry = null;

    final overlayState = Overlay.of(context, rootOverlay: true);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _AnimatedTopSnackBarWidget(
        message: message,
        title: title,
        type: type,
        durationSeconds: durationSeconds,
        onDismissed: () {
          if (_currentEntry == entry) {
            entry.remove();
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlayState.insert(entry);
  }
}

class _AnimatedTopSnackBarWidget extends StatefulWidget {
  final String message;
  final String? title;
  final TopSnackBarType type;
  final int durationSeconds;
  final VoidCallback onDismissed;

  const _AnimatedTopSnackBarWidget({
    required this.message,
    required this.type,
    required this.durationSeconds,
    required this.onDismissed,
    this.title,
  });

  @override
  State<_AnimatedTopSnackBarWidget> createState() => _AnimatedTopSnackBarWidgetState();
}

class _AnimatedTopSnackBarWidgetState extends State<_AnimatedTopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Animation de glissement : part de -100% en Y (au-dessus de l'écran) pour arriver à 0
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    // Lance l'animation d'entrée
    _controller.forward();

    // Programme la fermeture avec animation de sortie
    Future.delayed(Duration(seconds: widget.durationSeconds), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismissed();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.type == TopSnackBarType.success;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 10,
      right: 10,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  isSuccess
                      ? 'assets/images/svg/heureux.svg'
                      : 'assets/images/svg/triste.svg',
                  colorFilter: ColorFilter.mode(
                    isSuccess ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    BlendMode.srcIn,
                  ),
                  width: 22.5,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.title != null && widget.title!.isNotEmpty)
                        Text(
                          widget.title!,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1E3A5F),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      Text(
                        widget.message,
                        style: GoogleFonts.inter(
                          color: DefaultColors.black2Color,
                          fontWeight: FontWeight.w400,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}