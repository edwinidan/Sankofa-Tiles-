import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme/app_colors.dart';

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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tileBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.tileEdge,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Colors.black38,
            offset: Offset(2, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: SvgPicture.asset(
          'assets/tiles/tile_back.svg',
          width: width,
          height: height,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
