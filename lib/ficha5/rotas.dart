import 'package:go_router/go_router.dart';
import 'main_ex_4.dart';
import 'route_2_ex_4.dart';

final GoRouter routerEx4 = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(title: 'Primeira Route'),
    ),
    GoRoute(
      path: '/route2',
      builder: (context, state) => const Route2Ex4(title: 'Segunda Route'),
    ),
  ],
);
