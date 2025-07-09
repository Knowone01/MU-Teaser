class AdModel {
  final String id;
  final List<String> adCreativeBodies;
  final String adSnapshotUrl;
  final String? adStartTime;
  final String? adStopTime;

  AdModel({
    required this.id,
    required this.adCreativeBodies,
    required this.adSnapshotUrl,
    this.adStartTime,
    this.adStopTime,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'].toString(), // toString() to handle int or String
      adCreativeBodies: json['ad_creative_bodies'] != null
          ? List<String>.from(json['ad_creative_bodies'])
          : [],
      adSnapshotUrl: json['ad_snapshot_url'] ?? '',
      adStartTime: json['ad_delivery_start_time'],
      adStopTime: json['ad_delivery_stop_time'],
    );
  }
}
