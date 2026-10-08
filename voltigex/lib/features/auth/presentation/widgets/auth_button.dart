import 'package:flutter/material.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets/app_loader.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isBusy;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isBusy ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: DefaultColors.blueBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: isBusy
          ? SizedBox(
              height: 22,
              width: 22,
              child: FittedBox(
                fit: BoxFit.contain,
                child: loader(compact: true, color: Colors.white, size: 22),
              ),
            )
          : Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
    );
  }
}
