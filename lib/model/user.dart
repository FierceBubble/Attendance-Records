class User {
  final String name;
  final String phone;
  final int timestamp;
  final int timestampR;

  User(
      {required this.name,
      required this.phone,
      required this.timestamp,
      required this.timestampR});

  factory User.fromRTDB(Map<String, dynamic> data) {
    return User(
      name: data['user'] ?? 'Unknown',
      phone: data['phone'] ?? '0000000000',
      timestamp: data['timestamp'] ?? 0,
      timestampR: data['timestampR'] ?? 0,
    );
  }
}
