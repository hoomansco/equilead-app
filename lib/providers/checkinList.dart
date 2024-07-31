import 'dart:convert';
import 'dart:developer';

import 'package:equilead/models/checkInList.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/models/checkin.dart';
import 'package:equilead/utils/network_util.dart';

class CheckInListNotifier extends StateNotifier<List<CheckInList>> {
  CheckInListNotifier() : super([]);

  Future<List<CheckInList>> getCheckInListData() async {
    var resp = await NetworkUtils().httpGet('checkin/active');

    if (resp?.statusCode == 200 && json.decode(resp!.body)["status"]) {
      Iterable l = json.decode(resp!.body)["data"];
      List<CheckInList> checkInData =
          List<CheckInList>.from(l.map((model) => CheckInList.fromJson(model)))
              .toList();
      state = checkInData;
      return state;
    } else {
      state = [];
      return state;
    }
  }
}

final checkInListProvider =
    StateNotifierProvider<CheckInListNotifier, List<CheckInList>>(
        (ref) => CheckInListNotifier());
