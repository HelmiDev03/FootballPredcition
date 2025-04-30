import 'package:flutter/material.dart';
import 'package:football_predictions_app/providers/league_provider.dart';
import 'package:football_predictions_app/providers/match_provider.dart'; // Import MatchProvider
import 'package:football_predictions_app/views/leagues_screen.dart';
import 'package:football_predictions_app/views/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Placeholder for Theme Provider - will be implemented later
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using MultiProvider to provide multiple providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LeagueProvider()), 
        ChangeNotifierProvider(create: (_) => MatchProvider()), // Provide MatchProvider
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Football Predictions',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              textTheme: GoogleFonts.latoTextTheme(
                Theme.of(context).textTheme,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue, brightness: Brightness.dark),
              textTheme: GoogleFonts.latoTextTheme(
                Theme.of(context).primaryTextTheme, // Use primaryTextTheme for dark mode
              ),
              useMaterial3: true,
            ),
            home: const MainNavigationScreen(),
            // Define routes for navigation if needed later
            // routes: {
            //   '/matchList': (context) => MatchListScreen(), 
            // },
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Initialize pages only once
  final List<Widget> _widgetOptions = <Widget>[
    const LeaguesScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use IndexedStack to keep the state of the screens when switching tabs
      body: IndexedStack(
         index: _selectedIndex,
         children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Leagues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}

