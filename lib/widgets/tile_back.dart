import 'package:flutter/material.dart';

class TileBackWidget extends StatelessWidget {
  final double width;
  final double height;

  const TileBackWidget({
    super.key,
    this.width = 60,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.asset(
          'assets/adinkra tile back tile.png',
          width: width,
          height: height,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
