import 'package:cloud_firestore/cloud_firestore.dart';

class RunActivity {
  final DateTime date;
  final DateTime startTime;
  final int duration;
  final double distance;
  final double pace;
  final List<Map<String, double>> coordinates;

  RunActivity({
    required this.date,
    required this.startTime,
    required this.duration,
    required this.distance,
    required this.pace,
    required this.coordinates,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'duration': duration,
      'distance': distance,
      'pace': pace,
      'coordinates': coordinates,
    };
    print("toMap() result: $map");
    return map;
  }

  factory RunActivity.fromMap(Map<String, dynamic> map) {
    return RunActivity(
      date: (map['date'] as Timestamp).toDate(),
      startTime: (map['startTime'] as Timestamp).toDate(),
      duration: map['duration'],
      distance: map['distance'].toDouble(),
      pace: map['pace'].toDouble(),
      coordinates: List<Map<String, double>>.from(
        (map['coordinates'] as List).map(
          (e) => {'lat': e['lat'], 'lng': e['lng']},
        ),
      ),
    );
  }
}
