class WasteLessData {
  final int time;
  final int mass;

  WasteLessData({this.time,this.mass});

  factory WasteLessData.fromJson(Map<int, dynamic> json){
    return WasteLessData(
      time: json["time"],
      mass: json["weight"]
    );
  }

}