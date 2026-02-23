import 'package:flutter/material.dart';
import 'package:frugal_ai/app_storage.dart';

class InvestmentTracker extends StatefulWidget {
  const InvestmentTracker({super.key});

  @override
  State<InvestmentTracker> createState() => _InvestmentTrackerState();
}

class _InvestmentTrackerState extends State<InvestmentTracker> {
  final TextEditingController _investmentController = TextEditingController();
  final TextEditingController _investmentNameController =
      TextEditingController();

  double totalSavings = 25400.00;
  double investedAmount = 5200.00;
  List<Map<String, dynamic>> investments = [
    {
      'name': 'Stocks Portfolio',
      'amount': 2500.00,
      'returnRate': 8.5,
      'date': '2025-10-20',
    },
    {
      'name': 'Mutual Funds',
      'amount': 1800.00,
      'returnRate': 6.2,
      'date': '2025-11-15',
    },
    {
      'name': 'Fixed Deposit',
      'amount': 900.00,
      'returnRate': 4.5,
      'date': '2025-12-01',
    },
  ];

  @override
  void initState() {
    super.initState();
    loadInvestments();
  }

  Future<void> loadInvestments() async {
    // Load data from storage if available
    String? savingsData = await AppStorage.getStorageValue("totalSavings");
    if (savingsData != null) {
      setState(() {
        totalSavings = double.parse(savingsData);
      });
    }
  }

  void addInvestment() {
    if (_investmentNameController.text.isEmpty ||
        _investmentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    double amount = double.tryParse(_investmentController.text) ?? 0;
    if (amount > totalSavings - investedAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Insufficient available funds")),
      );
      return;
    }

    setState(() {
      investments.add({
        'name': _investmentNameController.text,
        'amount': amount,
        'returnRate': 5.0,
        'date': DateTime.now().toString().split(' ')[0],
      });
      investedAmount += amount;
    });

    _investmentController.clear();
    _investmentNameController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Investment added successfully")),
    );
  }

  void deleteInvestment(int index) {
    setState(() {
      investedAmount -= investments[index]['amount'];
      investments.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Investment removed")));
  }

  @override
  Widget build(BuildContext context) {
    double availableFunds = totalSavings - investedAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Tracker'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Cards
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  // Total Savings Card
                  Card(
                    elevation: 3,
                    color: const Color(0xFF0F9D58),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Savings",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "\$${totalSavings.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Investment Summary Row
                  Row(
                    children: [
                      // Invested Amount
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Invested",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "\$${investedAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Available Funds
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Available",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "\$${availableFunds.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Investments List
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "My Investments",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  investments.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.trending_up,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "No investments yet",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Start investing your savings to grow your wealth",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: investments.length,
                          itemBuilder: (context, index) {
                            final investment = investments[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.trending_up,
                                    color: Colors.green,
                                  ),
                                ),
                                title: Text(investment['name']),
                                subtitle: Text(
                                  "Return: ${investment['returnRate']}% | Date: ${investment['date']}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: SizedBox(
                                  width: 120,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "\$${investment['amount'].toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          deleteInvestment(index);
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Add Investment"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _investmentNameController,
                      decoration: InputDecoration(
                        labelText: "Investment Name",
                        hintText: "e.g., Stocks, Bonds, Crypto",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _investmentController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        hintText: "Enter amount",
                        prefixText: "\$",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Available to invest: \$${availableFunds.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: addInvestment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Add"),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _investmentController.dispose();
    _investmentNameController.dispose();
    super.dispose();
  }
}
