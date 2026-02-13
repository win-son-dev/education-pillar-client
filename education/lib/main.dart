import 'package:education/providers/theme_provider.dart';
import 'package:flutter/material.dart';

import 'education_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeProvider.instance.changeTheme(ThemeEnum.light);
  runApp(const EducationApp());
}

