import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/pricing/pricing_colors.dart';

class PricingProcessingOverlay extends StatelessWidget {
  final bool isVisible;

  const PricingProcessingOverlay({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.35),
          child: const Center(
            child: AppLoadingIndicator(color: PricingColors.volt),
          ),
        ),
      ),
    );
  }
}
