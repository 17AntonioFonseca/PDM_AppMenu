import 'package:go_router/go_router.dart';
import 'main_ex_6.dart';
import 'defi.dart';
import 'logi.dart';

final GoRouter rotasEx6 = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainEx6(title: 'Página Inicial'),
    ),
    GoRoute(
      path: '/defin',
      builder: (context, state) => const DefinRoute(title: 'Definições'),
    ),
    GoRoute(
      path: '/logi',
      builder: (context, state) => const LogiRoute(title: 'Login'),
    ),
  ],
);
