import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:equilead/models/ticket.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/event/upcoming_events.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/empty_state.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:equilead/widgets/common/ticket_card.dart';

class TicketsPage extends ConsumerStatefulWidget {
  const TicketsPage({super.key});

  @override
  _TicketsPageState createState() => _TicketsPageState();
}

class _TicketsPageState extends ConsumerState<TicketsPage> {
  bool isLoading = true;
  late List<Ticket> tickets = [];
  @override
  void initState() {
    getTickets();
    super.initState();
  }

  Future getTickets() async {
    var profile = ref.read(profileProvider);
    var resp = await NetworkUtils().httpGet("member/tickets/${profile.id}");
    if (resp?.statusCode == 200) {
      Iterable l = json.decode(resp!.body);
      List<Ticket> ts =
          List<Ticket>.from(l.map((model) => Ticket.fromJson(model)));
      tickets = ts;
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AnnotatedRegion(
      value: Platform.isIOS
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.white,
              systemNavigationBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.white,
            ),
      child: Scaffold(
        body: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            color: Color(0xFF282828),
          ),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        DelayedAnimation(
                          delayedAnimation: 450,
                          aniOffsetX: -0.15,
                          aniOffsetY: 0,
                          aniDuration: 300,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: IconWrapper(
                                icon: "assets/icons/back.svg",
                                onTap: () {
                                  context.pop();
                                  HapticFeedback.lightImpact();
                                }),
                          ),
                        ),
                        SizedBox(height: 32),
                        tickets.isEmpty
                            ? SizedBox(
                                height: size.height * 0.6,
                                child: Center(
                                  child: SizedBox(
                                    width: size.width * 0.45,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        EmptyState(
                                          text:
                                              "Your event tickets will be shown here",
                                          isDark: true,
                                        ),
                                        SizedBox(height: 16),
                                        PressEffect(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UpcomingEvents(),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                                12, 8, 12, 8),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              'GO TO EVENTS',
                                              style: TextStyle(
                                                fontFamily: 'General Sans',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                height: 1.2,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: SizedBox(
                                  height: 420,
                                  width: size.width,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: tickets.length,
                                    padding: tickets.length == 1
                                        ? EdgeInsets.only(
                                            left: size.width * 0.08,
                                          )
                                        : EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      return DelayedAnimation(
                                        delayedAnimation: 500 + (index * 80),
                                        aniOffsetX: -0.18,
                                        aniOffsetY: 0,
                                        aniDuration: 250,
                                        child: PressEffect(
                                          onPressed: () async {
                                            HapticFeedback.lightImpact();
                                            await showFullScreenTicket(
                                              tickets[index],
                                            );
                                          },
                                          child: TicketCard(
                                            ticket: tickets[index],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> showFullScreenTicket(Ticket ticket) async {
    Size size = MediaQuery.of(context).size;
    await showAdaptiveDialog(
      context: context,
      builder: (context) => PressEffect(
        onPressed: () => context.pop(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            height: size.height,
            width: size.width,
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: TicketCard(ticket: ticket, scaleFactor: 1.2),
            ),
          ),
        ),
      ),
    );
  }
}
