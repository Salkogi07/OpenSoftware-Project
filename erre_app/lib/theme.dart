import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFFFFFF); // 흰 배경
  static const Color primaryMint = Color(0xFFA8E6CF); // 파스텔 민트 (주 색상)
  static const Color deepNavy = Color(0xFF1B2A4A);    // 강조 / 중요한 버튼 (딥 네이비)
  static const Color accentOrange = Color(0xFFFF8C42); // 포인트 배지 (오렌지)
  static const Color selectedTab = Color(0xFF2E7D32);   // 선택된 메뉴 (초록색)
  static const Color unselectedTab = Color(0xFF9E9E9E); // 비선택 메뉴
  static const Color textBlack = Color(0xFF212121);
}

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  
  colorScheme: ColorScheme.light(
    surface: AppColors.background,
    primary: AppColors.primaryMint,
    secondary: AppColors.deepNavy,
    tertiary: AppColors.accentOrange,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.deepNavy,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.selectedTab, // 선택된 메뉴 초록색
    unselectedItemColor: AppColors.unselectedTab,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
    unselectedLabelStyle: TextStyle(fontSize: 12),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);