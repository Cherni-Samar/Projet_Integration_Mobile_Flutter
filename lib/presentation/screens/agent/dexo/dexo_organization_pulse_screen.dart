import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_team/data/services/dexo_service.dart';
import 'package:e_team/presentation/models/dexo/department_pulse_view_model.dart';
import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/presentation/widgets/dexo/organization_pulse/dexo_organization_pulse_widgets.dart';

class DexoOrganizationPulseScreen extends StatefulWidget {
  const DexoOrganizationPulseScreen({super.key});

  @override
  State<DexoOrganizationPulseScreen> createState() =>
      _DexoOrganizationPulseScreenState();
}

class _DexoOrganizationPulseScreenState
    extends State<DexoOrganizationPulseScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  Timer? _debounce;

  List<DepartmentPulseViewModel> _departments = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromUser();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadFromUser() async {
    setState(() => _isLoading = true);

    await context.read<UserProvider>().refreshFromApi();

    if (!mounted) return;

    final user = context.read<UserProvider>().user;

    final settings = user?.workforceSettings ?? [];

    setState(() {
      _departments = settings
          .map(
            (s) => DepartmentPulseViewModel(
              name: s.department,
              targetCount: s.targetCount,
              currentCount: s.currentCount,
            ),
          )
          .toList();

      _isLoading = false;
    });
  }

  void _updateTarget(DepartmentPulseViewModel department, double value) {
    setState(() {
      department.targetCount = value.round().clamp(0, 99);
    });

    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 900), _saveVisionAuto);
  }

  Future<void> _saveVisionAuto() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    final userProvider = context.read<UserProvider>();

    try {
      final response = await DexoService.updateWorkforceSettings({
        'workforceSettings': _departments.map((d) {
          return {
            'department': d.name,
            'targetCount': d.targetCount,
            'currentCount': d.currentCount,
          };
        }).toList(),
      });

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Save failed');
      }

      await userProvider.refreshFromApi();
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  int get _totalTarget => _departments.fold(0, (sum, d) => sum + d.targetCount);

  int get _totalCurrent =>
      _departments.fold(0, (sum, d) => sum + d.currentCount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DexoOrganizationPulseColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            DexoOrganizationPulseHeader(
              isSaving: _isSaving,
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: DexoOrganizationPulseColors.dark,
                      ),
                    )
                  : DexoOrganizationPulseList(
                      departments: _departments,
                      totalCurrent: _totalCurrent,
                      totalTarget: _totalTarget,
                      onRefresh: _loadFromUser,
                      onTargetChanged: (change) =>
                          _updateTarget(change.department, change.value),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
