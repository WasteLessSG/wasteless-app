class MassEntry {
  final double mass;
  final String timestamp;
  MassEntry (this.mass,this.timestamp);

  MassEntry.fromMap(Map<String, dynamic> map)
      : assert(map['mass'] != null),
        assert(map['timestamp'] != null),
        mass = double.parse(map['mass']),
        timestamp = map['timestamp'];


  @override
  String toString() => "Record<$mass:$timestamp>";
}
