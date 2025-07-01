import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants.dart';

class ShimmerWeatherCard extends StatelessWidget {
  const ShimmerWeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withAlpha(51),
      highlightColor: Colors.white.withAlpha(102),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(38),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(77),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppConstants.paddingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 20,
                    color: Colors.white.withAlpha(77),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 16,
                    color: Colors.white.withAlpha(51),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 28,
              color: Colors.white.withAlpha(77),
            ),
          ],
        ),
      ),
    );
  }
} 