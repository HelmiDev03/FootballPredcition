import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:football_predictions_app/models/league.dart';
import 'package:football_predictions_app/models/match.dart';
import 'package:intl/intl.dart';

class ApiFootballService {
  // API Key provided by the user
  static const String _apiKey = '46816a7795a292bb258f2bf88667c6d6'; 
  static const String _baseUrl = 'https://v3.football.api-sports.io';

  final Map<String, String> _headers = {
    'x-rapidapi-host': 'v3.football.api-sports.io',
    'x-rapidapi-key': _apiKey,
  };

  // Helper function to make API requests
  Future<Map<String, dynamic>> _makeRequest(String endpoint, Map<String, String> params) async {
    if (_apiKey == 'YOUR_API_KEY' || _apiKey.isEmpty) { // Check if key is still placeholder or empty
        print("API Key not set. Please provide your API key.");
        throw Exception('API Key not set in ApiFootballService. Please provide your key.');
    }
    
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: params.isNotEmpty ? params : null); // Pass null if params is empty
    print('Making API request to: $uri'); // Log the request URL

    try {
      final response = await http.get(uri, headers: _headers);
      print('API Response Status Code: ${response.statusCode}'); // Log status code
      // print('API Response Body: ${response.body}'); // Log response body (optional, can be large)

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['errors'] != null && data['errors'].isNotEmpty && (data['errors'] is List ? data['errors'].length > 0 : data['errors'] is Map ? data['errors'].isNotEmpty : true) ) {
          print('API Error: ${data['errors']}');
          // Handle specific API errors (e.g., invalid key, rate limit)
          if (data['errors'] is Map && data['errors']['token'] != null) {
            throw Exception('Invalid API Key: ${data['errors']['token']}');
          } else if (data['errors'] is Map && data['errors']['requests'] != null) {
             throw Exception('API Rate Limit Exceeded: ${data['errors']['requests']}');
          }
          throw Exception('API returned errors: ${data['errors']}');
        }
        if (data['response'] == null) {
            print('API response format error: Missing \'response\' key. Body: ${response.body}');
            throw Exception('API response format error: Missing \'response\' key.');
        }
        return data;
      } else {
        print('API Request Failed: ${response.statusCode} ${response.reasonPhrase}');
        print('Response Body: ${response.body}'); // Log body on failure
        throw Exception('API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during API request: $e');
      throw Exception('Failed to connect to the API: $e');
    }
  }

  // Fetch all available leagues (modified based on user feedback)
  Future<List<League>> getLeagues() async {
    List<League> leagues = [];
    try {
        // Fetch all leagues available to the API key, without specific IDs or season
        final data = await _makeRequest('/leagues', {}); // Empty params map
        
        if (data['response'] != null && data['response'] is List) {
            for (var leagueData in data['response']) {
                 // Basic check for essential data presence
                if (leagueData['league'] != null && leagueData['league']['id'] != null && leagueData['league']['name'] != null) {
                    leagues.add(League(
                        id: leagueData['league']['id'],
                        name: leagueData['league']['name'],
                        country: leagueData['country']?['name'] ?? 'World', // Handle null country
                        logoUrl: leagueData['league']['logo'],
                    ));
                } else {
                    print("Skipping league due to missing data: ${leagueData}");
                }
            }
        } else {
             print("No league data found or unexpected format in response.");
        }
    } catch (e) {
        print("Error fetching leagues: $e");
        // Re-throw the exception to be handled by the provider/UI
        throw Exception('Failed to fetch leagues: $e'); 
    }
    
    if (leagues.isEmpty) {
        print("Warning: getLeagues returned an empty list.");
        // Optionally throw an error here if an empty list is unexpected
        // throw Exception('No leagues were successfully fetched or parsed.');
    }
    return leagues;
  }

  // Fetch matches for a specific league and date
  Future<List<Match>> getMatchesForLeagueAndDate(int leagueId, DateTime date) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    // Determine the season based on the selected date. 
    // API-Football generally uses the starting year for seasons spanning two years (e.g., 2023 for 23/24 season).
    // A simple approach is to use the year of the date, but adjust if the month is early in the year (before typical season start like August)
    // This might need refinement depending on how API-Football handles season definitions across all leagues.
    int seasonYear = date.month < 8 ? date.year - 1 : date.year;
    String currentSeason = seasonYear.toString();

    final params = {
      'league': leagueId.toString(),
      'season': currentSeason,
      'date': formattedDate,
    };

    final data = await _makeRequest('/fixtures', params);
    List<Match> matches = [];
    if (data['response'] != null && data['response'] is List) {
      for (var item in data['response']) {
        try {
           // Basic check for essential data
           if (item['fixture']?['id'] != null && 
               item['fixture']?['date'] != null &&
               item['teams']?['home']?['name'] != null &&
               item['teams']?['away']?['name'] != null) 
           {
               matches.add(Match(
                id: item['fixture']['id'],
                date: DateTime.parse(item['fixture']['date']).toLocal(),
                homeTeamName: item['teams']['home']['name'],
                awayTeamName: item['teams']['away']['name'],
                homeTeamLogoUrl: item['teams']['home']['logo'],
                awayTeamLogoUrl: item['teams']['away']['logo'],
                homeTeamScore: item['goals']?['home'], // Allow null scores
                awayTeamScore: item['goals']?['away'], // Allow null scores
                status: item['fixture']?['status']?['short'] ?? 'TBD', // Default status
              ));
           } else {
               print("Skipping match due to missing essential data: ${item}");
           }
        } catch (e) {
            print("Error parsing match data: $e\nItem: $item");
            // Skip this match or handle error
        }
      }
    } else {
        print("No match data found or unexpected format for league $leagueId on $formattedDate");
    }
    return matches;
  }

  // Fetch prediction for a specific match
  Future<Prediction> getPredictionForMatch(int matchId) async {
    final params = {'fixture': matchId.toString()};
    final data = await _makeRequest('/predictions', params);

    if (data['response'] != null && data['response'].isNotEmpty) {
      var predictionData = data['response'][0]; // Assuming the first result is the relevant one
      try {
          // API-Football prediction structure: response[0]['predictions']['percent']
          var percentages = predictionData['predictions']?['percent'];
          if (percentages == null) {
              print("Prediction percentages missing for match ID: $matchId");
              throw Exception('Prediction percentages missing.');
          }
          
          // Helper to safely parse percentage strings like "50%"
          double parsePercent(String? percentString) {
              if (percentString == null) return 0.0;
              // Handle potential formats like "N/A" or just numbers
              if (!percentString.contains('%')) {
                  return (double.tryParse(percentString) ?? 0.0) / 100.0; // Assume it's a raw percentage if no '%' sign
              }
              return (double.tryParse(percentString.replaceAll('%', '')) ?? 0.0) / 100.0;
          }
          
          // Normalize probabilities if they don't sum to 1 (or close to it)
          double homeP = parsePercent(percentages['home']);
          double drawP = parsePercent(percentages['draw']);
          double awayP = parsePercent(percentages['away']);
          double totalP = homeP + drawP + awayP;

          if (totalP > 0.1 && (totalP < 0.95 || totalP > 1.05)) { // Check if total is significantly off from 1
              print("Normalizing probabilities for match $matchId. Original sum: $totalP");
              homeP = homeP / totalP;
              drawP = drawP / totalP;
              awayP = awayP / totalP;
          } else if (totalP < 0.1) { // Handle cases where all are 0 or very low
               print("Prediction probabilities are zero or near-zero for match $matchId. Using defaults.");
               return Prediction(homeWinProbability: 0.33, drawProbability: 0.34, awayWinProbability: 0.33);
          }

          return Prediction(
            homeWinProbability: homeP,
            drawProbability: drawP,
            awayWinProbability: awayP,
          );
      } catch (e) {
           print("Error parsing prediction data: $e\nItem: $predictionData");
           throw Exception('Failed to parse prediction data.');
      }
    } else {
      print("No prediction data found for match ID: $matchId");
      // Return a default prediction or throw an error
      // Returning default for now to avoid crashing UI if prediction is missing
       return Prediction(homeWinProbability: 0.33, drawProbability: 0.34, awayWinProbability: 0.33);
      // throw Exception('No prediction data found for match ID: $matchId');
    }
  }
}

