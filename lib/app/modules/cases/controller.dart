import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../data/models/case_model.dart';

class CasesController extends GetxController {
  final caseBox = Hive.box<CaseModel>('cases');
  
  // Search and filter observables
  final searchQuery = ''.obs;
  final selectedStatus = 'All'.obs;
  final sortBy = 'Title'.obs;
  final sortAscending = true.obs;
  final showAdvancedFilters = false.obs;
  final dateRange = Rxn<DateTimeRange>();
  
  // UI controllers
  final searchController = TextEditingController();
  
  // Options
  final statusOptions = ['All', 'Pending', 'Closed', 'Disposed', 'Not Filed'].obs;
  final sortOptions = ['Title', 'Client Name', 'Court', 'Next Hearing', 'Status'].obs;
  
  // Computed filtered cases
  List<CaseModel> get filteredCases {
    final allCases = caseBox.values.toList().cast<CaseModel>();
    return _filterAndSortCases(allCases);
  }
  
  // Stats
  int get totalCases => caseBox.length;
  int get filteredCount => filteredCases.length;
  
  Map<String, int> get casesByStatus {
    final allCases = caseBox.values.toList().cast<CaseModel>();
    final statusCount = <String, int>{};
    
    for (final status in statusOptions) {
      if (status == 'All') continue;
      statusCount[status] = allCases.where((c) => c.status == status).length;
    }
    
    return statusCount;
  }

  @override
  void onInit() {
    super.onInit();
    
    // Listen to search text changes
    searchController.addListener(() {
      searchQuery.value = searchController.text.toLowerCase();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Filter and sort logic
  List<CaseModel> _filterAndSortCases(List<CaseModel> cases) {
    RxList<CaseModel> filtered = cases.where((c) {
      // Text search - search in multiple fields
      bool matchesSearch = searchQuery.value.isEmpty ||
          c.title.toLowerCase().contains(searchQuery.value) ||
          c.clientName.toLowerCase().contains(searchQuery.value) ||
          c.court.toLowerCase().contains(searchQuery.value) ||
          (c.courtNo?.toLowerCase().contains(searchQuery.value) ?? false);

      // Status filter
      bool matchesStatus = selectedStatus.value == 'All' || 
          c.status == selectedStatus.value;

      // Date range filter for next hearing
      bool matchesDateRange = dateRange.value == null ||
          (c.nextHearing.isAfter(dateRange.value!.start.subtract(const Duration(days: 1))) &&
           c.nextHearing.isBefore(dateRange.value!.end.add(const Duration(days: 1))));

      return matchesSearch && matchesStatus && matchesDateRange;
    }).toList().obs;

    // Sort cases
    filtered.sort((a, b) {
      int comparison = 0;
      switch (sortBy.value) {
        case 'Title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'Client Name':
          comparison = a.clientName.compareTo(b.clientName);
          break;
        case 'Court':
          comparison = a.court.compareTo(b.court);
          break;
        case 'Next Hearing':
          comparison = a.nextHearing.compareTo(b.nextHearing);
          break;
        case 'Status':
          comparison = a.status.compareTo(b.status);
          break;
      }
      return sortAscending.value ? comparison : -comparison;
    });

    return filtered;
  }

  // Actions
  void updateSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void updateStatusFilter(String status) {
    selectedStatus.value = status;
  }

  void updateSortBy(String sort) {
    if (sortBy.value == sort) {
      // Toggle sort order if same field
      sortAscending.value = !sortAscending.value;
    } else {
      sortBy.value = sort;
      sortAscending.value = true;
    }
  }

  void toggleAdvancedFilters() {
    showAdvancedFilters.value = !showAdvancedFilters.value;
  }

  void updateDateRange(DateTimeRange? range) {
    dateRange.value = range;
  }

  void clearFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedStatus.value = 'All';
    sortBy.value = 'Title';
    sortAscending.value = true;
    dateRange.value = null;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  // Quick filter methods
  void filterByStatus(String status) {
    selectedStatus.value = status;
  }

  void filterUpcomingHearings() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    dateRange.value = DateTimeRange(start: now, end: nextWeek);
  }

  void filterOverdueHearings() {
    final now = DateTime.now();
    final pastMonth = now.subtract(const Duration(days: 30));
    dateRange.value = DateTimeRange(start: pastMonth, end: now);
  }

  // Get cases by specific criteria
  List<CaseModel> getCasesByStatus(String status) {
    return caseBox.values.where((c) => c.status == status).toList().cast<CaseModel>();
  }

  List<CaseModel> getUpcomingHearings() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return caseBox.values
        .where((c) => c.nextHearing.isAfter(now) && c.nextHearing.isBefore(nextWeek))
        .toList()
        .cast<CaseModel>();
  }

  List<CaseModel> getOverdueHearings() {
    final now = DateTime.now();
    return caseBox.values
        .where((c) => c.nextHearing.isBefore(now))
        .toList()
        .cast<CaseModel>();
  }
}