import 'package:bytelogik/core/provider/user_provider.dart';
import 'package:bytelogik/features/auth/view/pages/login_in.dart';
import 'package:bytelogik/features/auth/view/pages/sign_up.dart';
import 'package:bytelogik/features/home/view/pages/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:bytelogik/core/navigation/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bytelogik/core/storage/offline_storage_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(userNotifierProvider.notifier).loadAnyUser();
  final loggedIn = await OfflineStorageHelper().getLoggedInUser();
  final hasLoggedIn = loggedIn != null;

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(initialLocation: hasLoggedIn ? '/home' : '/login'),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialLocation});

  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      navigatorKey: appNavigatorKey,
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', redirect: (_, __) => '/login'),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      ],
    );

    return MaterialApp.router(
      title: 'Flutter Demo',
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router, 
    );
  }
}

