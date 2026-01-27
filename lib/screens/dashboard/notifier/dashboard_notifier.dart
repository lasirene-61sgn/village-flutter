import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:village/screens/dashboard/model/banner_model.dart';
import 'package:village/screens/dashboard/model/dashboard_model.dart';
import 'package:village/screens/dashboard/model/notifiction_model.dart';
import 'package:village/services/local_storage/shared_preference.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:village/services/api/api_client/api_client.dart';
import 'package:village/services/api/repo/repo.dart';

class DashboardState {
  final bool isLoading;
  final bool isSaving;
  final bool isLoaded;
  final String? error;

  final List<BirthdayModel> birthdayList;
  final List<BirthdayModel> anniversaryList;
  final List<AppNotification> notification;
  final List<BannerModel> banners;


  const DashboardState({
    this.isLoading = false,
    this.isSaving = false,
    this.isLoaded = false,
    this.error,
    this.birthdayList = const [],
    this.anniversaryList = const [],
    this.notification = const [],
    this.banners = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isLoaded,
    String? error,
    List<BirthdayModel>? birthdayList,
    List<BirthdayModel>? anniversaryList,
    List<AppNotification>? notification,
    List<BannerModel>? banners,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error,
      birthdayList: birthdayList ?? this.birthdayList,
      anniversaryList: anniversaryList ?? this.anniversaryList,
      notification: notification ?? this.notification,
      banners: banners ?? this.banners,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());

  /// ======================
  /// LOAD BIRTHDAY LIST
  /// ======================
  Future<void> loadBirthdays() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get('api/customer/today-birthdays');

      if (response['status'] == 1) {
        final rawData = response['data']?['data'] as List? ?? [];

        final list =
        rawData.map((e) => BirthdayModel.fromJson(e)).toList();

        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          birthdayList: list,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load birthdays',
      );
    }
  }

  Future<void> loadBanner() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get('api/customer/banner');

      if (response['status'] == 1) {
        final rawData = response['data']?['data'] as List? ?? [];

        final list =
        rawData.map((e) => BannerModel.fromJson(e)).toList();
        print("this is a banner : $list");

        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          banners: list,
        );
      }
      else{
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load banner',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load birthdays',
      );
    }
  }
  Future<void> loadNotification() async {
    state = state.copyWith(isSaving: true, error: null);

    // // 1. Get all preference values
    // bool eventReminders = SharedPreferencesHelper().getBool("event_reminders") ?? false;
    // bool newsReminders = SharedPreferencesHelper().getBool("news_updates") ?? false;
    // bool birthDayReminders = SharedPreferencesHelper().getBool("birthday_reminders") ?? false;
    // bool anniversaryReminders = SharedPreferencesHelper().getBool("anniversary_reminders") ?? false;
    // bool galleryReminders = SharedPreferencesHelper().getBool("gallery_updates") ?? false;
    // print("gallery Reminders  :$galleryReminders");

    try {
      final response = await ApiClient().get('api/customer/all-notifications');

      if (response['status'] == 1) {
        final rawData = response['data']?['data'] as List? ?? [];

        final list = rawData
            .map((e) => AppNotification.fromJson(e)).toList();
        //     .where((notification) {
        //   // 2. Check each type against its specific toggle
        //   switch (notification.type) {
        //     case "event":
        //       return eventReminders;
        //     case "gallery":
        //       return galleryReminders;
        //     case "news":
        //       return newsReminders;
        //     case "anniversary":
        //       return anniversaryReminders;
        //     case "birthday":
        //       return birthDayReminders;
        //     default:
        //     // If the type is unknown, you can choose to show it (true)
        //     // or hide it (false).
        //       return true;
        //   }
        // })
        //     .toList();
 print(list);
        state = state.copyWith(
          isSaving: false,
          notification: list,
        );
      }
    } catch (e) {
      print(" error  ${e.toString()}");
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to load notifications',
      );
    }
  }

  Future<void> loadAnniversaries() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get('api/customer/today-anniversaries');

      if (response['status'] == 1) {
        final rawData = response['data']?['data'] as List? ?? [];

        final list =
        rawData.map((e) => BirthdayModel.fromJson(e)).toList();

        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          anniversaryList: list,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load anniversaries',
      );
    }
  }
}


final dashboardNotifierProvider =
StateNotifierProvider<DashboardNotifier, DashboardState>(
      (ref) => DashboardNotifier(),
);
