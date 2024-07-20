import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({super.key});

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  bool _isLoading = false;

  Future<bool?>? checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('equilead.hoomans.dev');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return null;
  }

  void reRouteOnInternet() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration(seconds: 1), () {
      checkInternetConnection()!.then((value) {
        if (value == true) {
          context.go('/splash');
        }
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    "assets/images/miss_you.gif",
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  "We miss you too!",
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: 322,
                  child: Text(
                    "Unfortunately, the internet doesn't seem to miss us",
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff2E2E2E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Spacer(),
                _isLoading
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: Colors.black,
                        ),
                      )
                    : SizedBox(
                        height: 16,
                        width: 16,
                      ),
                Spacer(),
                Container(
                  padding: EdgeInsets.fromLTRB(12, 6, 8, 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset("assets/icons/cloud-off.svg"),
                      SizedBox(width: 4),
                      Text(
                        'You are Offline',
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      PressEffect(
                        onPressed: () => reRouteOnInternet(),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(8, 6, 8, 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'Retry'.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
