import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/models/profile.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/widgets/common/checkbox_group.dart';

class ProfileNotifier extends StateNotifier<Profile> {
  ProfileNotifier() : super(Profile());

  bool isProfileLoading = true;
  String collegeName = "";

  List<CheckboxItem> languages = [];

  Future<Profile> getProfile(String userId) async {
    isProfileLoading = true;
    var resp =
        await NetworkUtils().httpGet("member/$userId/${AppConstants.orgId}");
    if (resp?.statusCode == 200) {
      var profile = Profile.fromRawJson(resp!.body);
      state = profile;
      isProfileLoading = false;
    }
    return state;
  }

  Future<Profile> createProfile(Profile profile) async {
    isProfileLoading = true;
    var resp = await NetworkUtils().httpPost("user/create", profile.toJson());
    print("--->");
    print(resp!.body);
    if (resp?.statusCode == 201) {
      var profile = Profile.fromRawJson(resp!.body);
      state = profile;
      isProfileLoading = false;
    }
    return state;
  }

  Future<Profile?> updateProfile() async {
    isProfileLoading = true;
    var resp =
        await NetworkUtils().httpPut("member/${state.id}", state.toJson());
    if (resp?.statusCode == 200) {
      var profile = Profile.fromRawJson(resp!.body);
      state = profile;
      isProfileLoading = false;
      return state;
    }
    return null;
  }

  Future<Profile?> updateCompleteProfile() async {
    isProfileLoading = true;
    var resp = await NetworkUtils()
        .httpPut("member/complete/${state.id}", state.toJson());
    if (resp?.statusCode == 200) {
      var profile = Profile.fromRawJson(resp!.body);
      state = profile;
      isProfileLoading = false;
      return state;
    }
    return null;
  }

  Future<void> deleteProfile() async {
    var resp = await NetworkUtils().httpDelete("member/${state.id}", {});
    if (resp?.statusCode == 200) {
      state = Profile();
    }
  }

  Future<void> updateInviteStatus(int invitedBy, String inviteePhone,
      int inviteeMembershipId, String inviteeName) async {
    var resp = await NetworkUtils().httpPut("member/invite/update", {
      "invitedBy": invitedBy,
      "inviteePhone": inviteePhone,
      "inviteeMembershipId": inviteeMembershipId,
      "inviteeName": inviteeName,
    });
    if (resp?.statusCode == 200) {
      var profile = Profile.fromRawJson(resp!.body);
      state = profile;
    }
  }

  void logout() {
    isProfileLoading = true;
    state = Profile();
  }

  void setUserIdAndOrgId(int userId, int orgId) {
    state.userId = userId;
    state.orgId = orgId;
  }

  void updateInvitedBy(int invitedBy) {
    state.invitedBy = invitedBy;
  }

  void updateStudentStatus(bool isStudent) {
    state.isStudent = isStudent;
  }

  void updateProfileName(String name) {
    state.name = name;
  }

  void updateProfileEmail(String email) {
    state.email = email;
  }

  void updateSex(String sex) {
    state.sex = sex;
  }

  void updateAvatar(File file) async {
    var url = await NetworkUtils().uploadImageToS3(file);
    var rUrl = jsonDecode(url);
    state.avatar = rUrl['imageUrl'];
  }

  void updateBio(String bio) {
    state.bio = bio;
  }

  void updateBirthday(DateTime birthday) {
    state.birthday = birthday.toIso8601String() + 'Z';
  }

  void updateCompanyName(String companyName) {
    state.companyName = companyName;
  }

  void updateJobType(String jobType) {
    state.jobType = jobType;
  }

  void updateDistrict(String district) {
    state.district = district;
  }

  void updateCollegeName(int? collegeId) {
    state.subOrgId = collegeId;
  }

  void updateStream(String? stream) {
    state.stream = stream;
  }

  void updateCourse(String course) {
    state.course = course;
  }

  void updateYears(int yearOfAdmission, int yearOfGraduation) {
    state.yearOfAdmission = yearOfAdmission;
    state.yearOfGraduation = yearOfGraduation;
  }

  void updateInterests(List<String> interests) {
    state.interests = interests.join(",");
  }

  void updateLanguages(List<CheckboxItem> langs) {
    languages = langs;
  }

  void updateSkills(List<CheckboxItem> langs) {
    state.skills = langs;
  }

  void setCollegeName(String name) {
    collegeName = name;
  }

  void updateSocials({String? linkedin, String? github, String? twitter}) {
    state.linkedin = linkedin;
    state.github = github;
    state.twitter = twitter;
  }

  void updateIsOnboard(bool isOnboard) {
    state.isOnboard = isOnboard;
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, Profile>(
  (ref) => ProfileNotifier(),
);

class ExternalProfileNotifier extends StateNotifier<Profile> {
  ExternalProfileNotifier() : super(Profile());

  bool isProfileLoading = false;

  Future getProfile(String uniqueId) async {
    isProfileLoading = true;
    var resp = await NetworkUtils().httpGet("member/$uniqueId");
    if (resp?.statusCode == 200) {
      var profile = Profile.fromRawJson(resp!.body);
      state = profile;
      isProfileLoading = false;
      return state;
    } else {
      return null;
    }
  }

  void updateProfile(Profile profile) {
    state = profile;
  }
}

final externalProfileProvider =
    StateNotifierProvider<ExternalProfileNotifier, Profile>(
  (ref) => ExternalProfileNotifier(),
);

class SchoolStudentNotifier extends StateNotifier<bool> {
  SchoolStudentNotifier() : super(false);

  void update(bool val) {
    state = val;
  }
}

final schoolStudentProvider =
    StateNotifierProvider<SchoolStudentNotifier, bool>(
  (ref) => SchoolStudentNotifier(),
);
