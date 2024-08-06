import 'package:chess/components/game_board.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Chess());
}

class Chess extends StatelessWidget {
  const Chess({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameBoard(),
    );
  }
}
