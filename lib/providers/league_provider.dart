import 'package:flutter/material.dart';
import 'package:football_predictions_app/models/league.dart';
import 'package:football_predictions_app/services/api_football_service.dart';

enum LeagueState { initial, loading, loaded, error }

class LeagueProvider with ChangeNotifier {
  final ApiFootballService _apiService = ApiFootballService();
  List<League> _leagues = [];
  LeagueState _state = LeagueState.initial;
  String _errorMessage = '';

  List<League> get leagues => _leagues;
  LeagueState get state => _state;
  String get errorMessage => _errorMessage;

  Future<void> fetchLeagues() async {
    if (_state == LeagueState.loading) return; // Prevent multiple simultaneous fetches

    _state = LeagueState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _leagues = await _apiService.getLeagues();
      if (_leagues.isEmpty) {
          _state = LeagueState.error;
          _errorMessage = 'No leagues found. The API might be temporarily unavailable or the season might not have started for some leagues.';
      } else {
          _state = LeagueState.loaded;
      }
    } catch (e) {
      _state = LeagueState.error;
      _errorMessage = 'Failed to load leagues: ${e.toString()}';
      print(_errorMessage); // Log error
    }
    notifyListeners();
  }
}

