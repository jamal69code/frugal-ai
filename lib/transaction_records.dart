import 'package:flutter/material.dart';
import 'manual_entry_screen.dart';
import 'transaction_history_screen.dart';

class TransactionRecords extends StatefulWidget {
  const TransactionRecords({super.key});

  @override
  State<TransactionRecords> createState() => _TransactionRecordsState();
}

class _TransactionRecordsState extends State<TransactionRecords>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Records'),
        backgroundColor: Colors.green,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Manual Entries'),
            Tab(icon: Icon(Icons.history), text: 'Transaction History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ManualEntryScreen(), TransactionHistoryScreen()],
      ),
    );
  }
}
