import 'package:get/get.dart';
import '../../../data/models/earnings_model.dart';
import '../../../data/repositories/earnings_repository.dart';

class EarningsController extends GetxController {
  final EarningsRepository _repository = EarningsRepository();

  // State
  final isLoading = true.obs;
  final selectedPeriod = 'today'.obs;
  final earnings = Rxn<EarningsModel>();
  final dailyBreakdown = <DailyEarnings>[].obs;
  final transactions = <EarningTransaction>[].obs;
  final isLoadingMore = false.obs;

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    loadEarnings();
    loadDailyBreakdown();
    loadTransactions();
  }

  /// Change selected period
  void changePeriod(String period) {
    if (selectedPeriod.value == period) return;
    selectedPeriod.value = period;
    loadEarnings();
  }

  /// Load earnings for selected period
  Future<void> loadEarnings() async {
    try {
      isLoading.value = true;
      earnings.value = await _repository.getEarnings(period: selectedPeriod.value);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load earnings');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load daily breakdown (last 7 days)
  Future<void> loadDailyBreakdown() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 6));
      dailyBreakdown.value = await _repository.getDailyBreakdown(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      // Silently fail - chart will show empty
    }
  }

  /// Load transactions
  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      transactions.clear();
    }

    if (!_hasMore || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      final newTransactions = await _repository.getTransactions(page: _currentPage);
      
      if (newTransactions.isEmpty) {
        _hasMore = false;
      } else {
        transactions.addAll(newTransactions);
        _currentPage++;
      }
    } catch (e) {
      // Silently fail
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadEarnings(),
      loadDailyBreakdown(),
      loadTransactions(refresh: true),
    ]);
  }

  // Getters for UI
  String get periodLabel {
    switch (selectedPeriod.value) {
      case 'today':
        return 'Today';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      default:
        return 'Today';
    }
  }

  double get maxDailyEarning {
    if (dailyBreakdown.isEmpty) return 100;
    return dailyBreakdown.map((e) => e.earnings).reduce((a, b) => a > b ? a : b);
  }
}
