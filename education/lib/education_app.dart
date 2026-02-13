import 'package:education/layout/responsive_layout.dart';
import 'package:education/presentations/home/desktop_home_page.dart';
import 'package:education/presentations/home/mobile_home_page.dart';
import 'package:education/presentations/home/tablet_home_page.dart';
import 'package:education/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EducationApp extends StatelessWidget {
  const EducationApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final title = 'Flutter Demo Home Page';
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_)=> ThemeProvider.instance
        ),
      ],
      builder: (context, widget){
        return  MaterialApp(
          title: 'Flutter Demo',
          theme: Provider.of<ThemeProvider>(context).currentThemeData,
          home: ResponsiveLayout(
            mobileBody: MobileHomePage(title: title),
            tabletBody: TabletHomePage(title: title),
            desktopBody: DesktopHomePage(title: title),
          ),
        );
      },
    );
  }
}
