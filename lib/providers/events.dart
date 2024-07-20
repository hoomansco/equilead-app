import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/models/event.dart';
import 'package:equilead/utils/network_util.dart';

class FeaturedEventNotifier extends StateNotifier<List<Event>> {
  FeaturedEventNotifier() : super([]);

  List<Event> allEvents = [];

  Future getEvents() async {
    var resp = await NetworkUtils().httpGet("event/featured");
    if (resp?.statusCode == 200) {
      if (json.decode(resp!.body)["status"]) {
        Iterable l = json.decode(resp.body)["data"];
        List<Event> events =
            List<Event>.from(l.map((model) => Event.fromJson(model))).toList();
        state = events.where((element) => element.status != 'draft').toList();
        allEvents = state;
      }
    } else {
      state = [];
    }
  }

  void filterEvents(String filterType, bool isSpace) {
    if (filterType == "" && !isSpace) {
      state = allEvents;
    } else if (isSpace) {
      state = allEvents.where((element) => element.isSpace == isSpace).toList();
    } else {
      state = allEvents
          .where((element) =>
              element.type == filterType && element.isSpace == isSpace)
          .toList();
    }
  }

  void updateFeaturedEvent(List<Event> event) {
    state = event;
  }
}

final featuredEventProvider =
    StateNotifierProvider<FeaturedEventNotifier, List<Event>>(
  (ref) => FeaturedEventNotifier(),
);

class UpcomingEventNotifier extends StateNotifier<List<Event>> {
  UpcomingEventNotifier() : super([]);

  List<Event> allEvents = [];

  Future getEvents() async {
    var resp = await NetworkUtils().httpGet("event/unfeatured");
    if (resp?.statusCode == 200) {
      if (json.decode(resp!.body)["status"]) {
        Iterable l = json.decode(resp.body)["data"];
        List<Event> events =
            List<Event>.from(l.map((model) => Event.fromJson(model)))
                .take(10)
                .toList();
        state = events.where((element) => element.status != 'draft').toList();
        allEvents = state;
      }
    } else {
      state = [];
      allEvents = [];
    }
  }

  void filterEvents(String filterType, bool isSpace) {
    if (filterType == "" && !isSpace) {
      state = allEvents;
    } else if (isSpace) {
      state = allEvents.where((element) => element.isSpace == isSpace).toList();
    } else {
      state = allEvents
          .where((element) =>
              element.type == filterType && element.isSpace == isSpace)
          .toList();
    }
  }

  void updateUpcomingEvent(List<Event> event) {
    state = event;
  }
}

final upcomingEventProvider =
    StateNotifierProvider<UpcomingEventNotifier, List<Event>>(
  (ref) => UpcomingEventNotifier(),
);

class SpaceEventNotifier extends StateNotifier<List<Event>> {
  SpaceEventNotifier() : super([]);

  Future getEvents() async {
    var resp = await NetworkUtils().httpGet("event/space");
    if (resp?.statusCode == 200) {
      if (json.decode(resp!.body)["status"]) {
        Iterable l = json.decode(resp.body)["data"];
        List<Event> events =
            List<Event>.from(l.map((model) => Event.fromJson(model))).toList();
        state = events.where((element) => element.status != 'draft').toList();
      }
    } else {
      state = [];
    }
  }

  void updateSpaceEvent(List<Event> event) {
    state = event;
  }
}

final spaceEventProvider =
    StateNotifierProvider<SpaceEventNotifier, List<Event>>(
  (ref) => SpaceEventNotifier(),
);

class CampusEventNotifier extends StateNotifier<List<Event>> {
  CampusEventNotifier() : super([]);

  Future getEvents(int subOrgId) async {
    var resp = await NetworkUtils().httpGet("event/suborg/$subOrgId");
    if (resp?.statusCode == 200) {
      if (json.decode(resp!.body)["status"]) {
        Iterable l = json.decode(resp.body)["data"];
        List<Event> events =
            List<Event>.from(l.map((model) => Event.fromJson(model))).toList();
        state = events.where((element) => element.status != 'draft').toList();
      }
    } else {
      state = [];
    }
  }

  void updateCampusEvent(List<Event> event) {
    state = event;
  }
}

final campusEventProvider =
    StateNotifierProvider<CampusEventNotifier, List<Event>>(
  (ref) => CampusEventNotifier(),
);
