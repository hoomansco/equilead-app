import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:equilead/models/profile.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';

class QRCodeScanner extends ConsumerStatefulWidget {
  final int eventId;
  final VoidCallback onPop;

  const QRCodeScanner({super.key, required this.eventId, required this.onPop});

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends ConsumerState<QRCodeScanner> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  String qrCode = '';
  bool isScanned = false;
  bool isValid = false;
  bool isConfirmed = false;
  Attendee attendee = Attendee();
  bool isLoading = false;
  DateTime checkInTime = DateTime.now();

  void getMemberFromQR() async {
    var resp = await NetworkUtils()
        .httpGet('event/attendee/${widget.eventId}/ticket/$qrCode');
    if (resp?.statusCode == 200) {
      var data = resp?.body;
      if (data != null) {
        setState(() {
          attendee = Attendee.fromRawJson(data);
          if (!attendee.checkIn!) {
            isValid = true;
          } else {
            isValid = false;
          }
        });
        _showCheckinModal();
      }
    } else {
      setState(() {
        isValid = false;
      });
      _showCheckinModal();
    }
  }

  Future<bool> confirmCheckIn() async {
    var profile = ref.read(profileProvider);
    var resp = await NetworkUtils().httpPost('event/checkin', {
      "id": attendee.id,
      "checkIn": true,
      "checkInBy": profile.id,
    });
    if (resp?.statusCode == 200) {
      setState(() {
        isConfirmed = true;
        var a = Attendee.fromRawJson(resp!.body);
        checkInTime = a.checkInTime!.toLocal();
      });
      return true;
    } else {
      setState(() {
        isConfirmed = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          widget.onPop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconWrapper(
                      icon: "assets/icons/back.svg",
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    Spacer(flex: 3),
                    Text(
                      'Scan the QR code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'General Sans',
                      ),
                    ),
                    Spacer(flex: 5),
                  ],
                ),
              ),
              Spacer(flex: 3),
              Container(
                height: size.width - 40,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: QRView(
                    key: _qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    formatsAllowed: [BarcodeFormat.qrcode],
                  ),
                ),
              ),
              Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) {
      if (scanData.format == BarcodeFormat.qrcode && !isScanned) {
        setState(() {
          qrCode = scanData.code!;
          isScanned = true;
        });
        getMemberFromQR();
      }
    });
  }

  Future<void> _showCheckinModal() async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isConfirmed
                    ? Container(
                        width: double.infinity,
                        height: 40,
                        padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
                        decoration: BoxDecoration(
                          color: Color(0xff3CD377),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset("assets/icons/white-check.svg"),
                            SizedBox(width: 8),
                            Text(
                              'Checked In'.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'General Sans',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, 32, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: isConfirmed
                        ? BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          )
                        : BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isValid
                          ? CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(attendee.avatar!),
                            )
                          : SizedBox(
                              height: 40,
                              width: 40,
                              child: Image.asset(
                                "assets/images/FacewithMonocle.png",
                              ),
                            ),
                      SizedBox(height: 16),
                      Text(
                        isValid ? attendee.name! : 'Unable to validate',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'General Sans',
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        isValid
                            ? attendee.isStudent!
                                ? 'Student'
                                : attendee.companyName!
                            : "Verify if your QR code has already been scanned for check-in, or if it belongs to a different event.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'General Sans',
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 16),
                      isConfirmed
                          ? Text(
                              'Checked In @ ${DateFormat('hh:mm a').format(checkInTime.toLocal())}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'General Sans',
                              ),
                              maxLines: 2,
                            )
                          : SizedBox.shrink(),
                      SizedBox(height: 16),
                      Divider(
                        color: Color(0xffEBEBEB),
                        thickness: 1,
                        height: 1,
                      ),
                      SizedBox(height: 32),
                      isValid
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PressEffect(
                                  onPressed: isConfirmed
                                      ? () {}
                                      : () {
                                          Navigator.pop(context);
                                          setState(() {
                                            attendee = Attendee();
                                            isValid = false;
                                            isScanned = false;
                                            qrCode = '';
                                            isLoading = false;
                                            isConfirmed = false;
                                          });
                                        },
                                  child: Container(
                                    height: 40,
                                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      isConfirmed ? 'Scan next' : 'Try again',
                                      style: TextStyle(
                                        fontFamily: 'General Sans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        height: 1.15,
                                      ),
                                    ),
                                  ),
                                ),
                                PressEffect(
                                  onPressed: isLoading
                                      ? () {}
                                      : isValid
                                          ? isConfirmed
                                              ? () {
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    attendee = Attendee();
                                                    isValid = false;
                                                    isScanned = false;
                                                    qrCode = '';
                                                    isLoading = false;
                                                    isConfirmed = false;
                                                  });
                                                }
                                              : () {
                                                  if (mounted) {
                                                    setModalState(() {
                                                      isLoading = true;
                                                    });
                                                  }
                                                  confirmCheckIn()
                                                      .then((value) {
                                                    if (mounted) {
                                                      setModalState(() {
                                                        isLoading = false;
                                                      });
                                                    }
                                                  });
                                                }
                                          : () {
                                              Navigator.pop(context);
                                              setState(() {
                                                attendee = Attendee();
                                                isValid = false;
                                                isScanned = false;
                                                qrCode = '';
                                                isLoading = false;
                                                isConfirmed = false;
                                              });
                                            },
                                  child: Container(
                                    height: 40,
                                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                    decoration: BoxDecoration(
                                      color: isLoading
                                          ? Color(0xffA3A3A3)
                                          : Colors.black,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: isLoading
                                            ? Color(0xffA3A3A3)
                                            : Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          isValid
                                              ? isConfirmed
                                                  ? 'Done'
                                                  : 'Confirm'
                                              : 'Try again',
                                          style: TextStyle(
                                            fontFamily: 'General Sans',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            height: 1.15,
                                          ),
                                        ),
                                        isLoading
                                            ? SizedBox(width: 8)
                                            : SizedBox.shrink(),
                                        isLoading
                                            ? SizedBox(
                                                width: 15,
                                                height: 15,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                      Colors.white,
                                                    ),
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : PressEffect(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  attendee = Attendee();
                                  isValid = false;
                                  isScanned = false;
                                  qrCode = '';
                                  isLoading = false;
                                  isConfirmed = false;
                                });
                              },
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                alignment: Alignment.center,
                                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                decoration: BoxDecoration(
                                  color: isLoading
                                      ? Color(0xffA3A3A3)
                                      : Colors.black,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isLoading
                                        ? Color(0xffA3A3A3)
                                        : Colors.black,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Try again',
                                  style: TextStyle(
                                    fontFamily: 'General Sans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.15,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
