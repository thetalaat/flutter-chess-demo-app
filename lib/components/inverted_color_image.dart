import 'package:flutter/material.dart';

class InvertedColorImage extends StatelessWidget {
  final bool invertColor;
  final String imagePath;
  const InvertedColorImage(
      {super.key, required this.invertColor, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: !invertColor
          ? const ColorFilter.matrix(<double>[
              1.0, 0.0, 0.0, 0.0, 0.0, //
              0.0, 1.0, 0.0, 0.0, 0.0, //
              0.0, 0.0, 1.0, 0.0, 0.0, //
              0.0, 0.0, 0.0, 1.0, 0.0, //
            ])
          : const ColorFilter.matrix(<double>[
              -1.0, 0.0, 0.0, 0.0, 255.0, //
              0.0, -1.0, 0.0, 0.0, 255.0, //
              0.0, 0.0, -1.0, 0.0, 255.0, //
              0.0, 0.0, 0.0, 1.0, 0.0, //
            ]),
      child: Image.asset(
        imagePath,
      ),
    );
  }
}
