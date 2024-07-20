import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:equilead/models/opportunity.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/action_sheet.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';

class OpportunityDetails extends StatefulWidget {
  const OpportunityDetails({super.key, required this.opportunityId});
  final String opportunityId;

  @override
  State<OpportunityDetails> createState() => _OpportunityDetailsState();
}

class _OpportunityDetailsState extends State<OpportunityDetails>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Opportunity _opportunity = Opportunity();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    getOpportunity();

    super.initState();
  }

  void fadeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    _controller.forward();
  }

  Future<void> getOpportunity() async {
    var resp =
        await NetworkUtils().httpGet('opportunity/${widget.opportunityId}');
    if (resp?.statusCode == 200) {
      var result = jsonDecode(resp!.body);
      setState(() {
        _opportunity = Opportunity.fromJson(result);
        _isLoading = false;
        fadeAnimation();
      });
    } else {
      showFindErrorModal();
    }
  }

  Future<void> showFindErrorModal() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        color: Colors.transparent,
        child: CommonActionSheet(
          action: AppAction.Error,
          text: 'Unable to find this opportunity!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth: 2,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: size.width,
                      decoration: BoxDecoration(
                        color: Color(0xffE8F5FE),
                        image: DecorationImage(
                          image: AssetImage("assets/images/opp-grid.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 12),
                              DelayedAnimation(
                                delayedAnimation: 450,
                                aniOffsetX: 0,
                                aniOffsetY: -0.15,
                                aniDuration: 250,
                                child: Row(
                                  children: [
                                    IconWrapper(
                                      icon: "assets/icons/back.svg",
                                      onTap: () {
                                        context.pop();
                                        HapticFeedback.lightImpact();
                                      },
                                    ),
                                    Spacer(),
                                    IconWrapper(
                                      icon: "assets/icons/share.svg",
                                      onTap: () async {
                                        await Share.share(
                                          'https://app.tinkerhub.org/opportunity/${_opportunity.id}',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32),
                              DelayedAnimation(
                                delayedAnimation: 550,
                                aniOffsetX: 0,
                                aniOffsetY: -0.15,
                                aniDuration: 250,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _opportunity.companyName!,
                                          style: TextStyle(
                                            fontFamily: 'General Sans',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        SizedBox(
                                          width: size.width * 0.68,
                                          child: Text(
                                            _opportunity.title!,
                                            style: TextStyle(
                                              fontFamily: 'General Sans',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          '${_opportunity.location}',
                                          style: TextStyle(
                                            fontFamily: 'General Sans',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    SizedBox(
                                      height: 48,
                                      width: 48,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          _opportunity.companyLogo!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32),
                              DelayedAnimation(
                                delayedAnimation: 650,
                                aniOffsetX: 0,
                                aniOffsetY: -0.15,
                                aniDuration: 250,
                                child: Row(
                                  children: [
                                    OppChip(title: _opportunity.type!),
                                    OppChip(title: _opportunity.mode!),
                                    _opportunity.category != null
                                        ? OppChip(title: _opportunity.category!)
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 40),
                        DelayedAnimation(
                          delayedAnimation: 700,
                          aniOffsetX: 0,
                          aniOffsetY: -0.15,
                          aniDuration: 250,
                          child: Text(
                            'Job description',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        DelayedAnimation(
                          delayedAnimation: 750,
                          aniOffsetX: 0,
                          aniOffsetY: -0.05,
                          aniDuration: 250,
                          child: Text(
                            _opportunity.description!,
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        _opportunity.isVolunteering!
                            ? SizedBox.shrink()
                            : SizedBox(height: 40),
                        _opportunity.isVolunteering!
                            ? SizedBox.shrink()
                            : DelayedAnimation(
                                delayedAnimation: 800,
                                aniOffsetX: 0,
                                aniOffsetY: -0.15,
                                aniDuration: 250,
                                child: Text(
                                  'Monthly Compensation',
                                  style: TextStyle(
                                    fontFamily: 'General Sans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                        _opportunity.isVolunteering!
                            ? SizedBox.shrink()
                            : SizedBox(height: 24),
                        _opportunity.isVolunteering!
                            ? SizedBox.shrink()
                            : DelayedAnimation(
                                delayedAnimation: 850,
                                aniOffsetX: 0,
                                aniOffsetY: -0.15,
                                aniDuration: 250,
                                child: Text(
                                  '${_opportunity.compensation!}',
                                  style: TextStyle(
                                    fontFamily: 'General Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                        SizedBox(height: 40),
                        DelayedAnimation(
                          delayedAnimation: 850,
                          aniOffsetX: 0,
                          aniOffsetY: -0.15,
                          aniDuration: 250,
                          child: Text(
                            'About ${_opportunity.companyName}',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        DelayedAnimation(
                          delayedAnimation: 900,
                          aniOffsetX: 0,
                          aniOffsetY: -0.15,
                          aniDuration: 250,
                          child: Text(
                            '${_opportunity.companyInfo ?? ""}',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 120),
                ],
              ),
            ),
      floatingActionButton: _isLoading
          ? SizedBox.shrink()
          : _opportunity.deadline!.isBefore(DateTime.now()) ||
                  _opportunity.externalLink == null
              ? SizedBox.shrink()
              : DelayedAnimation(
                  delayedAnimation: 950,
                  aniOffsetX: 0,
                  aniOffsetY: 0.18,
                  aniDuration: 400,
                  child: PressEffect(
                    onPressed: _opportunity.isExternal!
                        ? () {
                            HapticFeedback.lightImpact();
                            launchUrl(
                              Uri.parse(
                                _opportunity.externalLink!,
                              ),
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        : () {},
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Apply now',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          _opportunity.isExternal!
                              ? SizedBox(width: 8)
                              : SizedBox.shrink(),
                          _opportunity.isExternal!
                              ? SvgPicture.asset(
                                  "assets/icons/arrow-top-right.svg",
                                  height: 20,
                                  width: 20,
                                  colorFilter: ColorFilter.mode(
                                      Colors.white, BlendMode.srcIn),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class OppChip extends StatelessWidget {
  const OppChip({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'General Sans',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }
}
