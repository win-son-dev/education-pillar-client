import 'package:centralized_library/centralized_library.dart';

enum ThemeEnum {
  light,
  dark
}

class ThemeProvider extends ChangeNotifier
{
  ThemeEnum currentTheme = ThemeEnum.light;

  static const Color _seedColor = Color(0xFF261A00);

  ThemeData get currentThemeData => _buildThemeData();

  static ThemeProvider? _instance;
  static ThemeProvider get instance
  {
    _instance ??= ThemeProvider._init();
    return _instance!;
  }

  void changeTheme(ThemeEnum theme)
  {
    currentTheme = theme;
    notifyListeners();
  }

  ThemeData _buildThemeData()
  {
    final brightness = currentTheme == ThemeEnum.light ? Brightness.light : Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outline, width: 1.5),
        ),
        color: colorScheme.surface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.tertiary,
          foregroundColor: colorScheme.onTertiary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  ThemeProvider._init();
}
