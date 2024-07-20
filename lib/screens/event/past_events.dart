import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:equilead/models/event.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:equilead/widgets/event/card.dart';

class PastEvents extends ConsumerStatefulWidget {
  const PastEvents({super.key});

  @override
  _PastEventsState createState() => _PastEventsState();
}

class _PastEventsState extends ConsumerState<PastEvents> {
  ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool hasReachedEnd = false;
  bool stopTrigger = false;
  int currentPage = 0;
  int limit = 10;
  List<Event> pastEvents = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _getPastEvents(currentPage, limit));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _getPastEvents(int page, int limit) async {
    try {
      var resp = await NetworkUtils()
          .httpGet("event/foundation/past?page=$page&limit=$limit");
      if (resp?.statusCode == 200) {
        if (jsonDecode(resp!.body)["status"]) {
          Iterable l = jsonDecode(resp.body)["data"];
          List<Event> newEvents =
              List<Event>.from(l.map((model) => Event.fromJson(model)))
                  .toList();
          setState(() {
            pastEvents.addAll(newEvents);
            currentPage++;
            hasReachedEnd = newEvents.length < limit;
            stopTrigger = false;
          });
        }
      } else {
        throw Error();
      }
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels + 70 >=
            _scrollController.position.maxScrollExtent &&
        !hasReachedEnd &&
        !stopTrigger) {
      setState(() {
        stopTrigger = true;
      });
      _getPastEvents(currentPage, limit);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  controller: _scrollController,
                  children: [
                    SizedBox(height: 12),
                    Row(
                      children: [
                        IconWrapper(
                          icon: "assets/icons/back.svg",
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(width: 24),
                        Text(
                          "Past events",
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 24),
                    Container(
                      width: size.width,
                      child: pastEvents.isEmpty
                          ? DelayedAnimation(
                              delayedAnimation: 400,
                              aniOffsetX: 0,
                              aniOffsetY: -0.18,
                              aniDuration: 250,
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 64, 16, 32),
                                  child: Text(
                                    'No past events',
                                    style: TextStyle(
                                      fontFamily: 'General Sans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black45,
                                      height: 0.9,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: pastEvents.length,
                              itemBuilder: (context, index) {
                                return DelayedAnimation(
                                  delayedAnimation: 400 + (index * 80),
                                  aniOffsetX: 0,
                                  aniOffsetY: -0.18,
                                  aniDuration: 250,
                                  child: EventCard(
                                    index: index,
                                    featured: pastEvents[index].featured!,
                                    eventUniqueId: pastEvents[index].uniqueId!,
                                    title: pastEvents[index].name!,
                                    coloured: false,
                                    isExternal: pastEvents[index].isExternal!,
                                    date: pastEvents[index].startDate.day ==
                                            pastEvents[index].endDate.day
                                        ? DateFormat('d MMM · hh:mm a').format(
                                                pastEvents[index].startDate) +
                                            ' - ' +
                                            DateFormat('hh:mm a').format(
                                                pastEvents[index].endDate)
                                        : DateFormat('d MMM · hh:mm a').format(
                                                pastEvents[index].startDate) +
                                            ' - ' +
                                            DateFormat('d MMM · hh:mm a')
                                                .format(
                                                    pastEvents[index].endDate),
                                    location: pastEvents[index].location ?? "",
                                    type: pastEvents[index].type!,
                                    isInviteOnly:
                                        pastEvents[index].isInviteOnly!,
                                    isVirtual: pastEvents[index].isVirtual!,
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return DelayedAnimation(
                                  delayedAnimation: 775 + (index * 80),
                                  aniOffsetX: 0,
                                  aniOffsetY: -0.18,
                                  aniDuration: 250,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 4),
                                      Divider(
                                        thickness: 1,
                                        color: Color(0xffEBEBEB),
                                      ),
                                      SizedBox(height: 4),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
