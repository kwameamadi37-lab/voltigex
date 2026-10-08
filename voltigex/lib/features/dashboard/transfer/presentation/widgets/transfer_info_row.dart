import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/theme.dart';

Widget transferInfoRow(IconData icon, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size: 15.5,
        color: DefaultColors.greyText,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: DefaultColors.greyText,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
        ),
      ),
    ],
  );
}
