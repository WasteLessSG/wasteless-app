import 'package:cloud_firestore/cloud_firestore.dart';


class MassEntry {
  final double mass;
  final String timestamp;
  final String shortenedTime;
  MassEntry (this.mass,this.timestamp, this.shortenedTime);

  MassEntry.fromMap(Map<String, dynamic> map)
      : assert(map['mass'] != null),
        assert(map['timestamp'] != null),
        assert(map['timestamp2'] != null),
        mass = double.parse(map['mass']),
        timestamp = map['timestamp'],
        shortenedTime = map['timestamp2'];




  // @override
  // String toString() => "Record<$mass:$timestamp>";
}
