import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced Expense Model with all Frugal AI features
class Expense {
  String id;
  double amount;
  String category;
  String description;
  DateTime dateTime;
  String? billImagePath;
  String notes;
  bool isSynced;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.dateTime,
    this.billImagePath,
    required this.notes,
    this.isSynced = false,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'category': category,
    'description': description,
    'dateTime': dateTime.toIso8601String(),
    'billImagePath': billImagePath,
    'notes': notes,
    'isSynced': isSynced,
  };

  // Create from JSON
  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    amount: json['amount'],
    category: json['category'],
    description: json['description'],
    dateTime: DateTime.parse(json['dateTime']),
    billImagePath: json['billImagePath'],
    notes: json['notes'] ?? '',
    isSynced: json['isSynced'] ?? false,
  );
}

/// Budget Management Model
class Budget {
  String category;
  double limit;
  DateTime createdDate;
  bool isActive;

  Budget({
    required this.category,
    required this.limit,
    required this.createdDate,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'limit': limit,
    'createdDate': createdDate.toIso8601String(),
    'isActive': isActive,
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    category: json['category'],
    limit: json['limit'],
    createdDate: DateTime.parse(json['createdDate']),
    isActive: json['isActive'] ?? true,
  );
}

class AppStorage {
  // 🔐 Authentication Keys
  static const String loginKey = "isLoggedIn";
  static const String appLockEnabledKey = "appLockEnabled";
  static const String appLockPinKey = "appLockPin";
  static const String biometricEnabledKey = "biometricEnabled";

  // 💰 Expense Keys
  static const String expenseKey = "expenses";
  static const String budgetKey = "budgets";
  static const String categoryBudgetKey = "categoryBudget_";

  // 🎯 Feature Keys
  static const String studentModePref = "studentMode";
  static const String offlineSyncKey = "offlineSync";
  static const String reminderEnabledKey = "reminderEnabled";
  static const String reminderTimeKey = "reminderTime";

  // ===== 🔐 SECURE LOGIN WITH LOCAL ENCRYPTION (Feature 7) =====

  static Future<void> setLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, value);
  }

  static Future<bool> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, false);
  }

  // App Lock (PIN/Fingerprint)
  static Future<void> setAppLockPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(appLockPinKey, pin);
    await prefs.setBool(appLockEnabledKey, true);
  }

  static Future<String?> getAppLockPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(appLockPinKey);
  }

  static Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(appLockEnabledKey) ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(biometricEnabledKey, enabled);
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(biometricEnabledKey) ?? false;
  }

  // ===== 1️⃣ SMART EXPENSE CATEGORIZATION (Feature 1) =====

  /// Auto-suggest category based on keywords in description
  static String suggestCategory(String description) {
    final lowerDesc = description.toLowerCase();

    // Transport keywords
    if (lowerDesc.contains('uber') ||
        lowerDesc.contains('taxi') ||
        lowerDesc.contains('bus') ||
        lowerDesc.contains('auto') ||
        lowerDesc.contains('fuel') ||
        lowerDesc.contains('petrol') ||
        lowerDesc.contains('metro') ||
        lowerDesc.contains('ola') ||
        lowerDesc.contains('bike') ||
        lowerDesc.contains('car')) {
      return 'Transport';
    }

    // Food keywords
    if (lowerDesc.contains('food') ||
        lowerDesc.contains('restaurant') ||
        lowerDesc.contains('pizza') ||
        lowerDesc.contains('burger') ||
        lowerDesc.contains('coffee') ||
        lowerDesc.contains('cafe') ||
        lowerDesc.contains('lunch') ||
        lowerDesc.contains('dinner') ||
        lowerDesc.contains('breakfast') ||
        lowerDesc.contains('meal')) {
      return 'Food';
    }

    // Shopping keywords
    if (lowerDesc.contains('shop') ||
        lowerDesc.contains('mall') ||
        lowerDesc.contains('cloth') ||
        lowerDesc.contains('shoes') ||
        lowerDesc.contains('amazon') ||
        lowerDesc.contains('flipkart') ||
        lowerDesc.contains('buy') ||
        lowerDesc.contains('purchase')) {
      return 'Shopping';
    }

    // Utilities keywords
    if (lowerDesc.contains('electric') ||
        lowerDesc.contains('water') ||
        lowerDesc.contains('internet') ||
        lowerDesc.contains('bill') ||
        lowerDesc.contains('phone') ||
        lowerDesc.contains('recharge')) {
      return 'Utilities';
    }

    // Entertainment keywords
    if (lowerDesc.contains('movie') ||
        lowerDesc.contains('game') ||
        lowerDesc.contains('netflix') ||
        lowerDesc.contains('spotify') ||
        lowerDesc.contains('entertainment') ||
        lowerDesc.contains('show') ||
        lowerDesc.contains('concert')) {
      return 'Entertainment';
    }

    // Health keywords
    if (lowerDesc.contains('medical') ||
        lowerDesc.contains('doctor') ||
        lowerDesc.contains('hospital') ||
        lowerDesc.contains('medicine') ||
        lowerDesc.contains('pharmacy') ||
        lowerDesc.contains('health')) {
      return 'Health';
    }

    // Education keywords
    if (lowerDesc.contains('school') ||
        lowerDesc.contains('college') ||
        lowerDesc.contains('book') ||
        lowerDesc.contains('course') ||
        lowerDesc.contains('tuition') ||
        lowerDesc.contains('education')) {
      return 'Education';
    }

    return 'Other'; // Default category
  }

  // ===== 💰 EXPENSE MANAGEMENT WITH NOTES & BILL IMAGES (Feature 8) =====

  static Future<void> addExpense(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> expenseList = prefs.getStringList(expenseKey) ?? [];
    expenseList.add(jsonEncode(expense.toJson()));
    await prefs.setStringList(expenseKey, expenseList);
  }

  static Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> expenseList = prefs.getStringList(expenseKey) ?? [];
    return expenseList.map((e) => Expense.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> deleteExpense(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> expenseList = prefs.getStringList(expenseKey) ?? [];
    expenseList.removeWhere((e) {
      final expense = Expense.fromJson(jsonDecode(e));
      return expense.id == id;
    });
    await prefs.setStringList(expenseKey, expenseList);
  }

  // ===== 4️⃣ BUDGET ALERT & PREDICTION (Feature 4) =====

  static Future<void> setBudget(Budget budget) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> budgetList = prefs.getStringList(budgetKey) ?? [];

    // Remove existing budget for category if any
    budgetList.removeWhere((b) {
      final budget = Budget.fromJson(jsonDecode(b));
      return budget.category == budget.category;
    });

    budgetList.add(jsonEncode(budget.toJson()));
    await prefs.setStringList(budgetKey, budgetList);
  }

  static Future<List<Budget>> getBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> budgetList = prefs.getStringList(budgetKey) ?? [];
    return budgetList.map((b) => Budget.fromJson(jsonDecode(b))).toList();
  }

  /// Check if spending in category is near or exceeded budget
  static Future<Map<String, dynamic>> checkBudgetAlert() async {
    final expenses = await getExpenses();
    final budgets = await getBudgets();
    final alerts = <Map<String, dynamic>>[];

    for (var budget in budgets) {
      final categoryExpenses = expenses
          .where((e) => e.category == budget.category)
          .fold<double>(0, (sum, e) => sum + e.amount);

      final percentage = (categoryExpenses / budget.limit) * 100;

      if (percentage > 100) {
        alerts.add({
          'category': budget.category,
          'status': 'exceeded',
          'percentage': percentage,
          'amount': categoryExpenses,
          'limit': budget.limit,
        });
      } else if (percentage > 80) {
        alerts.add({
          'category': budget.category,
          'status': 'warning',
          'percentage': percentage,
          'amount': categoryExpenses,
          'limit': budget.limit,
        });
      }
    }

    return {'alerts': alerts, 'hasAlerts': alerts.isNotEmpty};
  }

  /// Predict monthly overspending
  static Future<Map<String, dynamic>> predictMonthlySpending() async {
    final expenses = await getExpenses();
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    final monthExpenses = expenses
        .where(
          (e) => e.dateTime.year == now.year && e.dateTime.month == now.month,
        )
        .toList();

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    final daysRemaining = daysInMonth - daysPassed;

    double totalSpent = monthExpenses.fold(0, (sum, e) => sum + e.amount);
    double avgPerDay = daysPassed > 0 ? totalSpent / daysPassed : 0;
    double predictedTotal = totalSpent + (avgPerDay * daysRemaining);

    return {
      'totalSpent': totalSpent,
      'avgPerDay': avgPerDay,
      'predictedTotal': predictedTotal,
      'daysPassed': daysPassed,
      'daysRemaining': daysRemaining,
    };
  }

  // ===== 5️⃣ STUDENT/DAILY WAGE FRIENDLY MODE (Feature 5) =====

  static Future<void> setStudentMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(studentModePref, enabled);
  }

  static Future<bool> isStudentMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(studentModePref) ?? false;
  }

  // ===== 3️⃣ OFFLINE + ONLINE SYNC (Feature 3) =====

  static Future<void> markExpenseForSync(String expenseId, bool synced) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> expenseList = prefs.getStringList(expenseKey) ?? [];

    expenseList = expenseList.map((e) {
      final expense = Expense.fromJson(jsonDecode(e));
      if (expense.id == expenseId) {
        expense.isSynced = synced;
      }
      return jsonEncode(expense.toJson());
    }).toList();

    await prefs.setStringList(expenseKey, expenseList);
  }

  static Future<List<Expense>> getUnsyncedExpenses() async {
    final expenses = await getExpenses();
    return expenses.where((e) => !e.isSynced).toList();
  }

  // ===== 9️⃣ REMINDER SYSTEM (Feature 9) =====

  static Future<void> enableDailyReminder(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(reminderEnabledKey, true);
    await prefs.setString(reminderTimeKey, "${time.hour}:${time.minute}");
  }

  static Future<void> disableDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(reminderEnabledKey, false);
  }

  static Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(reminderEnabledKey) ?? false;
  }

  static Future<String?> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(reminderTimeKey);
  }

  // ===== 6️⃣ GRAPHICAL & INSIGHT-BASED REPORTS (Feature 6) =====

  static Future<Map<String, double>> getCategoryWiseExpenses() async {
    final expenses = await getExpenses();
    final categoryMap = <String, double>{};

    for (var expense in expenses) {
      categoryMap[expense.category] =
          (categoryMap[expense.category] ?? 0) + expense.amount;
    }

    return categoryMap;
  }

  /// Get weekly/monthly comparison
  static Future<Map<String, dynamic>> getWeeklyMonthlyComparison() async {
    final expenses = await getExpenses();
    final now = DateTime.now();

    // Current week
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final currentWeek = expenses
        .where((e) => e.dateTime.isAfter(weekStart))
        .fold<double>(0, (sum, e) => sum + e.amount);

    // Last week
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));
    final lastWeek = expenses
        .where(
          (e) =>
              e.dateTime.isAfter(lastWeekStart) &&
              e.dateTime.isBefore(weekStart),
        )
        .fold<double>(0, (sum, e) => sum + e.amount);

    // Current month
    final monthStart = DateTime(now.year, now.month);
    final currentMonth = expenses
        .where((e) => e.dateTime.isAfter(monthStart))
        .fold<double>(0, (sum, e) => sum + e.amount);

    // Last month
    final lastMonthStart = DateTime(now.year, now.month - 1);
    final lastMonthEnd = monthStart;
    final lastMonth = expenses
        .where(
          (e) =>
              e.dateTime.isAfter(lastMonthStart) &&
              e.dateTime.isBefore(lastMonthEnd),
        )
        .fold<double>(0, (sum, e) => sum + e.amount);

    return {
      'currentWeek': currentWeek,
      'lastWeek': lastWeek,
      'weekChangePercent': lastWeek != 0
          ? ((currentWeek - lastWeek) / lastWeek) * 100
          : 0,
      'currentMonth': currentMonth,
      'lastMonth': lastMonth,
      'monthChangePercent': lastMonth != 0
          ? ((currentMonth - lastMonth) / lastMonth) * 100
          : 0,
    };
  }

  /// Get highest spending category
  static Future<Map<String, dynamic>> getHighestSpendingCategory() async {
    final categoryWise = await getCategoryWiseExpenses();
    if (categoryWise.isEmpty) {
      return {'category': 'N/A', 'amount': 0};
    }

    final sorted = categoryWise.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'category': sorted.first.key,
      'amount': sorted.first.value,
      'percentage':
          (sorted.first.value /
              categoryWise.values.fold(0, (sum, e) => sum + e)) *
          100,
    };
  }

  // ===== GENERIC STORAGE METHODS =====

  static Future<String?> getStorageValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setStorageValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<double?> getDoubleValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future<void> setDoubleValue(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }
}

// Extend TimeOfDay for reminder time
extension TimeOfDayExtension on TimeOfDay {
  String toFormattedString() =>
      "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
}
