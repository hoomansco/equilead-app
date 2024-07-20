import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:equilead/models/vouch.dart';
import 'package:equilead/screens/external_profile.dart';

class FloatsProfiles extends StatefulWidget {
  FloatsProfiles({Key? key, required this.vouches}) : super(key: key);
  final List<Vouch> vouches;

  @override
  State<FloatsProfiles> createState() => _FloatsProfilesState();
}

class _FloatsProfilesState extends State<FloatsProfiles>
    with SingleTickerProviderStateMixin {
  final double _circleSize = 100;
  List<Offset> _circlePositions = [];
  List<double> _moveValue = [0.6, 0.8, 0.3, 0.2, 0.1, 0.4, 0.7, 0.5, 0.9, 0.1];
  double _xDistance = 0;
  @override
  void initState() {
    super.initState();
    move();
  }

  move() {
    for (var i = 0; i < widget.vouches.length; i++) {
      if ((i % 2) == 0) {
        moveRight(_moveValue[i], i);
      } else {
        moveLeft(_moveValue[i], i);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void moveRight(double slope, int i) {
    Timer.periodic(const Duration(milliseconds: 15), (timer) {
      _xDistance = sqrt(1 / (1 + pow(slope, 2)));
      if (!mounted) return;
      setState(() {
        _circlePositions[i] = Offset(_circlePositions[i].dx + _xDistance,
            _circlePositions[i].dy - slope * _xDistance);
      });

      //if the ball bounces off the top or bottom
      if (_circlePositions[i].dy < 0 ||
          _circlePositions[i].dy >
              MediaQuery.of(context).size.height - _circleSize) {
        timer.cancel();
        moveRight(-slope, i);
      }
      //if the ball bounces off the right
      if (_circlePositions[i].dx >
          MediaQuery.of(context).size.width - (_circleSize * 0.5)) {
        timer.cancel();
        moveLeft(-slope, i);
      }
    });
  }

  void moveLeft(double slope, int i) {
    Timer.periodic(const Duration(milliseconds: 15), (timer) {
      _xDistance = sqrt(1 / (1 + pow(slope, 2)));
      if (!mounted) return;
      setState(() {
        _circlePositions[i] = Offset(_circlePositions[i].dx - _xDistance,
            _circlePositions[i].dy + slope * _xDistance);
      });
      //if the ball bounces off the top or bottom
      if (_circlePositions[i].dy < 0 ||
          _circlePositions[i].dy >
              MediaQuery.of(context).size.height - _circleSize) {
        timer.cancel();
        moveLeft(-slope, i);
      }
      //if the ball bounces off the left
      if (_circlePositions[i].dx < 0) {
        timer.cancel();
        moveRight(-slope, i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_circlePositions.isEmpty) {
      _circlePositions = List.generate(
        widget.vouches.length,
        (i) => Offset(
          (MediaQuery.of(context).size.width - _circleSize) / 2,
          (MediaQuery.of(context).size.height - _circleSize),
        ),
      );
    }
    return Stack(alignment: Alignment.bottomCenter, children: profilesWidget());
  }

  List<Widget> profilesWidget() {
    List<Widget> list = [];
    for (var i = 0; i < widget.vouches.length; i++) {
      list.add(
        Positioned(
          left: _circlePositions[i].dx,
          top: _circlePositions[i].dy,
          child: Container(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // context.go('/u/${widget.vouches[i].inviteeUniqueId}');
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ExternalProfile(
                          uniqueId: widget.vouches[i].inviteeUniqueId!,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.network(
                        "${widget.vouches[i].inviteeAvatar}",
                        fit: BoxFit.cover,
                      ),
                      height: _circleSize * 0.5,
                      width: _circleSize * 0.5,
                    ),
                  ),
                ),
                Text(
                  widget.vouches[i].inviteeName!.split(' ')[0],
                  style: TextStyle(
                    fontFamily: "General Sans",
                    fontWeight: FontWeight.w500,
                    color: Color(
                      0xFF2E2E2E,
                    ),
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      );
    }
    return list;
  }
}
