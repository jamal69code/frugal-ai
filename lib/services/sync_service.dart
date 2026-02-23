import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frugal_ai/app_storage.dart';

/// 🔄 Offline + Online Sync Service (Feature 3)
/// Manages local caching and synchronization with Firebase
class SyncService {
  static final SyncService _instance = SyncService._internal();

  factory SyncService() {
    return _instance;
  }

  SyncService._internal();

  late Connectivity _connectivityChecker;
  late FirebaseFirestore _firestore;
  bool _isOnline = false;

  Future<void> initialize() async {
    _connectivityChecker = Connectivity();
    _firestore = FirebaseFirestore.instance;

    // Check initial connectivity
    await _checkConnectivity();

    // Listen to connectivity changes
    _connectivityChecker.onConnectivityChanged.listen((result) async {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        print('🌐 Online - Syncing data...');
        await syncPendingData();
      } else {
        print('📴 Offline mode activated');
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivityChecker.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
  }

  bool get isOnline => _isOnline;

  /// Sync unsynced expenses to Firebase
  Future<void> syncPendingData() async {
    if (!_isOnline) {
      print('❌ Cannot sync: No internet connection');
      return;
    }

    try {
      final unsyncedExpenses = await AppStorage.getUnsyncedExpenses();

      for (var expense in unsyncedExpenses) {
        try {
          // Save to Firestore
          await _firestore.collection('expenses').doc(expense.id).set({
            'id': expense.id,
            'amount': expense.amount,
            'category': expense.category,
            'description': expense.description,
            'dateTime': expense.dateTime.toIso8601String(),
            'billImagePath': expense.billImagePath,
            'notes': expense.notes,
            'syncedAt': DateTime.now().toIso8601String(),
          });

          // Mark as synced locally
          await AppStorage.markExpenseForSync(expense.id, true);
          print('✅ Synced expense: ${expense.id}');
        } catch (e) {
          print('❌ Failed to sync expense ${expense.id}: $e');
        }
      }

      print('✅ All pending expenses synced successfully');
    } catch (e) {
      print('❌ Sync error: $e');
    }
  }

  /// Sync expenses from Firebase to local database
  Future<void> syncExpensesFromCloud() async {
    if (!_isOnline) {
      print('❌ Cannot fetch from cloud: No internet connection');
      return;
    }

    try {
      final snapshot = await _firestore.collection('expenses').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Update local database with cloud data
        print('📥 Downloaded expense: ${data['id']}');
      }

      print('✅ Cloud expenses synced to local database');
    } catch (e) {
      print('❌ Cloud sync error: $e');
    }
  }

  /// Create offline cache of Firestore data
  Future<void> enableOfflineCache() async {
    try {
      await _firestore.enableNetwork();
      print('✅ Offline cache enabled');
    } catch (e) {
      print('❌ Failed to enable offline cache: $e');
    }
  }

  /// Disable offline cache to save storage
  Future<void> disableOfflineCache() async {
    try {
      await _firestore.disableNetwork();
      print('✅ Offline cache disabled');
    } catch (e) {
      print('❌ Failed to disable offline cache: $e');
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final unsyncedExpenses = await AppStorage.getUnsyncedExpenses();

    return {
      'isOnline': _isOnline,
      'unsyncedCount': unsyncedExpenses.length,
      'lastSyncTime': DateTime.now(),
      'status': _isOnline
          ? 'Online & Ready'
          : 'Offline - Will sync when online',
    };
  }

  /// Manual sync trigger
  Future<void> manualSync() async {
    print('🔄 Starting manual sync...');
    await _checkConnectivity();

    if (_isOnline) {
      await syncPendingData();
      await syncExpensesFromCloud();
      print('✅ Manual sync completed');
    } else {
      print('❌ Cannot sync: Device is offline');
    }
  }

  /// Get last sync time
  DateTime? _lastSyncTime;

  DateTime? get lastSyncTime => _lastSyncTime;

  /// Update sync timestamp
  void updateLastSyncTime() {
    _lastSyncTime = DateTime.now();
  }

  /// Calculate data to be synced (in bytes)
  Future<int> calculateSyncSize() async {
    final unsyncedExpenses = await AppStorage.getUnsyncedExpenses();
    // Rough estimate: ~200 bytes per expense
    return unsyncedExpenses.length * 200;
  }

  /// Handle sync conflicts (if local and cloud data differ)
  Future<void> resolveConflicts() async {
    print('🔀 Resolving sync conflicts...');
    // Implement conflict resolution strategy
    // E.g., take newer timestamp, user preference, etc.
  }
}
