import 'package:equilead/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:equilead/models/profile.dart';
import 'package:equilead/widgets/common/qr.dart';

class MembershipCard extends StatefulWidget {
  final Profile profile;
  final String college;
  const MembershipCard({
    super.key,
    required this.profile,
    required this.college,
  });

  @override
  State<MembershipCard> createState() => _MembershipCardState();
}

class _MembershipCardState extends State<MembershipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController? animationController;

  lottieAnimation() {
    animationController = AnimationController(vsync: this);
  }

  @override
  void initState() {
    super.initState();
    lottieAnimation();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.width * 1.35,
      width: size.width * 0.86,
      margin: EdgeInsets.symmetric(
        horizontal: size.width * 0.07,
        vertical: size.width * 0.62,
      ),
      decoration: BoxDecoration(
        color: Color(0xffC7AEE8),
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expires on ${DateFormat('dd MMMM yyyy').format(widget.profile.createdAt!.add(Duration(days: 365 * 2)))}',
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.profile.uniqueId!.split('').join(' '),
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: QRCode(
                    size: size.width * 0.16,
                    data:
                        "https://app.tinkerhub.org/u/${widget.profile.uniqueId}",
                    avatar: "",
                  ),
                ),
              ],
            ),
          ),
          Spacer(flex: 3),
          //TODO: add equilead membership animation
          // SizedBox(
          //   width: double.infinity,
          //   child: Center(
          //     child: Lottie.asset(
          //       'assets/lottie/hub.json',
          //       repeat: true,
          //       frameRate: FrameRate(120),
          //       controller: animationController,
          //       onLoaded: (composition) {
          //         animationController!
          //           ..duration = composition.duration
          //           ..forward();
          //         animationController!.addListener(() {
          //           if (animationController!.isCompleted) {
          //             animationController!.repeat();
          //           }
          //         });
          //       },
          //     ),
          //   ),
          // ),
          Spacer(flex: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  backgroundImage: widget.profile.avatar == null
                      ? Image.asset(avatars[(widget.profile.id! % 7) - 1]).image
                      : NetworkImage(widget.profile.avatar!),
                ),
                SizedBox(height: 16),
                Text(
                  widget.profile.name!.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.profile.isStudent!
                      ? widget.college
                      : '${widget.profile.jobType != "Others" ? widget.profile.jobType : ""}${widget.profile.jobType != "Others" ? " at " : ''}${widget.profile.companyName}',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    height: 1,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
