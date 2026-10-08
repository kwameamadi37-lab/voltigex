import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FontSizes {
  static const small = 12.0;
  static const standard = 14.0;
  static const standardUp = 16.0;
  static const medium = 20.0;
  static const large = 28.0;
}

class DefaultColors {
  // static const Color greyText = Color(0xFFB3B9C9);
  static const Color greyText = Color(0xFF4b5563);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color blueBackground = Color(0xFF0A296B);
  static const Color scafoldColor = Color(0xFFF3F4F6);
  static const Color yellowBackground = Color(0xFFFFC800);
  static const Color blackColor = Colors.black87;
  static const Color black2Color = Color(0xFF757272);
  // static const Color senderMessage = Color(0xFF7A8194);
  static const Color senderMessage = Color(0xFF0A296B);
  // static const Color receiverMessage = Color(0xFF373E4E);
  static const Color receiverMessage = Color.fromARGB(255, 227, 228, 232);
  static const Color sentMessageInput = Color(0xFF3D4354);
  static const Color messageListPage = Color(0xFF292F3F);
  static const Color buttonColor = Color(0xFF7A8194);
  static const Color dailyQuestionColor = Colors.blueGrey;
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.white,
      // scaffoldBackgroundColor: DefaultColors.messageListPage,
      scaffoldBackgroundColor: DefaultColors.scafoldColor,
      /// Barre d’état : icônes sombres sur fond clair (cohérent avec le scaffold clair).
      /// Les [AppBar] peuvent surcharger localement (ex. chat blanc type Messenger).
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      textTheme: TextTheme(
        titleMedium: GoogleFonts.alegreyaSans(
          fontSize: FontSizes.medium,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.alegreyaSans(
          fontSize: FontSizes.large,
          color: Colors.white,
        ),
        bodySmall: GoogleFonts.alegreyaSans(
          fontSize: FontSizes.standardUp,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.alegreyaSans(
          fontSize: FontSizes.standard,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.alegreyaSans(
          fontSize: FontSizes.standardUp,
          color: Colors.white,
        ),
      ),
    );
  }
}

