import 'package:flutter/material.dart';

import 'di/service_locator.dart';
import 'education_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const EducationApp());
}
