import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/models/profile.dart';

class CampusAdminNotifier extends StateNotifier<List<Profile>> {
  CampusAdminNotifier() : super([]);
}

final campusAdminProvider =
    StateNotifierProvider<CampusAdminNotifier, List<Profile>>(
  (ref) => CampusAdminNotifier(),
);

class CampusMemberNotifier extends StateNotifier<List<Profile>> {
  CampusMemberNotifier() : super([]);
}

final campusMemberProvider =
    StateNotifierProvider<CampusMemberNotifier, List<Profile>>(
  (ref) => CampusMemberNotifier(),
);
