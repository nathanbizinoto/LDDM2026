import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'services/ab_test_service.dart';
import 'services/order_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(OficinaApp(prefs: prefs));
}

class OficinaApp extends StatelessWidget {
  final SharedPreferences prefs;

  const OficinaApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderRepository()),
        ChangeNotifierProvider(create: (_) => ABTestService(prefs)),
      ],
      child: MaterialApp(
        title: 'Oficina Rápida',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
