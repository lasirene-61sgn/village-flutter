import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:village/screens/business/model/business_model.dart';
import 'package:village/screens/business/model/category_model.dart';
import 'package:village/screens/staff/model/staff_model.dart';
import 'package:village/services/api/api_client/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ======================
/// STATE
/// ======================
class StaffState {
  final bool isLoading;
  final bool isSaving;
  final bool isLoaded;
  final String? error;
  final List<Staff> staffList;
  final List<Category> category;

  const StaffState({
    this.isLoading = false,
    this.isSaving = false,
    this.isLoaded = false,
    this.error,
    this.staffList = const [],
    this.category = const [],
  });

  StaffState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isLoaded,
    String? error,
    List<Staff>? staffList,
    List<Category>? category,
  }) {
    return StaffState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error,
      staffList: staffList ?? this.staffList,
      category: category ?? this.category,
    );
  }
}

/// ======================
/// NOTIFIER
/// ======================
class StaffNotifier extends StateNotifier<StaffState> {
  StaffNotifier() : super(const StaffState());

  Future<void> loadStaff(String url) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: url);

      if (response["status"] == 1) {
        dynamic rawData = response['data'];

        // 🔥 Handle both API formats
        if (rawData is Map && rawData['data'] is List) {
          rawData = rawData['data'];
          debugPrint("STAFF COUNT: $rawData");
        }

        if (rawData is List) {
          final staff = rawData
              .map<Staff>((e) => Staff.fromJson(e))
              .toList();

          debugPrint("STAFF COUNT: ${staff.length} ${staff}");

          state = state.copyWith(
            isLoading: false,
            staffList: staff,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            staffList: [],
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Server returned error status',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load staff: $e',
      );
    }
  }


  Future<void> loadCategory(String url) async {
    state = state.copyWith(isLoaded: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: url);
      debugPrint("category COUNT: ${response}");
      if (response["status"] == 1) {
        final rawData = response['data']?['data'];

        if (rawData is List && rawData.isNotEmpty) {
          final categories =
          rawData.map((e) => Category.fromJson(e)).toList();

          debugPrint("category COUNT: ${categories.length}");
          final allCategory = Category(
            id: 0,
            categoryName: 'All',
          );

          state = state.copyWith(
            isLoaded: false,
            category: [allCategory, ...categories],
          );
        } else {
          state = state.copyWith(isLoaded: false, category: []);
        }
      } else {
        state = state.copyWith(
          isLoaded: false,
          error: 'Server returned error status',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoaded: false,
        error: 'Failed to load category: $e',
      );
    }
  }
}

/// ======================
/// PROVIDER
/// ======================
final staffNotifierProvider =
StateNotifierProvider<StaffNotifier, StaffState>(
      (ref) => StaffNotifier(),
);
