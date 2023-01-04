// ignore_for_file: file_names

class CheckInList {
  final String name;
  final String phone;
  final int timestamp;
  final int timestampR;

  CheckInList(
      {required this.name,
      required this.phone,
      required this.timestamp,
      required this.timestampR});

  factory CheckInList.fromRTDB(Map<String, dynamic> data) {
    return CheckInList(
      name: data['user'] ?? 'Unknown',
      phone: data['phone'] ?? '0000000000',
      timestamp: data['timestamp'] ?? 0,
      timestampR: data['timestampR'] ?? 0,
    );
  }
}
