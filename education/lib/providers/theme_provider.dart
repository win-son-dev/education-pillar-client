import 'dart:convert';
import 'package:centralized_library/centralized_library.dart';

enum ThemeEnum {
  light,
  dark
}

class ThemeProvider extends ChangeNotifier
{
  ThemeEnum currentTheme = ThemeEnum.light;

  ThemeData? currentThemeData;

  static ThemeProvider? _instance;
  static ThemeProvider get instance
  {
    _instance ??= ThemeProvider._init();
    return _instance!;
  }

  Future<void> changeTheme(ThemeEnum theme) async
  {
    currentTheme = theme;
    await _setThemeData();
    notifyListeners();
  }

  Future<void> _setThemeData() async
  {
    String themeStr = await rootBundle.loadString(_getThemeJsonPath());
    final themeJson = jsonDecode(themeStr);
    currentThemeData = ThemeDecoder.instance.decodeThemeData(themeJson);
  }

  String _getThemeJsonPath()
  {
    switch(currentTheme)
    {
      case ThemeEnum.light:
        return "assets/themes/theme_light.json";
      case ThemeEnum.dark:
        return "assets/themes/theme_dark.json";
    }
  }
  ThemeProvider._init();

}