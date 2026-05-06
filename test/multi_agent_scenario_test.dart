import 'package:flutter/material.dart';

/// Multi-Agent Collaboration Test UI
/// Demonstrates the "Employee Performance Drop + Contract Renewal + Sensitive Document Update" scenario
class MultiAgentScenarioTest extends StatefulWidget {
  const MultiAgentScenarioTest({super.key});

  @override
  State<MultiAgentScenarioTest> createState() => _MultiAgentScenarioTestState();
}

class _MultiAgentScenarioTestState extends State<MultiAgentScenarioTest> {
  bool _isRunning = false;
  final List<ScenarioStep> _steps = [];
  final Map<String, List<AgentAction>> _agentActions = {
    'echo': [],
    'hera': [],
    'dexo': [],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-Agent Scenario Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScenarioHeader(),
            SizedBox(height: 20),
            _buildControlPanel(),
            SizedBox(height: 20),
            if (_steps.isNotEmpty) _buildStepsTimeline(),
            SizedBox(height: 20),
            if (_agentActions.values.any((actions) => actions.isNotEmpty))
              _buildAgentActivitySummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioHeader() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.deepPurple, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Multi-Agent Collaboration Scenario',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '🧩 Context: Employee Performance Drop + Contract Renewal + Sensitive Document Update',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'This scenario tests complex multi-agent collaboration where Echo, Hera, and Dexo work together to handle a contract renewal with performance concerns.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            _buildScenarioDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioDetails() {
    return ExpansionTile(
      title: Text('Scenario Details'),
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem(
                '👤 Employee',
                'Sara Johnson - Contract expires in 30 days',
              ),
              _buildDetailItem(
                '📉 Performance',
                'Score dropped from 4.2 to 2.5 (-40%)',
              ),
              _buildDetailItem(
                '📧 Trigger',
                'Manager requests contract renewal',
              ),
              _buildDetailItem(
                '📄 Document',
                'New performance evaluation uploaded',
              ),
              _buildDetailItem(
                '🚨 Challenge',
                'Performance decline requires HR escalation',
              ),
              _buildDetailItem(
                '🎯 Outcome',
                'Coordinated renewal with improvement plan',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runScenario,
                    icon: _isRunning
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.play_arrow),
                    label: Text(
                      _isRunning
                          ? 'Running Scenario...'
                          : 'Run Multi-Agent Scenario',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _clearResults,
                  icon: Icon(Icons.clear),
                  label: Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
            if (_isRunning) ...[
              SizedBox(height: 16),
              LinearProgressIndicator(),
              SizedBox(height: 8),
              Text(
                'Agents are collaborating...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepsTimeline() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scenario Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ..._steps.map((step) => _buildStepItem(step)),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(ScenarioStep step) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: step.completed ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.stepNumber.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: TextStyle(fontWeight: FontWeight.w600)),
                if (step.description.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    step.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
                if (step.agentsInvolved.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: step.agentsInvolved
                        .map(
                          (agent) => Chip(
                            label: Text(agent.toUpperCase()),
                            backgroundColor: _getAgentColor(agent),
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (step.completed)
            Icon(Icons.check_circle, color: Colors.green)
          else if (step.inProgress)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildAgentActivitySummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agent Activity Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ..._agentActions.entries.map(
              (entry) => _buildAgentSummary(entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentSummary(String agentName, List<AgentAction> actions) {
    if (actions.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getAgentColor(agentName),
          child: Text(
            agentName.substring(0, 1).toUpperCase(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${agentName.toUpperCase()} Agent',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${actions.length} actions performed'),
        children: actions
            .map(
              (action) => ListTile(
                dense: true,
                leading: Icon(
                  Icons.arrow_right,
                  color: _getAgentColor(agentName),
                ),
                title: Text(action.actionType),
                subtitle: Text(action.description),
                trailing: Text(
                  _formatTime(action.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Color _getAgentColor(String agentName) {
    switch (agentName.toLowerCase()) {
      case 'echo':
        return Colors.purple;
      case 'hera':
        return Colors.pink;
      case 'dexo':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _runScenario() async {
    setState(() {
      _isRunning = true;
      _steps.clear();
      _agentActions.clear();
    });

    try {
      // Simulate the 7-step scenario
      await _simulateStep1();
      await _simulateStep2();
      await _simulateStep3();
      await _simulateStep4();
      await _simulateStep5();
      await _simulateStep6();
      await _simulateStep7();

      _showCompletionDialog();
    } catch (error) {
      _showErrorDialog(error.toString());
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _simulateStep1() async {
    setState(() {
      _steps.add(
        ScenarioStep(
          stepNumber: 1,
          title: 'Manager sends contract renewal message',
          description: 'Echo analyzes message and extracts priority tasks',
          agentsInvolved: ['echo'],
          inProgress: true,
        ),
      );
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _steps.last.completed = true;
      _steps.last.inProgress = false;
      _agentActions['echo']!.add(
        AgentAction(
          actionType: 'analyze_message',
          description: 'Detected high priority contract renewal request',
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _simulateStep2() async {
    setState(() {
      _steps.add(
        ScenarioStep(
          stepNumber: 2,
          title: 'Hera processes contract renewal task',
          description:
              'Checks contract status and performance, applies HR rules',
          agentsInvolved: ['hera'],
          inProgress: true,
        ),
      );
    });

    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _steps.last.completed = true;
      _steps.last.inProgress = false;
      _agentActions['hera']!.add(
        AgentAction(
          actionType: 'process_contract_renewal',
          description:
              'Identified performance decline, requested manager justification',
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _simulateStep3() async {
    setState(() {
      _steps.add(
        ScenarioStep(
          stepNumber: 3,
          title: 'Manager uploads performance evaluation',
          description: 'Dexo classifies document, Echo extracts tasks',
          agentsInvolved: ['dexo', 'echo'],
          inProgress: true,
        ),
      );
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _steps.last.completed = true;
      _steps.last.inProgress = false;
      _agentActions['dexo']!.add(
        AgentAction(
          actionType: 'classify_document',
          description:
              'Classified as confidential HR document, applied access controls',
          timestamp: DateTime.now(),
        ),
      );
      _agentActions['echo']!.add(
        AgentAction(
          actionType: 'extract_tasks',
          description:
              'Extracted performance review and improvement plan tasks',
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _simulateStep4() async {
    setState(() {
      _steps.add(
        ScenarioStep(
          stepNumber: 4,
          title: 'Hera re-evaluates with new document',
          description: 'Assesses burnout risk and escalates to HR manager',
          agentsInvolved: ['hera'],
          inProgress: true,
        ),
      );
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _steps.last.completed = true;
      _steps.last.inProgress = false;
      _agentActions['hera']!.add(
        AgentAction(
          actionType: 'assess_burnout_risk',
          description: 'Flagged high burnout risk, recommended intervention',
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _simulateStep5() async {
    setState(() {
      _steps.add(
        ScenarioStep(
          stepNumber: 5,
          title: 'Manager provides justification',
          description: 'Echo summarizes, Hera validates and approves renewal',
          agentsInvolved: ['echo', 'hera'],
          inProgress: true,
        ),
      );
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _steps.last.completed = true;
      _steps.last.inProgress = false;
      _agentActions['echo']!.add(
        AgentAction(
          actionType: 'summarize_justification',
          description: 'Summarized manager justification for renewal',
          timestamp: DateTime.now(),
        ),
      );
      _agentActions['hera']!.add(
        AgentAction(
          actionType: 'approve_renewal',
          description:
              'Approved renewal with performance improvement conditions',
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _simulateStep6() async {
    setState(() {
      _steps.add(
        ScenarioStep(
          stepNumber: 6,
          title: 'Dexo generates new contract',
          description: 'Auto-generates contract with security and versioning',
          agentsInvolved: ['dexo'],
          inProgress: true,
        ),
      );
    });

    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _steps.last.completed = true;
      _steps.last.inProgress = false;
      _agentActions['dexo']!.add(
        AgentAction(
          actionType: 'generate_contract',
          description: 'Generated Contract_Sara_Johnson_2026_Renewal_v3.pdf',
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _simulateStep7() async {
    setState(() {
      _steps.add(
        ScenarioStep(
          stepNumber: 7,
          title: 'Echo sends final communications',
          description: 'Notifies all parties and creates communication digest',
          agentsInvolved: ['echo'],
          inProgress: true,
        ),
      );
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _steps.last.completed = true;
      _steps.last.inProgress = false;
      _agentActions['echo']!.add(
        AgentAction(
          actionType: 'send_notifications',
          description: 'Sent notifications to employee, HR, and manager',
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _clearResults() {
    setState(() {
      _steps.clear();
      _agentActions.clear();
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Scenario Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎉 Multi-agent collaboration successful!'),
            SizedBox(height: 12),
            Text(
              'Key outcomes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Contract renewal approved with conditions'),
            Text('• Performance improvement plan activated'),
            Text('• Burnout risk identified and escalated'),
            Text('• All stakeholders notified appropriately'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Scenario Failed'),
          ],
        ),
        content: Text('Error: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ScenarioStep {
  final int stepNumber;
  final String title;
  final String description;
  final List<String> agentsInvolved;
  bool completed;
  bool inProgress;

  ScenarioStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.agentsInvolved,
    this.completed = false,
    this.inProgress = false,
  });
}

class AgentAction {
  final String actionType;
  final String description;
  final DateTime timestamp;

  AgentAction({
    required this.actionType,
    required this.description,
    required this.timestamp,
  });
}
