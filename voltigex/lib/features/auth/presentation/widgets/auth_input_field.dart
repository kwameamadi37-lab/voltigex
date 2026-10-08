import 'package:flutter/material.dart';
import 'package:voltigex/core/theme.dart';

class AuthInputField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;

  const AuthInputField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  // Variable locale pour suivre la visibilité du texte
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // Initialise avec la valeur reçue en paramètre (true si c'est un mot de passe)
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DefaultColors.blueBackground, width: 0.35),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            color: DefaultColors.blackColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              obscureText: _obscureText,
              // Assure l'alignement vertical au centre
              textAlignVertical: widget.isPassword ? TextAlignVertical.center : null,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: DefaultColors.blackColor.withOpacity(0.65),
                ),
                border: InputBorder.none,
                // Si isPassword est true, on ajoute l'icône à la fin
                suffixIcon: widget.isPassword
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        // constraints: const BoxConstraints(), // Retire le rembourrage excessif de l'IconButton
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: DefaultColors.blackColor.withOpacity(0.65),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                    : null,
              ),
              style: TextStyle(color: DefaultColors.blackColor),
            ),
          ),
        ],
      ),
    );
  }
}