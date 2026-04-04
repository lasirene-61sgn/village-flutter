import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:village/screens/profile/model/family_member_model.dart';
import 'package:village/screens/profile/model/profile_model.dart';
import 'package:village/services/api/api_client/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:village/services/widget/custom_msg.dart';

class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final bool isLoaded;
  final String? error;

  final Profile? profile;          // ✅ Single profile
  final List<FamilyMember>? familyMember;          // ✅ Single profile
  final Profile? selectedProfile;  // ✅ For edit/view

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.isLoaded = false,
    this.error,
    this.profile,
    this.selectedProfile,
    this.familyMember,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isLoaded,
    String? error,
    Profile? profile,
    List<FamilyMember>? familyMember,
    Profile? selectedProfile,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error,
      profile: profile ?? this.profile,
      familyMember: familyMember ?? this.familyMember,
      selectedProfile: selectedProfile ?? this.selectedProfile,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super( ProfileState());

  /// ======================
  /// LOAD PROFILE
  /// ======================
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/profile');

      if (response['status'] == 1 && response['data']?['data'] != null) {
        final profile = Profile.fromJson(response['data']?['data']);
        print("User Profile: ${response['data']?['data']}");
        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          profile: profile,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid profile response',
        );
      }
    } catch (e, s) {
      debugPrint("PROFILE LOAD ERROR: $e");
      debugPrintStack(stackTrace: s);

      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile',
      );
    }
  }
  Future<void> addFamily(
      BuildContext context,
      File? profileImage,
      Map<String, dynamic> payload) async {

    // 1. Set loading state
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await ApiClient().postWithFiles(
        endpoint: 'api/customer/family-members',
        fields: payload,
        files: {
          if (profileImage != null) 'image': profileImage,
        },
      );

      print("Add Family Response: $response");

      // 2. Check for success (status 1 from ApiClient)
      if (response['status'] == 1) {
        // Refresh the list
        await loadMember();

        // Update state
        state = state.copyWith(isSaving: false, error: null);

        // 3. Extract message from nested data
        final String msg = response['data']?['message']?.toString() ??
            response['message']?.toString() ??
            "Member added successfully";

        Toaster.showSuccess(msg);

        // 4. Safety check before popping the screen
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        // 5. Handle failure (validation errors, etc.)
        state = state.copyWith(isSaving: false);
        Toaster.showError(response['message']?.toString() ?? "Failed to add member");
      }
    } catch (e) {
      // 6. Handle exceptions
      debugPrint("ADD FAMILY ERROR: $e");
      state = state.copyWith(
          isSaving: false,
          error: e.toString()
      );
      Toaster.showError("An unexpected error occurred");
    }
  }
  Future<void> updateFamily(
      BuildContext context,
      String memberId,
      File? profileImage,
      Map<String, dynamic> payload) async {

    state = state.copyWith(isSaving: true, error: null);

    try {

      final response = await ApiClient().postWithFiles( // Use POST instead of PUT
        endpoint: 'api/customer/family-members/$memberId',
        fields: payload,
        files: {
          if (profileImage != null) 'image': profileImage,
        },
      );

      print("Update Response: $response");

      // 1. Check status 1 (Success from your ApiClient wrapper)
      if (response['status'] == 1) {
        // 2. Refresh the list in the background
        await loadMember();

        state = state.copyWith(isSaving: false, error: null);

        // 3. Extract the success message properly
        // Looks for data -> message first, then falls back to outer message
        String msg = response['data']?['message']?.toString() ??
            response['message']?.toString() ??
            "Updated successfully";

        Toaster.showSuccess(msg);

        // 4. Return to previous screen
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        // Handle logic errors (e.g., validation failed)
        state = state.copyWith(isSaving: false);
        Toaster.showError(response['message']?.toString() ?? "Failed to update");
      }
    } catch (e) {
      debugPrint("UPDATE FAMILY ERROR: $e");
      state = state.copyWith(isSaving: false, error: e.toString());
      Toaster.showError("An unexpected error occurred");
    }
  }
  Future<void> loadMember() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/family-members/');

      // Check if data is a List
      if (response['status'] == 1 && response['data']?['data'] != null) {
        final List<dynamic> dataList = response['data']['data'];

        // Map the list to FamilyMember objects
        final members = dataList.map((item) => FamilyMember.fromJson(item)).toList();

        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          familyMember: members, // ✅ Assign to familyMember list, not profile
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'No family data found');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load family');
    }
  }

  Future<void> submitProfile(
      BuildContext context,
      Map<String, dynamic> payload,
      File? profileImage,
      ) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      // Note: Ensure you use the same instance of Dio if possible,
      // but calling ApiClient() works if it initializes correctly.
      final response = await ApiClient().postWithFiles(
        endpoint: 'api/customer/profile',
        fields: payload,
        files: {
          if (profileImage != null) 'image': profileImage, // This is now handled
        },
      );

      // Your logic to check 'status' from your _handleResponse wrapper
      if (response["status"] == 1) {
        await loadProfile();
        state = state.copyWith(isSaving: false, error: null);
        Toaster.showSuccess(response["message"] ?? "Updated Successfully");
       Get.back();
      } else {
        state = state.copyWith(isSaving: false);
        Toaster.showError(response['message'].toString());
      }
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

}


final profileNotifierProvider =
StateNotifierProvider<ProfileNotifier, ProfileState>(
      (ref) => ProfileNotifier(),
);
