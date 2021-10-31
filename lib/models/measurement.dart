class Measurement {
  int period;
  DateTime? dateTime;

  Measurement({this.period = 0, this.dateTime});

  Measurement.fromJson(Map<String, dynamic> json) :
    period = json['period'],
    dateTime = DateTime.fromMillisecondsSinceEpoch(json['timestamp']);

  Map<String, dynamic> toJson() => {
    'period': period,
    'timestamp': dateTime?.millisecondsSinceEpoch
  };
}