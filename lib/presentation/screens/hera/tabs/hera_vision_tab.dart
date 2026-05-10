import 'package:flutter/material.dart';

import 'package:e_team/domain/models/hera/hera_models.dart';
import 'package:e_team/presentation/widgets/hera/vision/hera_vision_widgets.dart';
import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

/// Vision tab — department density radar / staffing analysis.
/// All state lives in [_HeraDashboardPageState]; this widget is pure UI.
class HeraVisionTab extends StatelessWidget {
  final List<HeraEmployee> employees;

  const HeraVisionTab({super.key, required this.employees});

  // Static config — department capacity targets.
  static const Map<String, int> _deptMax = {
    'Tech': 20,
    'Design': 10,
    'Marketing': 15,
    'RH': 5,
    'Finance': 8,
    'Support': 12,
  };

  // Pure helper — no state access needed.
  int _countInDept(String dept) {
    return employees.where((emp) {
      return emp.department.toLowerCase() == dept.toLowerCase() &&
          emp.status == 'active';
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        HeraVisionHeaderCard(
          employeeCount: employees.length,
          departmentCount: _deptMax.length,
        ),
        const SizedBox(height: 24),
        const Text(
          'Densité par département',
          style: TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        ..._deptMax.entries.map((entry) {
          final count = _countInDept(entry.key);
          return HeraDepartmentDensityBar(
            department: entry.key,
            count: count,
            max: entry.value,
          );
        }),
        const SizedBox(height: 20),
        const HeraVisionInfoFooter(),
      ],
    );
  }
}
