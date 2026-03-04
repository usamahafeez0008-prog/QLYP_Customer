import 'package:customer/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primarySwatch: Colors.red,
      useMaterial3: false,
      colorScheme: ColorScheme(
          brightness: isDarkTheme ? Brightness.dark : Brightness.light,
          primary: isDarkTheme ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
          onPrimary: isDarkTheme ? AppColors.lightsecondprimary : AppColors.darksecondprimary,
          secondary: isDarkTheme ? AppColors.darkBackground : AppColors.background,
          onSecondary: isDarkTheme ? AppColors.darkBackground : AppColors.background,
          error: isDarkTheme ? AppColors.darkBackground : AppColors.background,
          onError: isDarkTheme ? AppColors.darkBackground : AppColors.background,
          background: isDarkTheme ? AppColors.darkBackground : AppColors.background,
          onBackground: isDarkTheme ? AppColors.darkBackground : AppColors.background,
          surface: isDarkTheme ? AppColors.darkBackground : AppColors.background,
          onSurface: isDarkTheme ? AppColors.darkBackground : AppColors.background),
      primaryColor: isDarkTheme ? AppColors.lightsecondprimary : AppColors.darksecondprimary,
      hintColor: isDarkTheme ? Colors.white38 : Colors.black38,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      appBarTheme: AppBarTheme(centerTitle: true, iconTheme: const IconThemeData(color: Colors.white), titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
    );
  }
}
