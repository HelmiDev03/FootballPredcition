import 'package:flutter/material.dart';
import 'package:football_predictions_app/models/league.dart'; // Import League model
import 'package:football_predictions_app/providers/league_provider.dart';
import 'package:football_predictions_app/views/match_list_screen.dart'; // Import MatchListScreen
import 'package:provider/provider.dart';

class LeaguesScreen extends StatefulWidget {
  const LeaguesScreen({super.key});

  @override
  State<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends State<LeaguesScreen> {

  @override
  void initState() {
    super.initState();
    // Fetch leagues when the screen is first initialized
    // Use addPostFrameCallback to ensure Provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if leagues are already loaded or loading to avoid redundant calls
      final leagueProvider = Provider.of<LeagueProvider>(context, listen: false);
      if (leagueProvider.state == LeagueState.initial) {
         leagueProvider.fetchLeagues();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leagues'),
      ),
      body: Consumer<LeagueProvider>(
        builder: (context, leagueProvider, child) {
          switch (leagueProvider.state) {
            case LeagueState.loading:
            case LeagueState.initial: // Show loading also in initial state before first fetch
              return const Center(child: CircularProgressIndicator());
            case LeagueState.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                        Text(
                           'Error: ${leagueProvider.errorMessage}',
                           textAlign: TextAlign.center,
                           style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                           onPressed: () => leagueProvider.fetchLeagues(), 
                           child: const Text('Retry'),
                        )
                     ],
                  )
                ),
              );
            case LeagueState.loaded:
              if (leagueProvider.leagues.isEmpty) {
                 return const Center(child: Text('No leagues available.'));
              }
              return ListView.builder(
                itemCount: leagueProvider.leagues.length,
                itemBuilder: (context, index) {
                  final league = leagueProvider.leagues[index];
                  return ListTile(
                    leading: Image.network(
                      league.logoUrl,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.sports_soccer, size: 40), // Placeholder icon on error
                    ),
                    title: Text(league.name),
                    subtitle: Text(league.country),
                    onTap: () {
                      // Navigate to Match List Screen for this league
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchListScreen(league: league),
                        ),
                      );
                    },
                  );
                },
              );
          }
        },
      ),
    );
  }
}

