import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCode extends StatelessWidget {
  final String data;
  final String avatar;
  final double size;
  const QRCode({
    Key? key,
    required this.size,
    required this.data,
    required this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        QrImageView(
          padding: EdgeInsets.all(size * 0.03),
          backgroundColor: Colors.white,
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: Color(0xff171717),
          ),
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.circle,
            color: Color(0xff171717),
          ),
          data: data,
          version: 5,
          size: size,
        ),
        avatar == ""
            ? SizedBox.shrink()
            : Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: size,
                  width: size,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          avatar,
                          height: size * 0.15,
                          width: size * 0.15,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
