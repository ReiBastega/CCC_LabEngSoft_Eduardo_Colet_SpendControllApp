import 'package:flutter/material.dart';

class AppColors {
  final bool isDarkMode;
  static AppColors? _instance;
  AppColors(this.isDarkMode);

  static AppColors of(BuildContext context) {
    final newTheme = Theme.of(context).brightness == Brightness.dark;
    if (_instance != null && _instance!.isDarkMode != newTheme) {
      _instance = AppColors(newTheme);
    } else {
      _instance ??= AppColors(newTheme);
    }
    return _instance!;
  }

  Color get primary => const Color.fromARGB(255, 25, 59, 152);

  Color get secondary => const Color.fromARGB(255, 55, 255, 0);
  Color get backgroundDark => const Color(0xFF161616);
  Color get backgroundLigth => Colors.white;
  Color get staraGreen => const Color(0xFF0A5F26);

  ({
    Color gray50,
    Color gray100,
    Color gray200,
    Color gray300,
    Color gray400,
    Color gray500,
    Color gray800,
    Color gray900,
    Color trueBlack,
    Color trueWhite
  }) get neutrals => (
        gray50: const Color(0xFFEBEBEB),
        gray100: const Color(0xFFC1C1C1),
        gray200: const Color(0xFFA3A3A3),
        gray300: const Color(0xFF7A7A79),
        gray400: const Color(0xFF60605F),
        gray500: const Color(0xFF383837),
        gray800: const Color(0xFF1F1F1E),
        gray900: const Color(0xFF161616),
        trueBlack: const Color(0xFF000000),
        trueWhite: const Color(0xFFFFFFFF)
      );

  ({
    Color orangeBrandDark2,
    Color orange100,
    Color orange200,
    Color orange500,
    Color orange700,
    Color orange800,
    Color green100,
    Color green300,
    Color green500,
    Color green800,
    Color greenBrandDark2
  }) get brand => (
        orangeBrandDark2: const Color(0xFFC6A68E),
        orange100: const Color(0xFFFAD9C2),
        orange200: const Color(0xFFF5B485),
        orange500: const Color(0xFFEB690B),
        orange700: const Color(0xFFA74B08),
        orange800: const Color(0xFF844314),
        green100: const Color(0xFFBFD5C8),
        green300: const Color(0xFF80AC92),
        green500: const Color(0xFF005924),
        green800: const Color(0xFF0F3B21),
        greenBrandDark2: const Color(0xFF879D90),
      );

  ({
    Color green100,
    Color green500,
    Color green900,
    Color yellow100,
    Color yellow500,
    Color redLight100,
    Color redLight500,
    Color redDark100,
    Color redDark500,
    Color redDark900,
    Color blue100,
    Color blue500,
    Color blue900,
  }) get other => (
        green100: const Color(0xFFC0EAD7),
        green500: const Color(0xFF06AB60),
        green900: const Color(0xFF034828),
        yellow100: const Color(0xFFFBE6B0),
        yellow500: const Color(0xFFF1AE00),
        redLight100: const Color(0xFFFFC5C2),
        redLight500: const Color(0xFFFF453A),
        redDark100: const Color(0xFFEFC9CA),
        redDark500: const Color(0xFFC0272D),
        redDark900: const Color(0xFF511013),
        blue100: const Color(0xFFC0D8EB),
        blue500: const Color(0xFF0465B2),
        blue900: const Color(0xFF022A4B),
      );

  Color get background1st => isDarkMode ? neutrals.gray900 : neutrals.trueWhite;
  Color get background2nd => brand.orange500;
  Color get background3rd => isDarkMode ? neutrals.gray800 : neutrals.gray50;
  Color get background4th => isDarkMode ? neutrals.gray400 : neutrals.gray100;
  Color get background2ndDsbld1 =>
      isDarkMode ? brand.orange800 : brand.orange200;
  Color get background2ndDsbld2 =>
      isDarkMode ? brand.orangeBrandDark2 : brand.orange100;
  Color get backgroundError =>
      isDarkMode ? other.redLight500 : other.redDark500;
  Color get backgroundSuccess => other.green500;
  Color get bgTransparencyBlue => isDarkMode ? other.blue900 : other.blue100;
  Color get bgTransparencyRed =>
      isDarkMode ? other.redDark900 : other.redDark100;
  Color get bgTransparencyGreen => isDarkMode ? other.green900 : other.green100;
  Color get bgTransparencyGray =>
      isDarkMode ? neutrals.gray500 : neutrals.gray50;
  Color get bgStateNeutral => isDarkMode ? neutrals.gray50 : neutrals.gray800;

  Color get foreground1st => isDarkMode ? neutrals.trueWhite : neutrals.gray800;
  Color get foreground1stDsbld =>
      isDarkMode ? neutrals.gray400 : neutrals.gray100;
  Color get foreground2nd => brand.orange500;
  Color get foreground3rd => neutrals.trueWhite;
  Color get foreground4th => isDarkMode ? neutrals.gray200 : neutrals.gray300;
  Color get foreground5th => isDarkMode ? neutrals.trueWhite : brand.orange500;
  Color get foreground5thDsbld =>
      isDarkMode ? neutrals.gray100 : brand.orange200;
  Color get foregroundRed => isDarkMode ? other.redLight500 : other.redDark500;
  Color get foregroundGreen => other.green500;
  Color get foregroundBlue => other.blue500;
  Color get fgApplicationOn =>
      isDarkMode ? neutrals.gray800 : neutrals.trueWhite;
  Color get fgApplicationOff =>
      isDarkMode ? neutrals.trueWhite : neutrals.gray800;

  Color get border1st => brand.orange500;
  Color get border1stDsbld => isDarkMode ? brand.orange800 : brand.orange200;
  Color get border2nd => neutrals.gray100;
  Color get border3rd => isDarkMode ? neutrals.gray500 : neutrals.gray300;
  Color get border4th => isDarkMode ? neutrals.gray500 : neutrals.gray100;
  Color get border5th =>
      isDarkMode ? const Color(0xFF383837) : const Color(0xFFEBEBEB);
  Color get borderGreen => other.green500;
  Color get borderRed => other.redDark500;
  Color get borderBlue => other.blue500;

  Color get separator => isDarkMode ? neutrals.gray400 : neutrals.gray100;

  Color get statusBw => isDarkMode ? neutrals.trueWhite : neutrals.trueBlack;
  Color get statusOrange => brand.orange500;
  Color get statusWhite => neutrals.trueWhite;
  Color get statusError => isDarkMode ? other.redLight500 : other.redDark500;
  Color get statusSelected =>
      isDarkMode ? neutrals.gray500 : neutrals.trueWhite;
}
