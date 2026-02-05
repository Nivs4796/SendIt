import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/history_repository.dart';

class HistoryController extends GetxController {
  final HistoryRepository _repository = HistoryRepository();

  // State
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final jobs = <JobHistoryItem>[].obs;

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;

  // Filters
  final selectedFilter = 'all'.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  // Stats
  final totalEarnings = 0.0.obs;
  final totalJobs = 0.obs;
  final completedJobs = 0.obs;
  final cancelledJobs = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadJobs();
  }

  /// Load job history
  Future<void> loadJobs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      jobs.clear();
    }

    if (!_hasMore || isLoadingMore.value) return;

    try {
      if (_currentPage == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      String? statusFilter;
      if (selectedFilter.value == 'completed') {
        statusFilter = 'completed';
      } else if (selectedFilter.value == 'cancelled') {
        statusFilter = 'cancelled';
      }

      final response = await _repository.getJobHistory(
        page: _currentPage,
        status: statusFilter,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      if (_currentPage == 1) {
        jobs.value = response.jobs;
      } else {
        jobs.addAll(response.jobs);
      }

      _hasMore = response.hasMore;
      _currentPage++;

      // Calculate stats
      _calculateStats();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load job history',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Calculate stats from jobs
  void _calculateStats() {
    double earnings = 0;
    int completed = 0;
    int cancelled = 0;

    for (final job in jobs) {
      earnings += job.earnings;
      if (job.status == JobStatus.completed) {
        completed++;
      } else {
        cancelled++;
      }
    }

    totalEarnings.value = earnings;
    totalJobs.value = jobs.length;
    completedJobs.value = completed;
    cancelledJobs.value = cancelled;
  }

  /// Apply filter
  void applyFilter(String filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      loadJobs(refresh: true);
    }
  }

  /// Set date range
  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: startDate.value != null && endDate.value != null
          ? DateTimeRange(start: startDate.value!, end: endDate.value!)
          : null,
    );

    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;
      loadJobs(refresh: true);
    }
  }

  /// Clear date filter
  void clearDateFilter() {
    startDate.value = null;
    endDate.value = null;
    loadJobs(refresh: true);
  }

  /// Load more jobs (for pagination)
  void loadMore() {
    if (_hasMore && !isLoadingMore.value) {
      loadJobs();
    }
  }

  /// Refresh jobs
  Future<void> refresh() => loadJobs(refresh: true);

  /// Get status color
  Color getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.completed:
        return Colors.green;
      case JobStatus.cancelled:
        return Colors.red;
    }
  }

  /// Get status icon
  IconData getStatusIcon(JobStatus status) {
    switch (status) {
      case JobStatus.completed:
        return Icons.check_circle;
      case JobStatus.cancelled:
        return Icons.cancel;
    }
  }
}
