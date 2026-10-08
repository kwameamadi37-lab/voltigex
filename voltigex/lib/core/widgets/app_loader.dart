import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:voltigex/core/theme.dart';

/// Loader global (points étirés). [compact] : sans [Center] ni padding, pour boutons / lignes.
Widget loader({
  Color? color,
  bool compact = false,
  double size = 21.5,
}) {
  final anim = LoadingAnimationWidget.stretchedDots(
    color: color ?? DefaultColors.blueBackground,
    size: size,
  );
  if (compact) {
    return anim;
  }
  return Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: anim,
    ),
  );
}

Widget softLoader({
  Color? color,
  double size = 21.5,
}) {
  return Center(
    child: LoadingAnimationWidget.horizontalRotatingDots(
      color: color ?? DefaultColors.blueBackground,
      size: size,
    ),
  );
}
