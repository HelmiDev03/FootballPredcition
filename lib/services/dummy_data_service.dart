import 'package:football_predictions_app/models/league.dart';
import 'package:football_predictions_app/models/match.dart';

class DummyDataService {
  // Dummy list of major leagues
  final List<League> _leagues = [
    League(id: 39, name: 'Premier League', country: 'England', logoUrl: 'https://media.api-sports.io/football/leagues/39.png'),
    League(id: 140, name: 'La Liga', country: 'Spain', logoUrl: 'https://media.api-sports.io/football/leagues/140.png'),
    League(id: 135, name: 'Serie A', country: 'Italy', logoUrl: 'https://media.api-sports.io/football/leagues/135.png'),
    League(id: 78, name: 'Bundesliga', country: 'Germany', logoUrl: 'https://media.api-sports.io/football/leagues/78.png'),
    League(id: 61, name: 'Ligue 1', country: 'France', logoUrl: 'https://media.api-sports.io/football/leagues/61.png'),
    League(id: 2, name: 'UEFA Champions League', country: 'World', logoUrl: 'https://media.api-sports.io/football/leagues/2.png'),
  ];

  Future<List<League>> getLeagues() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _leagues;
  }

  Future<List<Match>> getMatchesForLeagueAndDate(int leagueId, DateTime date) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate dummy matches based on league and date
    // In a real app, this would fetch from an API
    List<Match> dummyMatches = [];
    int baseMatchId = leagueId * 1000 + date.day * 10;

    for (int i = 0; i < 5; i++) { // Generate 5 dummy matches
      bool isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
      bool isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;

      dummyMatches.add(
        Match(
          id: baseMatchId + i,
          date: date.add(Duration(hours: 18 + i)), // Stagger match times
          homeTeamName: 'Home Team ${String.fromCharCode(65 + i)}',
          awayTeamName: 'Away Team ${String.fromCharCode(70 + i)}',
          homeTeamLogoUrl: 'https://via.placeholder.com/50/0000FF/FFFFFF?text=H${String.fromCharCode(65 + i)}', // Placeholder logo
          awayTeamLogoUrl: 'https://via.placeholder.com/50/FF0000/FFFFFF?text=A${String.fromCharCode(70 + i)}', // Placeholder logo
          homeTeamScore: isPast ? (i % 3) : null,
          awayTeamScore: isPast ? ((i + 1) % 3) : null,
          status: isPast ? 'FT' : (isToday ? 'NS' : 'NS'), // FT for past, NS for today/future
        )
      );
    }
    return dummyMatches;
  }

  Future<Prediction> getPredictionForMatch(int matchId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Generate dummy prediction based on matchId (simple deterministic for demo)
    double homeProb = (matchId % 100) / 100.0;
    double drawProb = 0.3;
    double awayProb = 1.0 - homeProb - drawProb;
    if (awayProb < 0) { // Ensure probabilities are valid
        awayProb = 0.1;
        drawProb = 1.0 - homeProb - awayProb;
        if (drawProb < 0) {
            drawProb = 0.0;
            homeProb = 1.0;
        }
    }

    return Prediction(
      homeWinProbability: homeProb,
      drawProbability: drawProb,
      awayWinProbability: awayProb,
    );
  }
}

