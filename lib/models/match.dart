class Match {
  final int id;
  final DateTime date;
  final String homeTeamName;
  final String awayTeamName;
  final String homeTeamLogoUrl;
  final String awayTeamLogoUrl;
  final int? homeTeamScore; // Nullable for future matches
  final int? awayTeamScore; // Nullable for future matches
  final String status;

  Match({
    required this.id,
    required this.date,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeTeamLogoUrl,
    required this.awayTeamLogoUrl,
    this.homeTeamScore,
    this.awayTeamScore,
    required this.status,
  });

  // Placeholder for factory constructor from JSON if using API
  // factory Match.fromJson(Map<String, dynamic> json) {
  //   return Match(
  //     id: json["fixture"]["id"],
  //     date: DateTime.parse(json["fixture"]["date"]).toLocal(),
  //     homeTeamName: json["teams"]["home"]["name"],
  //     awayTeamName: json["teams"]["away"]["name"],
  //     homeTeamLogoUrl: json["teams"]["home"]["logo"],
  //     awayTeamLogoUrl: json["teams"]["away"]["logo"],
  //     homeTeamScore: json["goals"]["home"],
  //     awayTeamScore: json["goals"]["away"],
  //     status: json["fixture"]["status"]["short"],
  //   );
  // }
}

class Prediction {
  final double homeWinProbability;
  final double drawProbability;
  final double awayWinProbability;

  Prediction({
    required this.homeWinProbability,
    required this.drawProbability,
    required this.awayWinProbability,
  });

  // Placeholder for factory constructor from JSON if using API
  // factory Prediction.fromJson(Map<String, dynamic> json) {
  //   // API-Football prediction structure might vary, adjust accordingly
  //   // Example assumes a structure like: json["predictions"]["percent"]
  //   return Prediction(
  //     homeWinProbability: double.tryParse(json["predictions"]["percent"]["home"].replaceAll("%", "")) ?? 0.0,
  //     drawProbability: double.tryParse(json["predictions"]["percent"]["draw"].replaceAll("%", "")) ?? 0.0,
  //     awayWinProbability: double.tryParse(json["predictions"]["percent"]["away"].replaceAll("%", "")) ?? 0.0,
  //   );
  // }
}

