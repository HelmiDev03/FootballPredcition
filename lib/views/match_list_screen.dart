import 'package:flutter/material.dart';
import 'package:football_predictions_app/models/league.dart';
import 'package:football_predictions_app/providers/match_provider.dart';
import 'package:football_predictions_app/widgets/calendar_strip.dart'; // Import the CalendarStrip widget
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MatchListScreen extends StatefulWidget {
  final League league;

  const MatchListScreen({super.key, required this.league});

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  // Initialize _selectedDate with today's date, normalized to midnight
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    // Fetch matches for the selected league and initial date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMatchesForSelectedDate();
    });
  }

  void _fetchMatchesForSelectedDate() {
    Provider.of<MatchProvider>(context, listen: false)
        .fetchMatchesAndPredictions(widget.league.id, _selectedDate);
  }

  void _onDateSelected(DateTime date) {
    // Normalize the selected date to midnight for consistent comparison and state management
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Check date constraints (+/- 7 days from today, normalized)
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = normalizedNow.subtract(const Duration(days: 7));
    final sevenDaysLater = normalizedNow.add(const Duration(days: 7));

    if (normalizedDate.isBefore(sevenDaysAgo) || normalizedDate.isAfter(sevenDaysLater)) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only view matches within 7 days from today.')),
        );
        // Optionally, visually revert the calendar selection if using a stateful calendar
        // For CalendarCarousel, it might automatically handle not selecting disabled dates.
        // If not, you might need to force a rebuild or manage the calendar's internal state.
        return; // Do not update state or fetch matches
    }

    // Only update state and fetch if the date actually changed
    if (_selectedDate != normalizedDate) {
        setState(() {
          _selectedDate = normalizedDate;
        });
        _fetchMatchesForSelectedDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.league.name} - Matches'),
      ),
      body: Column(
        children: [
          // Integrate the CalendarStrip widget
          CalendarStrip(
            selectedDate: _selectedDate,
            onDateSelected: _onDateSelected,
          ),
          Expanded(
            child: Consumer<MatchProvider>(
              builder: (context, matchProvider, child) {
                // Ensure we are showing data for the correct league and date (normalized)
                final normalizedProviderDate = matchProvider.selectedDate != null
                    ? DateTime(matchProvider.selectedDate!.year, matchProvider.selectedDate!.month, matchProvider.selectedDate!.day)
                    : null;
                    
                if (matchProvider.selectedLeagueId != widget.league.id || 
                    normalizedProviderDate != _selectedDate) {
                    // If the provider's state doesn't match the screen's state,
                    // show loading or initial state until fetch completes.
                    if (matchProvider.state == MatchState.loading) {
                        return const Center(child: CircularProgressIndicator());
                    }
                    // If not loading but state is inconsistent, trigger fetch
                    // This can happen if navigating back quickly or state updates are delayed
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                         if (mounted) { // Check if the widget is still in the tree
                            _fetchMatchesForSelectedDate();
                         }
                    });
                    return const Center(child: CircularProgressIndicator()); // Show loading while fetch is triggered
                }

                switch (matchProvider.state) {
                  case MatchState.loading:
                  case MatchState.initial: // Should ideally not stay in initial if fetch is triggered
                    return const Center(child: CircularProgressIndicator());
                  case MatchState.error:
                    return Center(
                       child: Padding(
                         padding: const EdgeInsets.all(16.0),
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                              Text(
                                 'Error: ${matchProvider.errorMessage}',
                                 textAlign: TextAlign.center,
                                 style: TextStyle(color: Theme.of(context).colorScheme.error),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                 onPressed: _fetchMatchesForSelectedDate, 
                                 child: const Text('Retry'),
                              )
                           ],
                         )
                       ),
                    );
                  case MatchState.loaded:
                    if (matchProvider.matches.isEmpty) {
                      return Center(child: Text('No matches found for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}.'));
                    }
                    return ListView.builder(
                      itemCount: matchProvider.matches.length,
                      itemBuilder: (context, index) {
                        final match = matchProvider.matches[index];
                        final prediction = matchProvider.predictions[match.id];
                        
                        // Format match time
                        String matchTime = DateFormat('HH:mm').format(match.date);
                        String matchStatusDisplay = match.status;
                        // Use more descriptive status if available (API-Football specific)
                        // Example: TBD, NS, 1H, HT, 2H, ET, BT, P, SUSP, INT, FT, AET, PEN
                        if (match.status == 'NS') matchStatusDisplay = matchTime;
                        if (match.status == 'FT') matchStatusDisplay = 'Finished';
                        if (match.status == 'HT') matchStatusDisplay = 'Half Time';
                        // Add more status mappings as needed

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                // Match Info Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Home Team
                                    Expanded(
                                      flex: 3, // Give teams more space
                                      child: Row(
                                        children: [
                                          Image.network(match.homeTeamLogoUrl, width: 24, height: 24, errorBuilder: (c,e,s) => const Icon(Icons.shield, size: 24)),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(match.homeTeamName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))), 
                                        ],
                                      ),
                                    ),
                                    // Score / Status
                                    Expanded(
                                      flex: 2, // Adjust flex for score/time
                                      child: Text(
                                        match.status == 'FT' || match.status == 'HT' || match.status == '1H' || match.status == '2H' || match.status == 'ET' || match.status == 'P'
                                          ? '${match.homeTeamScore ?? '-'} - ${match.awayTeamScore ?? '-'}' 
                                          : matchStatusDisplay, // Show status/time
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    // Away Team
                                    Expanded(
                                      flex: 3, // Give teams more space
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(child: Text(match.awayTeamName, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))), 
                                          const SizedBox(width: 8),
                                          Image.network(match.awayTeamLogoUrl, width: 24, height: 24, errorBuilder: (c,e,s) => const Icon(Icons.shield, size: 24)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Prediction Row (if available and match not started)
                                if (prediction != null && match.status == 'NS') 
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildPredictionChip('Home', prediction.homeWinProbability, context),
                                      _buildPredictionChip('Draw', prediction.drawProbability, context),
                                      _buildPredictionChip('Away', prediction.awayWinProbability, context),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build prediction chips
  Widget _buildPredictionChip(String label, double probability, BuildContext context) {
    // Determine color based on probability (example)
    Color chipColor = Theme.of(context).colorScheme.secondaryContainer;
    if (probability > 0.6) {
        chipColor = Colors.green.shade100;
    } else if (probability < 0.25) {
        chipColor = Colors.red.shade100;
    }

    return Chip(
      label: Text('$label: ${(probability * 100).toStringAsFixed(0)}%'),
      backgroundColor: chipColor,
      labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          fontSize: 12, // Smaller font for chips
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 0), // Adjust padding
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target size
    );
  }
}

