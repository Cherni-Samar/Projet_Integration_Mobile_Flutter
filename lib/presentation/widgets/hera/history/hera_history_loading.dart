import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/hera/history/hera_history_config.dart';

class HeraHistoryLoadingMoreIndicator extends StatelessWidget {
  const HeraHistoryLoadingMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: AppLoadingIndicator(color: HeraHistoryTheme.lime),
      ),
    );
  }
}
