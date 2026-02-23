import 'package:flutter/material.dart';
import 'package:frugal_ai/app_storage.dart';

/// 🤖 Smart Category Suggester Widget (Feature 1)
/// Displays auto-suggested categories based on expense description
class SmartCategorySuggester extends StatefulWidget {
  final String description;
  final Function(String) onCategorySelected;
  final String? currentCategory;

  const SmartCategorySuggester({
    Key? key,
    required this.description,
    required this.onCategorySelected,
    this.currentCategory,
  }) : super(key: key);

  @override
  State<SmartCategorySuggester> createState() => _SmartCategorySuggesterState();
}

class _SmartCategorySuggesterState extends State<SmartCategorySuggester> {
  late String suggestedCategory;
  final List<String> allCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Utilities',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    suggestedCategory = AppStorage.suggestCategory(widget.description);
  }

  @override
  void didUpdateWidget(SmartCategorySuggester oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.description != widget.description) {
      suggestedCategory = AppStorage.suggestCategory(widget.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 💡 Smart Suggestion Section
        if (widget.description.isNotEmpty && widget.description.length > 2)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Suggestion',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: $suggestedCategory',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    widget.onCategorySelected(suggestedCategory);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Category set to $suggestedCategory'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Use'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),

        // 📂 Category Selection Grid
        Text(
          'Or select manually:',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: allCategories.map((category) {
            final isSelected = widget.currentCategory == category;
            return GestureDetector(
              onTap: () => widget.onCategorySelected(category),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : Colors.grey.shade100,
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getCategoryEmoji(category),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getCategoryEmoji(String category) {
    const emojis = {
      'Food': '🍔',
      'Transport': '🚗',
      'Shopping': '🛍️',
      'Utilities': '💡',
      'Entertainment': '🎬',
      'Health': '⚕️',
      'Education': '📚',
      'Other': '📌',
    };
    return emojis[category] ?? '📌';
  }
}

/// 📊 Category Statistics Widget
/// Shows breakdown of spending by category (Feature 6)
class CategoryStatsWidget extends StatelessWidget {
  final Map<String, double> categoryData;

  const CategoryStatsWidget({Key? key, required this.categoryData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending by Category',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (categoryData.isEmpty)
          Center(
            child: Text(
              'No expenses yet',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          Column(
            children: categoryData.entries.map((entry) {
              final total = categoryData.values.fold(0.0, (a, b) => a + b);
              final percentage = (entry.value / total) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '₹${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          _getCategoryColor(entry.key),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    const colors = {
      'Food': Color(0xFFFF6B6B),
      'Transport': Color(0xFF4ECDC4),
      'Shopping': Color(0xFFFFD93D),
      'Utilities': Color(0xFF6BCF7F),
      'Entertainment': Color(0xFF9D84B7),
      'Health': Color(0xFFFF6B9D),
      'Education': Color(0xFF95E1D3),
      'Other': Color(0xFFC7CEEA),
    };
    return colors[category] ?? Colors.grey;
  }
}

/// 🎯 Budget Alert Widget (Feature 4)
/// Shows alerts when spending approaches or exceeds budget
class BudgetAlertWidget extends StatefulWidget {
  final Map<String, dynamic> alerts;

  const BudgetAlertWidget({Key? key, required this.alerts}) : super(key: key);

  @override
  State<BudgetAlertWidget> createState() => _BudgetAlertWidgetState();
}

class _BudgetAlertWidgetState extends State<BudgetAlertWidget> {
  @override
  Widget build(BuildContext context) {
    final alertList = widget.alerts['alerts'] as List<dynamic>? ?? [];

    if (alertList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text('✅ All spending within budget'),
          ],
        ),
      );
    }

    return Column(
      children: alertList.map((alert) {
        final status = alert['status'] as String;
        final isExceeded = status == 'exceeded';

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isExceeded ? Colors.red.shade50 : Colors.orange.shade50,
              border: Border.all(
                color: isExceeded
                    ? Colors.red.shade200
                    : Colors.orange.shade200,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isExceeded ? Icons.warning : Icons.info,
                      color: isExceeded
                          ? Colors.red.shade600
                          : Colors.orange.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${alert['category']} - ${isExceeded ? 'EXCEEDED' : 'APPROACHING'} BUDGET',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isExceeded
                              ? Colors.red.shade600
                              : Colors.orange.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${alert['amount']} / ₹${alert['limit']} (${alert['percentage'].toStringAsFixed(1)}%)',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
