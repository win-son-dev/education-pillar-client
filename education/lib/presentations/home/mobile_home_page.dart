import 'package:centralized_library/centralized_library.dart';


import '../../providers/theme_provider.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key, required this.title});


  final String title;

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider= Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () {
            if(themeProvider.currentTheme == ThemeEnum.light)
            {
              themeProvider.changeTheme(ThemeEnum.dark);
            }
            else
            {
              themeProvider.changeTheme(ThemeEnum.light);
            }
          },
              icon: Icon( themeProvider.currentTheme == ThemeEnum.light
                  ? Icons.light_mode
                  : Icons.dark_mode)
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}