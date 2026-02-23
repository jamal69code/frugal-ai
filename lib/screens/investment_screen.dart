import 'package:flutter/material.dart';
import 'package:frugal_ai/backend/backend.dart';

/// 📈 Investment Tracking Screen
class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final InvestmentService _investmentService = InvestmentService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _investments = [];
  Map<String, dynamic> _portfolio = {};

  @override
  void initState() {
    super.initState();
    _loadInvestmentData();
  }

  Future<void> _loadInvestmentData() async {
    try {
      final investments = await _investmentService.getUserInvestments();
      final portfolio = await _investmentService.getPortfolioSummary();

      if (mounted) {
        setState(() {
          _investments = investments;
          _portfolio = portfolio;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading investments: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===== ADD INVESTMENT =====
  void _showAddInvestmentDialog() {
    final typeController = TextEditingController();
    final symbolController = TextEditingController();
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    final apiKeyController = TextEditingController();

    final types = ['stock', 'crypto', 'mutual_fund', 'fds'];
    var selectedType = types[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('📈 Add Investment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField(
                  value: selectedType,
                  items: types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedType = value ?? types[0]),
                  decoration: InputDecoration(
                    labelText: 'Investment Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: symbolController,
                  decoration: InputDecoration(
                    labelText: 'Symbol (e.g., AAPL, BTC)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Investment Amount (₹)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Current Price (₹)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await _investmentService.addInvestment(
                  type: selectedType,
                  symbol: symbolController.text,
                  name: nameController.text,
                  amount: double.parse(amountController.text),
                  currentPrice: double.parse(priceController.text),
                  quantity: int.parse(quantityController.text),
                  apiKey: apiKeyController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '✅ Investment added'
                            : '❌ Failed to add investment',
                      ),
                    ),
                  );
                  if (success) _loadInvestmentData();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📈 My Investments'),
        backgroundColor: const Color(0xFF0F9D58),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 📊 Portfolio Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F9D58), Color(0xFF2E7D32)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Portfolio Value',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹ ${(_portfolio['totalCurrentValue'] ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Invested',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹ ${(_portfolio['totalInvested'] ?? 0).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total Returns',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹ ${(_portfolio['totalReturns'] ?? 0).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color:
                                          (_portfolio['totalReturns'] ?? 0) >= 0
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Return %',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(_portfolio['percentageReturn'] ?? 0).toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color:
                                          (_portfolio['percentageReturn'] ??
                                                  0) >=
                                              0
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ➕ Add Investment Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _showAddInvestmentDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Investment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 📋 Investments List
                    if (_investments.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Text('📈', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              'No investments yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _investments.length,
                        itemBuilder: (context, index) {
                          final inv = _investments[index];
                          final returns = (inv['returns'] ?? 0).toDouble();
                          final isPositive = returns >= 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    '📊',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              title: Text(
                                inv['name'] ?? 'Investment',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '₹${(inv['currentPrice'] ?? 0).toStringAsFixed(2)} × ${inv['quantity']}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${returns.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isPositive
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(inv['percentageChange'] ?? 0).toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: isPositive
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
