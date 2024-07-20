import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/models/college.dart';
import 'package:equilead/utils/network_util.dart';

class CollegeNameNotifier extends StateNotifier<String> {
  CollegeNameNotifier() : super("");

  void update(String name) {
    state = name;
  }
}

final collegeNameProvider = StateNotifierProvider<CollegeNameNotifier, String>(
    (ref) => CollegeNameNotifier());

class CollegeNotifier extends StateNotifier<List<College>> {
  CollegeNotifier() : super([]);

  bool isCollegeLoading = true;

  List<College> filteredColleges = [];

  // api call to get the list of colleges
  Future<void> getColleges() async {
    isCollegeLoading = false;
    var resp = await NetworkUtils().httpGet("suborg/org/${AppConstants.orgId}");
    if (resp?.statusCode == 200) {
      // convert the response to list of colleges with iterables and college.fromjson()

      Iterable l = resp?.body != "null" ? json.decode(resp!.body) : [];

      List<College> colleges =
          List<College>.from(l.map((model) => College.fromJson(model)));
      state = colleges;
    }
    isCollegeLoading = false;
  }

  // Future<void> createCollege(College college) async {
  //   var resp = await NetworkUtils().httpPost("suborg/create", college.toJson());
  //   if (resp?.statusCode == 201) {
  //     var college = College.fromRawJson(resp!.body);
  //     print("Campus created: ${college.name}");
  //   } else {
  //     print(resp!.body);
  //   }
  // }

  Future<void> filterColleges(String district) async {
    filteredColleges =
        state.where((college) => college.district == district).toList();
  }

  void updateCollege(List<College> college) {
    state = college;
  }
}

final collegeProvider =
    StateNotifierProvider<CollegeNotifier, List<College>>((ref) {
  return CollegeNotifier();
});

class CollegeFilteredByDistrictNotifier extends StateNotifier<List<College>> {
  CollegeFilteredByDistrictNotifier() : super([]);

  List<College> fullColleges = [];

  void filterCollegesByDistrict(List<College> colleges, String district) {
    state = colleges.where((college) => college.district == district).toList();
    fullColleges = state;
  }

  void searchColleges(String search) {
    state = fullColleges
        .where((college) => college.name!.toLowerCase().contains(search))
        .toList();
  }
}

final collegeDistrictProvider =
    StateNotifierProvider<CollegeFilteredByDistrictNotifier, List<College>>(
        (ref) {
  return CollegeFilteredByDistrictNotifier();
});
