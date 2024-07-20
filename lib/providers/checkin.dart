import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/models/checkin.dart';
import 'package:equilead/utils/network_util.dart';

class CheckInNotifier extends StateNotifier<CheckIn> {
  CheckInNotifier() : super(CheckIn());

  void checkIn(CheckIn checkIn) {
    state = checkIn;
  }

  Future checkOut(int id) async {
    var resp = await NetworkUtils().httpPut(
      'checkin/out',
      {
        'id': id,
        'checkOutTime': '${DateTime.now().toIso8601String()}' + '+05:30',
      },
    );
    if (resp?.statusCode == 200) {
      state = CheckIn();
    }
  }

  Future checkOutExtend(int id, DateTime checkOutTime, int hours) async {
    var resp = await NetworkUtils().httpPut(
      'checkin/out',
      {
        'id': id,
        'checkOutTime':
            '${checkOutTime.add(Duration(hours: hours)).toIso8601String()}' +
                '+05:30',
      },
    );
    if (resp?.statusCode == 200) {
      // success
    }
  }

  Future<bool> createCheckIn(CheckIn checkIn) async {
    var resp = await NetworkUtils().httpPost(
      'checkin/create',
      checkIn.toJson(),
    );
    if (resp?.statusCode == 201) {
      state = CheckIn.fromRawJson(resp!.body);
      return true;
    } else {
      state = CheckIn();
      return false;
    }
  }

  Future<bool> getCheckInData(int membershipId) async {
    String currentTime = DateTime.now().toUtc().toIso8601String();
    var resp = await NetworkUtils()
        .httpGet('checkin/member/${membershipId}/time/$currentTime');

    if (resp?.statusCode == 200) {
      state = CheckIn.fromRawJson(resp!.body);
      return true;
    } else {
      state = CheckIn();
      return false;
    }
  }
}

final checkInProvider =
    StateNotifierProvider<CheckInNotifier, CheckIn>((ref) => CheckInNotifier());
