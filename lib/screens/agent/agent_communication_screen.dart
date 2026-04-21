import 'package:flutter/material.dart';
import '../../services/echo_service.dart';
import '../../services/hr_agent_service.dart';

class AgentCommunicationScreen extends StatefulWidget {
  final String? token;
  final String fromAgent; // 'echo' ou 'hera'

  const AgentCommunicationScreen({
    super.key,
    this.token,
    required this.fromAgent,
  });

  @override
  State<AgentCommunicationScreen> createState() => _AgentCommunicationScreenState();
}

class _AgentCommunicationScreenState extends State<AgentCommunicationScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isSending = false;
  String _resultMessage = '';

  Future<void> _sendEmail() async {
    if (_subjectController.text.isEmpty || _contentController.text.isEmpty) {
      setState(() {
        _resultMessage = 'Veuillez remplir le sujet et le contenu';
      });
      return;
    }

    setState(() {
      _isSending = true;
      _resultMessage = '';
    });

    Map<String, dynamic> response;

    if (widget.fromAgent == 'echo') {
      response = await EchoService.sendEmailToHera(
        subject: _subjectController.text,
        content: _contentController.text,
        from: 'echo@e-team.com',
        token: widget.token,
      );
    } else {
      response = await HrAgentService.sendEmailToEcho(
        subject: _subjectController.text,
        content: _contentController.text,
        from: 'hera@e-team.com',
      );
    }

    setState(() {
      _isSending = false;
      if (response['success'] == true) {
        _resultMessage = '✅ Email envoyé avec succès !';
        _subjectController.clear();
        _contentController.clear();
      } else {
        _resultMessage = '❌ Erreur: ${response['error'] ?? 'Envoi échoué'}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEcho = widget.fromAgent == 'echo';
    final agentName = isEcho ? 'Echo → Hera' : 'Hera → Echo';
    final agentColor = isEcho ? Colors.deepPurple : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: Text(agentName),
        backgroundColor: agentColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Sujet',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.subject),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Contenu du message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.message),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: agentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Envoyer à ${isEcho ? 'Hera' : 'Echo'}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (_resultMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _resultMessage.contains('✅')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _resultMessage,
                  style: TextStyle(
                    color: _resultMessage.contains('✅')
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
