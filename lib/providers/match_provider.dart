import 'package:flutter/material.dart';
import 'package:football_predictions_app/models/match.dart';
import 'package:football_predictions_app/services/api_football_service.dart';

enum MatchState { initial, loading, loaded, error }

class MatchProvider with ChangeNotifier {
  final ApiFootballService _apiService = ApiFootballService();
  List<Match> _matches = [];
  Map<int, Prediction> _predictions = {}; // Store predictions by match ID
  MatchState _state = MatchState.initial;
  String _errorMessage = '';
  int? _selectedLeagueId;
  DateTime? _selectedDate;

  List<Match> get matches => _matches;
  Map<int, Prediction> get predictions => _predictions;
  MatchState get state => _state;
  String get errorMessage => _errorMessage;
  int? get selectedLeagueId => _selectedLeagueId;
  DateTime? get selectedDate => _selectedDate;

  Future<void> fetchMatchesAndPredictions(int leagueId, DateTime date) async {
    if (_state == MatchState.loading && _selectedLeagueId == leagueId && _selectedDate == date) {
      // Already loading for this selection
      return;
    }

    _state = MatchState.loading;
    _selectedLeagueId = leagueId;
    _selectedDate = date;
    _errorMessage = '';
    _matches = []; // Clear previous matches
    _predictions = {}; // Clear previous predictions
    notifyListeners();

    try {
      _matches = await _apiService.getMatchesForLeagueAndDate(leagueId, date);
      if (_matches.isEmpty) {
        _state = MatchState.loaded; // No error, just no matches
        notifyListeners();
        return;
      }

      // Fetch predictions for each match (can be parallelized for performance)
      List<Future<void>> predictionFutures = [];
      for (var match in _matches) {
        predictionFutures.add(
          _apiService.getPredictionForMatch(match.id).then((prediction) {
            _predictions[match.id] = prediction;
          }).catchError((e) {
            // Handle prediction fetch error for individual match if needed
            print('Error fetching prediction for match ${match.id}: $e');
            // Assign a default/error prediction or leave it null
             _predictions[match.id] = Prediction(homeWinProbability: 0.0, drawProbability: 0.0, awayWinProbability: 0.0); // Default/Error state
          })
        );
      }
      // Wait for all prediction fetches to complete
      await Future.wait(predictionFutures);

      _state = MatchState.loaded;
    } catch (e) {
      _state = MatchState.error;
      _errorMessage = 'Failed to load matches: ${e.toString()}';
      print(_errorMessage); // Log error
    }
    notifyListeners();
  }

  // Optional: Clear matches when navigating back or changing context
  void clearMatches() {
      _matches = [];
      _predictions = {};
      _state = MatchState.initial;
      _selectedLeagueId = null;
      _selectedDate = null;
      notifyListeners();
  }
}

