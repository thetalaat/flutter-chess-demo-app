import 'package:chess/components/inverted_color_image.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final Piece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;

  const Square(
      {super.key,
      required this.isWhite,
      required this.piece,
      required this.isSelected,
      required this.isValidMove,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.green;
    } else if (isValidMove) {
      squareColor = Colors.green[200];
    } else {
      squareColor = isWhite ? foregroundColor : backgroundColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: squareColor,
            border: Border.all(
              color: isWhite ? foregroundColor! : backgroundColor!,
            )),
        child: Center(
          child: piece != null
              ? InvertedColorImage(
                  invertColor: !piece!.isWhite, imagePath: piece!.imagePath)
              : null,
        ),
      ),
    );
  }
}
