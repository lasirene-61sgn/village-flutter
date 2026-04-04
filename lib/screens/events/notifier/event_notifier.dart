import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:village/services/api/api_client/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:village/screens/events/model/event_model.dart';

/// ======================
/// STATE
/// ======================
class EventsState {
  final bool isLoading;
  final bool isSaving;
  final bool isLoaded;
  final String? error;
  final List<Event> eventsList;
  final Event? selectedEvent;

  const EventsState({
    this.isLoading = false,
    this.isSaving = false,
    this.isLoaded = false,
    this.error,
    this.eventsList = const [],
    this.selectedEvent,
  });

  EventsState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isLoaded,
    String? error,
    List<Event>? eventsList,
    Event? selectedEvent,
  }) {
    return EventsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error,
      eventsList: eventsList ?? this.eventsList,
      selectedEvent: selectedEvent ?? this.selectedEvent,
    );
  }
}

/// ======================
/// NOTIFIER
/// ======================
class EventsNotifier extends StateNotifier<EventsState> {
  EventsNotifier() : super(const EventsState());

  /// Load Events List
  Future<void> loadEvents() async {
    state = state.copyWith(
      isLoading: true,
      isLoaded: false,
      error: null,
    );

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/event');

      if (response["status"] == 1) {
        print("RAW RESPONSE: $response");

        final dynamic rawData = response['data']?['data'];

        if (rawData != null && rawData is List) {
          final events = rawData
              .map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList();

          state = state.copyWith(
            isLoading: false,
            isLoaded: true,
            eventsList: events,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            isLoaded: true,
            eventsList: const [],
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Server returned error status',
        );
      }
    } catch (e, s) {
      print("EVENT LOAD ERROR: $e");
      print(s);

      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load events',
      );
    }
  }



  Future<void> updateRSVP(
      String memberId,
      Map<String, dynamic> payload) async {

    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await ApiClient().post(
        endpoint:'api/customer/event/$memberId/rsvp',
        body:  payload,
      );

      if (response != null && response['status'] == 1) {
        await loadEvents();
        state = state.copyWith(isSaving: false, error: null);


      } else {
        throw Exception(response['message'] ?? 'Update failed');
      }
    } catch (e) {
      debugPrint("UPDATE FAMILY ERROR: $e");
      state = state.copyWith(
          isSaving: false,
          error: 'Failed to update family member'
      );
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

/// ======================
/// PROVIDER
/// ======================
final eventsNotifierProvider =
StateNotifierProvider<EventsNotifier, EventsState>(
      (ref) => EventsNotifier(),
);
