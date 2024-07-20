import 'package:equilead/screens/auth/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:equilead/screens/checkin.dart';
import 'package:equilead/screens/no_internet.dart';
import 'package:equilead/screens/onboard/onboard.dart';
import 'package:equilead/screens/event/event.dart';
import 'package:equilead/screens/external_profile.dart';
import 'package:equilead/screens/main/navigation.dart';
import 'package:equilead/screens/opportunity/details.dart';
import 'package:equilead/screens/splash.dart';
import 'package:equilead/screens/tickets.dart';
import 'package:equilead/screens/vouch.dart';
import 'package:equilead/screens/walkthorugh.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:equilead/widgets/dialog_builder/builder.dart';
import 'package:equilead/widgets/transition/circle_reveal.dart';

final router = GoRouter(
  navigatorKey: DialogBuilder.navigatorKey,
  initialLocation: '/splash',
  redirect: (context, state) {
    var id = SharedPrefs().getMemberID();
    if (id.isEmpty) {
      return '/auth';
    } else {
      return null;
    }
  },
  onException: (context, state, router) {
    router.go('/');
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
    GoRoute(
      path: '/',
      // builder: (context, state) => MainNavigation(),
      pageBuilder: (context, state) => CircleRevealTransitionPage(
        key: state.pageKey,
        child: MainNavigation(),
      ),
      routes: [
        GoRoute(
          path: 'auth',
          // builder: (_, __) => Authentication(),
          pageBuilder: (context, state) => CircleRevealTransitionPage(
            key: state.pageKey,
            child: Authentication(),
          ),
        ),
        GoRoute(
            path: 'onboard/:invitedBy',
            builder: (context, state) {
              final invitedBy = state.pathParameters['invitedBy'].toString();
              return OnboardScreen(invitedBy: int.parse(invitedBy));
            }),
        GoRoute(path: 'vouch', builder: (context, state) => VouchPage()),
        GoRoute(path: 'no_internet', builder: (context, state) => NoInternet()),
        GoRoute(
            path: 'event/:id',
            name: 'eventDetails',
            builder: (c, s) {
              final id = s.pathParameters['id'].toString();
              return EventScreen(eventUniqueId: id);
            }),
        GoRoute(
            path: 'u/:id',
            name: 'memberDetails',
            builder: (c, s) {
              final id = s.pathParameters['id'].toString();
              return ExternalProfile(uniqueId: id);
            }),
        GoRoute(
            path: 'opportunity/:id',
            name: 'opportunityDetails',
            builder: (c, s) {
              final id = s.pathParameters['id'].toString();
              return OpportunityDetails(opportunityId: id);
            }),
        GoRoute(path: 'tickets', builder: (context, state) => TicketsPage()),
        GoRoute(
          path: 'checkin',
          builder: (context, state) => SpaceCheckIn(),
        ),
      ],
    ),
  ],
);
