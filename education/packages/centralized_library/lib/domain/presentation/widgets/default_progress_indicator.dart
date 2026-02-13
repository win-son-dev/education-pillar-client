import 'package:flutter/material.dart';
import '../../../centralized_library.dart';

class DefaultProgressIndicator extends StatelessWidget {
  const DefaultProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/loading/bouncing_balls_loading.json',
      package: 'centralized_library',
      width: 150,
      height: 150,
      fit: BoxFit.contain,
      repeat: true,        // Loop animation
      animate: true,       // Auto-play
      reverse: false,      // Play forward
    );
  }
}
