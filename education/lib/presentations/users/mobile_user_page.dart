import 'package:centralized_library/centralized_library.dart';

class MobileUserPage extends StatelessWidget {
  const MobileUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
          slivers: <Widget>[
          SliverAppBar(
            pinned:  true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('demo'),
            ),
          )
        ]
      )
    );
  }
}
