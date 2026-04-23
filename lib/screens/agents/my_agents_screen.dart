import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/agent_service.dart';

class MyAgentsScreen extends StatefulWidget {
  final String? token;
  
  const MyAgentsScreen({super.key, this.token});

  @override
  State<MyAgentsScreen> createState() => _MyAgentsScreenState();
}

class _MyAgentsScreenState extends State<MyAgentsScreen> {
  List<Agent> _agents = [];
  bool _loading = true;
  bool _initializing = false;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    setState(() => _loading = true);
    
    try {
      print('🔍 Loading agents from API...');
      
      final response = await AgentService.getAllAgents(token: widget.token);
      
      if (response.success) {
        setState(() {
          _agents = response.agents;
          _loading = false;
        });
        
        print('✅ Successfully loaded ${response.agents.length} agents');
      } else {
        print('❌ API call failed: ${response.error}');
        _showErrorSnackBar('Failed to load agents: ${response.error}');
        setState(() => _loading = false);
      }
      
    } catch (e) {
      print('❌ Error loading agents: $e');
      _showErrorSnackBar('Failed to load agents: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _initializeAgents() async {
    setState(() => _initializing = true);
    
    try {
      final result = await AgentService.initializeAgents(token: widget.token);
      
      if (result['success'] == true) {
        await _loadAgents();
        _showSuccessSnackBar('Agents initialized successfully!');
      } else {
        _showErrorSnackBar('Failed to initialize agents: ${result['error']}');
      }
    } catch (e) {
      print('❌ Error initializing agents: $e');
      _showErrorSnackBar('Failed to initialize agents: $e');
    } finally {
      setState(() => _initializing = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Agents',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadAgents,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _agents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No agents available',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _initializing ? null : _initializeAgents,
                        child: _initializing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Initialize Agents'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _agents.length,
                  itemBuilder: (context, index) {
                    final agent = _agents[index];
                    return _buildAgentCard(agent);
                  },
                ),
    );
  }

  Widget _buildAgentCard(Agent agent) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: agent.avatar != null
                      ? Image.network(
                          agent.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.smart_toy_outlined, color: Colors.blue),
                        )
                      : const Icon(Icons.smart_toy_outlined, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.displayName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        agent.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusBadge(agent),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 12),
            if (agent.specialties.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: agent.specialties
                    .take(3)
                    .map((specialty) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            specialty,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Agent agent) {
    final isReady = agent.isReady;
    final color = isReady ? Colors.green : Colors.orange;
    final statusText = isReady ? 'Ready' : 'Not Ready';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
