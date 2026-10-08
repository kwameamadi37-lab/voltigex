import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets/app_loader.dart';

Widget FormsButton({
  String? text,
  VoidCallback? onPressed,
  bool isBusy = false,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isBusy ? null : onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: DefaultColors.blueBackground,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 15)),
      child: isBusy
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: loader(compact: true, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  text ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 15.5),
                ),
              ],
            )
          : Text(
              text ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 15.5),
            ),
    ),
  );
}

// Déclarations de vos classes et constantes d'input formatters
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// Exemple de fonction buildLabeledTextField fonctionnelle et nettoyée
Widget BuildLabeledTextField({
  required String label,
  required String hintText,
  required TextEditingController controller,
  TextInputType inputType = TextInputType.text,
  String? suffix,
  Widget? suffixIcon,
  bool obscureText = false,
  bool isEditable = true,
  bool isDateField = false,
  bool isCardExpiryField = false, // <-- NOUVEAU
  bool isIbanField = false,
  bool isBicField = false,
  bool isUpercaseFormated = false,
  bool isCodeField = false,
  int? minLines,
  int? maxLines,
  String? Function(String?)? validator,
  VoidCallback? onTap,
}) {
  // readOnly est true uniquement si le champ n'est pas éditable OU si un onTap explicite est passé sans qu'il s'agisse d'une saisie MM/AA
  final isReadOnly = !isEditable || (onTap != null && !isCardExpiryField);

  return Container(
    padding: isCodeField
        ? const EdgeInsets.only(top: 12, bottom: 6, left: 12, right: 12)
        : null,
    decoration: BoxDecoration(
      color: isCodeField ? DefaultColors.blueBackground : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            textStyle: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              color: isCodeField ? Colors.white : DefaultColors.blackColor,
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          readOnly: isReadOnly,
          keyboardType: isCardExpiryField ? TextInputType.number : inputType,
          validator: validator,
          onTap: onTap,
          minLines: minLines,
          maxLines: maxLines ?? (obscureText ? 1 : null),
          textCapitalization: isIbanField || isBicField
              ? TextCapitalization.characters
              : TextCapitalization.none,
          style: GoogleFonts.inter(
            color: DefaultColors.blackColor,
            fontWeight: FontWeight.w400,
            fontSize: 15.0,
          ),
          inputFormatters: isCardExpiryField
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  CardMonthInputFormatter(),
                ]
              : isUpercaseFormated || isCodeField
                  ? [UpperCaseTextFormatter()]
                  : isIbanField
                      ? [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                          UpperCaseTextFormatter(),
                        ]
                      : null,
          decoration: InputDecoration(
            errorStyle:
                isCodeField ? const TextStyle(color: Colors.white) : null,
            suffixIcon: suffixIcon ??
                (suffix != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            suffix,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w400,
                              color: DefaultColors.blackColor,
                            ),
                          ),
                        ],
                      )
                    : null),
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            filled: true,
            fillColor: DefaultColors.receiverMessage,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(0xFFD1D5DB), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: isEditable
                ? OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: DefaultColors.blueBackground, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  )
                : OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFFD1D5DB), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
          ),
        ),
      ],
    ),
  );
}

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonOnlyDigits = i + 1;
      if (nonOnlyDigits % 2 == 0 && nonOnlyDigits != newText.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// class _DateInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     var text = newValue.text;
//     if (text.length >= 3 && text[2] != '/') {
//       text = '${text.substring(0, 2)}/${text.substring(2)}';
//     }
//     if (text.length >= 6 && text[5] != '/') {
//       text = '${text.substring(0, 5)}/${text.substring(5)}';
//     }
//     return TextEditingValue(
//       text: text,
//       selection: TextSelection.collapsed(offset: text.length),
//     );
//   }
// }

// class UpperCaseTextFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     return newValue.copyWith(
//       text: newValue.text.toUpperCase(),
//       selection: newValue.selection,
//     );
//   }
// }

class IbanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(' ', '').toUpperCase();

    StringBuffer newText = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      newText.write(text[i]);
      if ((i == 3 || (i > 3 && (i - 3) % 4 == 0)) && i != text.length - 1) {
        newText.write(' ');
      }
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
