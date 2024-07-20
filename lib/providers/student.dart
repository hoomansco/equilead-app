import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/widgets/common/checkbox_group.dart';

class StreamNotifier extends StateNotifier<List<Map<String, String>>> {
  StreamNotifier() : super(streams);

  List<Map<String, String>> allStreams = streams;
  List<Map<String, String>> filtered = [];

  void addData(List<Map<String, String>> data) {
    state = data;
    allStreams = data;
  }

  void filterStreamByCourse(String type) {
    state = allStreams
        .where((c) => c['type']!.toLowerCase() == type.toLowerCase())
        .toList();
    filtered = allStreams
        .where((c) => c['type']!.toLowerCase() == type.toLowerCase())
        .toList();
  }

  searchStream(String query) {
    state = filtered
        .where((c) => c['course']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

final streamProvider =
    StateNotifierProvider<StreamNotifier, List<Map<String, String>>>(
  (ref) => StreamNotifier(),
);

class LanguageProvider extends StateNotifier<List<CheckboxItem>> {
  LanguageProvider() : super([]);

  List<CheckboxItem> allLanguages = languages
      .map((e) => CheckboxItem(title: e['title'], icon: e['icon']))
      .toList();

  void selectedLanguages(List<CheckboxItem> data) {
    state = data;
  }

  void updateRating(int index, int level) {
    state[index].level = level;
  }
}

final languageProvider =
    StateNotifierProvider<LanguageProvider, List<CheckboxItem>>(
  (ref) => LanguageProvider(),
);
