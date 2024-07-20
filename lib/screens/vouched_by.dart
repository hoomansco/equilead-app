import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/models/vouch.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/widgets/animation/floating_animation.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';

class VouchedBy extends ConsumerStatefulWidget {
  final String membershipId;
  final String profileName;
  const VouchedBy({super.key, this.membershipId = "1", this.profileName = ""});

  @override
  _VouchedByState createState() => _VouchedByState();
}

class _VouchedByState extends ConsumerState<VouchedBy> {
  Size get size => MediaQuery.of(context).size;
  // bool _isLoading = true;
  List<Vouch> vouches = [];

  @override
  void initState() {
    super.initState();
    _getVouches();
  }

  Future<void> _getVouches() async {
    var resp =
        await NetworkUtils().httpGet('member/invite/m/${widget.membershipId}');
    if (resp?.statusCode == 200) {
      var jsdec = jsonDecode(resp!.body);
      if (jsdec["status"]) {
        Iterable l = jsdec["data"];
        List<Vouch> vouches =
            List<Vouch>.from(l.map((model) => Vouch.fromJson(model))).toList();
        vouches =
            vouches.where((el) => el.status == "accepted").take(9).toList();
        setState(() {
          this.vouches = vouches;
          // _isLoading = false;
        });
      } else {
        setState(() {
          this.vouches = [];
          // _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconWrapper(
                          icon: "assets/icons/back.svg",
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Spacer(flex: 4),
                      Image.asset("assets/images/animated/clap.png",
                          height: 50, width: 50),
                      Text(
                        "Vouch by ${widget.profileName}",
                        style: TextStyle(
                          fontFamily: "General Sans",
                          color: Color(0xFF000000),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Vouching is the act of endorsing someone to build trust and credibility.",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(flex: 6),
                    ],
                  ),
                ),
              ),
              vouches.isNotEmpty
                  ? FloatsProfiles(
                      vouches: vouches,
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
