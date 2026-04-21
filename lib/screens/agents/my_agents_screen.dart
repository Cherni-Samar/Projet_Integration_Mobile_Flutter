import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/agent_service.dart';

class MyAgentsScreen extends StatefulWidget {
  final String? token;
  
  const MyAgentsScreen({super.key, this.token});

  @override
  State<MyAgentsScreen> createState() => _MyAgentsScreenState();
}

class _MyAgentsScreenState extends State<MyAgentsScreen> {
  List<Agent> _agents = [];
  int _totalEnergy = 0;
  int _userEnergyBalance = 0;
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
      print('🔍 Loading agents and energy balance from API...');
      
      // Use the correct token for eya.mosbahi@esprit.tn user
      const correctToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5Y2MxOTAwNzM1ZTAwMDQxMjliZDliOCIsImVtYWlsIjoiZXlhLm1vc2JhaGlAZXNwcml0LnRuIiwiaWF0IjoxNzc2NjU1Nzc1LCJleHAiOjE3NzcyNjA1NzV9.g618Jb2u745mTUE0AqjQQ6NnZXyEV09RBRgQr_VG-zQ';
      
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/agents/energy/balance'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': correctToken, // Use the correct token
        },
      );
      
      print('🔍 API Response Status: ${response.statusCode}');
      print('🔍 API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];
          
          // Extract user energy balance
          final userEnergyBalance = data['userEnergyBalance'] ?? 0;
          final totalAgentEnergy = data['totalAgentEnergy'] ?? 0;
          
          // Extract agents data
          final agentsData = data['agents'] as List? ?? [];
          final agents = agentsData.map((agentJson) {
            return Agent(
              id: agentJson['id'] ?? '',
              name: agentJson['name'] ?? '',
              displayName: agentJson['displayName'] ?? '',
              description: 'AI Agent',
              energy: agentJson['energy'] ?? 0,
              maxEnergy: agentJson['maxEnergy'] ?? 200,
              energyPercentage: agentJson['energyPercentage'] ?? 0,
              status: 'active',
              readyStatus: 'ready',
              specialties: ['AI'],
              isReady: true,
            );
          }).toList();
          
          setState(() {
            _agents = agents;
            _userEnergyBalance = userEnergyBalance;
            _totalEnergy = totalAgentEnergy; // Use total agent energy (should be same as user energy now)
            _loading = false;
          });
          
          print('✅ Successfully loaded ${agents.length} agents');
          print('✅ User energy portfolio: $userEnergyBalance (synchronized with agent energy)');
          print('✅ Total agent energy: $totalAgentEnergy');
          print('✅ Synchronized: ${userEnergyBalance == totalAgentEnergy ? "YES" : "NO"}');
          
          return;
        }
      }
      
      // If API fails, show error
      print('❌ API call failed, status: ${response.statusCode}');
      _showErrorSnackBar('Failed to load agents: API error ${response.statusCode}');
      
    } catch (e) {
      print('❌ Error loading agents: $e');
      _showErrorSnackBar('Failed to load agents: $e');
    }
    
    setState(() => _loading = false);
  }
  
  Future<void> _loadEnergyBalance() async {
    try {
      // Use the correct token for eya.mosbahi@esprit.tn user
      const correctToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5Y2MxOTAwNzM1ZTAwMDQxMjliZDliOCIsImVtYWlsIjoiZXlhLm1vc2JhaGlAZXNwcml0LnRuIiwiaWF0IjoxNzc2NjU1Nzc1LCJleHAiOjE3NzcyNjA1NzV9.g618Jb2u745mTUE0AqjQQ6NnZXyEV09RBRgQr_VG-zQ';
      
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/agents/energy/balance'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': correctToken, // Use the correct token
        },
      );
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          setState(() {
            _userEnergyBalance = jsonData['data']['userEnergyBalance'] ?? 0;
            _totalEnergy = jsonData['data']['totalAgentEnergy'] ?? 0; // Use total agent energy
          });
          print('✅ Energy balance updated: $_userEnergyBalance (synchronized with agent energy)');
        }
      }
    } catch (e) {
      print('❌ Error loading energy balance: $e');
    }
  }

  Future<void> _initializeAgents() async {
    setState(() => _initializing = true);
    
    try {
      final result = await AgentService.initializeAgents(token: widget.token);
      
      if (result['success'] == true) {
        // Successfully initialized, reload agents
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

  Future<void> _buyEnergy() async {
    final amount = await _showEnergyPurchaseDialog();
    if (amount == null || amount <= 0) return;

    try {
      final result = await AgentService.buyEnergy(
        amount: amount,
        paymentMethod: 'stripe',
        token: widget.token,
      );

      if (result['success'] == true) {
        _showSuccessSnackBar('Successfully purchased $amount energy!');
        _loadEnergyBalance();
      } else {
        _showErrorSnackBar('Purchase failed: ${result['error']}');
      }
    } catch (e) {
      _showErrorSnackBar('Purchase failed: $e');
    }
  }

  Future<int?> _showEnergyPurchaseDialog() async {
    int selectedAmount = 100;
    
    return showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Buy Energy',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select amount of energy to purchase',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              const SizedBox(height: 20),
              
              // Amount selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$selectedAmount Energy',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      '\$${(selectedAmount * 0.10).toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Slider
              Slider(
                value: selectedAmount.toDouble(),
                min: 10,
                max: 1000,
                divisions: 99,
                activeColor: Colors.purple,
                onChanged: (value) {
                  setDialogState(() {
                    selectedAmount = value.round();
                  });
                },
              ),
              
              // Quick select buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [50, 100, 250, 500].map((amount) {
                  return OutlinedButton(
                    onPressed: () {
                      setDialogState(() {
                        selectedAmount = amount;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selectedAmount == amount 
                          ? Colors.purple.withOpacity(0.1) 
                          : null,
                      side: BorderSide(
                        color: selectedAmount == amount 
                            ? Colors.purple 
                            : Colors.grey,
                      ),
                    ),
                    child: Text(
                      '$amount',
                      style: TextStyle(
                        color: selectedAmount == amount 
                            ? Colors.purple 
                            : Colors.grey[600],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedAmount),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: Text('Buy \$${(selectedAmount * 0.10).toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
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
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _loading || _initializing
          ? _buildLoadingState()
          : _agents.isEmpty
              ? _buildEmptyState()
              : _buildAgentsList(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.purple),
          const SizedBox(height: 16),
          Text(
            _initializing ? 'Initializing agents...' : 'Loading agents...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No agents found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Initialize agents to get started',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializeAgents,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Initialize Agents'),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsList() {
    return Column(
      children: [
        // Debug info
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔍 Debug Info:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              Text('Agents loaded: ${_agents.length}'),
              Text('Total energy: $_totalEnergy'),
              if (_agents.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Agent energies:', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ..._agents.map((agent) => Text('${agent.displayName}: ${agent.energy}/${agent.maxEnergy}')),
              ],
            ],
          ),
        ),
        
        // Energy portfolio header
        _buildEnergyPortfolioHeader(),
        
        // Agents list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadAgents(); // Reload both agents and energy balance
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _agents.length,
              itemBuilder: (context, index) => _buildAgentCard(_agents[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyPortfolioHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB57BFF), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portefeuille d\'Energie',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$_userEnergyBalance ⚡',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _buyEnergy,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Acheter plus'),
              ),
            ],
          ),
          
          if (_userEnergyBalance > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, 
                      color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Available: $_userEnergyBalance energy',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAgentCard(Agent agent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Agent avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: _getAgentGradient(agent.name),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                agent.displayName[0],
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Agent info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      agent.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.more_horiz,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: agent.isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Active',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.bolt, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${agent.energy}', // Use real agent energy from API
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange, // Use orange color for energy
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Ready',
                        style: GoogleFonts.inter(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Energy bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Energy',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${agent.energy}/${agent.maxEnergy}', // Use real agent energy from API
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: agent.energy / agent.maxEnergy,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        agent.hasLowEnergy ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getAgentGradient(String agentName) {
    switch (agentName.toLowerCase()) {
      case 'dexo':
        return [Colors.blue, Colors.blueAccent];
      case 'timo':
        return [Colors.orange, Colors.deepOrange];
      case 'echo':
        return [Colors.purple, Colors.purpleAccent];
      case 'hera':
        return [Colors.indigo, Colors.indigoAccent];
      case 'kash':
        return [Colors.green, Colors.greenAccent];
      default:
        return [Colors.grey, Colors.grey[600]!];
    }
  }
}