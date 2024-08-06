import 'package:chess/components/inverted_color_image.dart';
import 'package:flutter/material.dart';

class DeadPiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;
  const DeadPiece({super.key, required this.imagePath, required this.isWhite});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Center(
          child:
              InvertedColorImage(invertColor: !isWhite, imagePath: imagePath)),
    );
  }
}
