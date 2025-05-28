import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // font per titoli con poppins
  static TextStyle title1({Color color = Colors.black}) => GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: color,
    ),
  );
  // font per titoli con poppins
  static TextStyle title2({Color color = Colors.black}) => GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: color,
    ),
  );

  // font per titoli con CalSans
  static TextStyle title({Color color = Colors.black}) => TextStyle(
    fontFamily: 'CalSans',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: color,
  );

  // font per sottotitoli (outfit)
  static TextStyle subtitle({Color color = Colors.black}) => GoogleFonts.outfit(
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w300,
      color: color,
    ),
  );

  // font per il corpo (poppins)
  static TextStyle body({Color color = Colors.black}) => GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w200,
      color: color,
    ),
  );

  // font per link e/o corpo
  static TextStyle link({Color color = Colors.black}) => GoogleFonts.outfit(
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
    ),
  );

  // font per bottoni (poppins)
  static TextStyle buttons({Color color = Colors.black}) => GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color,
    ),
  );
}
