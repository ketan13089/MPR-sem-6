import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final String imagePath;
  final double maxImageHeight;

  const ImageDisplay({
    super.key,
    required this.imagePath,
    required this.maxImageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxImageHeight,
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}