class League {
  final int id;
  final String name;
  final String country;
  final String logoUrl;

  League({
    required this.id,
    required this.name,
    required this.country,
    required this.logoUrl,
  });

  // Placeholder for factory constructor from JSON if using API
  // factory League.fromJson(Map<String, dynamic> json) {
  //   return League(
  //     id: json["league"]["id"],
  //     name: json["league"]["name"],
  //     country: json["country"]["name"],
  //     logoUrl: json["league"]["logo"],
  //   );
  // }
}

