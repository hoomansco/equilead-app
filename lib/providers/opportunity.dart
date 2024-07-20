import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/models/opportunity.dart';
import 'package:equilead/utils/network_util.dart';

class OpportunityNotifier extends StateNotifier<List<Opportunity>> {
  OpportunityNotifier() : super([]);

  Future getOpportunities() async {
    var resp = await NetworkUtils().httpGet("opportunity/active");
    if (resp?.statusCode == 200) {
      if (json.decode(resp!.body)["status"]) {
        Iterable l = json.decode(resp.body)["data"];
        List<Opportunity> opportunities = List<Opportunity>.from(
            l.map((model) => Opportunity.fromJson(model))).toList();
        state = opportunities;
      }
    } else {
      state = [];
    }
  }

  void updateOpportunity(List<Opportunity> opportunity) {
    state = opportunity;
  }
}

final opportunityProvider =
    StateNotifierProvider<OpportunityNotifier, List<Opportunity>>(
  (ref) => OpportunityNotifier(),
);
