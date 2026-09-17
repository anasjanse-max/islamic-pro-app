import 'package:flutter/material.dart';

class AppSettings {
  static bool notificationsEnabled = true;
  static bool adhanEnabled = true;
  static bool vibrationEnabled = true;

  static final ValueNotifier<bool> darkModeNotifier =
  ValueNotifier<bool>(false);

  // Aladhan calculation methods
  // 1 = Karachi
  // 2 = ISNA
  // 3 = Muslim World League
  // 4 = Umm Al-Qura
  static int calculationMethod = 1;

  static String get calculationMethodName {
    switch (calculationMethod) {
      case 1:
        return 'Karachi';
      case 2:
        return 'ISNA';
      case 3:
        return 'Muslim World League';
      case 4:
        return 'Umm Al-Qura';
      default:
        return 'Karachi';
    }
  }

  static void setDarkMode(bool value) {
    darkModeNotifier.value = value;
  }

  static void setCalculationMethod(String method) {
    switch (method) {
      case 'Karachi':
        calculationMethod = 1;
        break;

      case 'ISNA':
        calculationMethod = 2;
        break;

      case 'MWL':
      case 'Muslim World League':
        calculationMethod = 3;
        break;

      case 'Umm Al-Qura':
        calculationMethod = 4;
        break;

      default:
        calculationMethod = 1;
    }
  }
}