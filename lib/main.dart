import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/todo_screen.dart';
import 'screens/alarm_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/menstruation_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/notification_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID');
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Zira',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
            primary: Colors.pink[400],
            secondary: Colors.pink[300],
            tertiary: Colors.pink[200],
            background: Colors.pink[50],
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          textTheme: TextTheme(
            displayLarge: TextStyle(color: Colors.pink[700]),
            displayMedium: TextStyle(color: Colors.pink[700]),
            displaySmall: TextStyle(color: Colors.pink[700]),
            headlineLarge: TextStyle(color: Colors.pink[700]),
            headlineMedium: TextStyle(color: Colors.pink[700]),
            headlineSmall: TextStyle(color: Colors.pink[700]),
            titleLarge: TextStyle(color: Colors.pink[700]),
            titleMedium: TextStyle(color: Colors.pink[700]),
            titleSmall: TextStyle(color: Colors.pink[700]),
            bodyLarge: TextStyle(color: Colors.pink[900]),
            bodyMedium: TextStyle(color: Colors.pink[900]),
            bodySmall: TextStyle(color: Colors.pink[900]),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.pink[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.pink[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.pink[400]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/calendar': (context) => const CalendarScreen(),
          '/todo': (context) => const TodoScreen(),
          '/alarm': (context) => const AlarmScreen(),
          '/budget': (context) => const BudgetScreen(),
          '/menstruation': (context) => const MenstruationScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}