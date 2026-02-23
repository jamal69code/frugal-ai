import 'package:flutter/material.dart';
import 'package:frugal_ai/app_storage.dart';
import 'package:intl/intl.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();

  final List<String> categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Bills',
    'Healthcare',
    'Education',
    'Other',
  ];

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Amount is required")));
      return;
    }

    try {
      double amount = double.parse(amountController.text);

      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        category: selectedCategory,
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : 'Manual entry',
        dateTime: selectedDate,
        notes: notesController.text,
        isSynced: false,
      );

      await AppStorage.addExpense(expense);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Expense Saved Successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("💰 Manual Entry"),
        backgroundColor: const Color(0xFF0F9D58),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 💵 Amount Field
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: "Amount (₹)",
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // 📂 Category Dropdown
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                underline: const SizedBox(),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            // 📝 Description Field
            TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Description",
                hintText: "What did you spend on?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // 📅 Date Picker
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Color(0xFF0F9D58)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 📄 Notes Field
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Additional Notes",
                hintText: "Any extra details?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            // 💾 Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9D58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveExpense,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Expense",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
