import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // font per titoli
  static TextStyle title({Color color = Colors.black}) => GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: color,
    ),
  );

  // font per sottotitoli
  static TextStyle subtitle({Color color = Colors.black}) => GoogleFonts.outfit(
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w300,
      color: color,
    ),
  );

  // font per il corpo
  static TextStyle body({Color color = Colors.black}) => GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w200,
      color: color,
    ),
  );

  // font per bottoni
  static TextStyle buttons({Color color = Colors.black}) => GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color,
    ),
  );

  // font per link
  static TextStyle link({Color color = Colors.black}) => GoogleFonts.outfit(
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
    ),
  );
}
