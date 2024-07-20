import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:equilead/providers/opportunity.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:equilead/widgets/common/opportunity_card.dart';

class OpportunityListing extends ConsumerStatefulWidget {
  const OpportunityListing({super.key});

  @override
  _OpportunityListingState createState() => _OpportunityListingState();
}

class _OpportunityListingState extends ConsumerState<OpportunityListing> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: size.width,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Row(
                children: [
                  IconWrapper(
                    icon: "assets/icons/back.svg",
                    onTap: () {
                      context.pop();
                      HapticFeedback.lightImpact();
                    },
                  ),
                  SizedBox(width: 24),
                  Text(
                    'Opportunities',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ListView.separated(
                itemCount: ref.watch(opportunityProvider).length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return DelayedAnimation(
                    delayedAnimation: 450 + (index * 80),
                    aniOffsetX: 0,
                    aniOffsetY: -0.18,
                    aniDuration: 250,
                    child: OpportunityCard(
                      opportunity: ref.watch(opportunityProvider)[index],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return DelayedAnimation(
                    delayedAnimation: 680 + (index * 50),
                    aniOffsetX: 0,
                    aniOffsetY: -0.18,
                    aniDuration: 250,
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xffEBEBEB),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
