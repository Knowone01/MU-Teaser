import 'dart:convert';

class AdsSearchFilter {
  final String searchTerm;
  final List<String> countryCode;
  final String adType;
  final String? platform;
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;

  AdsSearchFilter({
    required this.searchTerm,
    List<String>? countryCode,
    this.adType = 'ALL',
    this.platform,
    this.startDate,
    this.endDate,
    this.limit = 25,
  }) : countryCode = countryCode ?? const ['IN'];

  Map<String, dynamic> toQueryParameters(String accessToken) {
    final Map<String, dynamic> params = {
      'access_token': accessToken,
      'search_terms': searchTerm,
      'ad_reached_countries': jsonEncode(countryCode),
      'ad_type': adType,
      'limit': limit.toString(),
      'fields':
          'id,ad_creative_bodies,ad_snapshot_url,ad_delivery_start_time,ad_delivery_stop_time',
    };

    if (platform != null && platform!.isNotEmpty) {
      params['publisher_platforms'] = platform!;
    }

    if (startDate != null) {
      params['ad_delivery_date_min'] = startDate!
          .toIso8601String()
          .split('T')
          .first;
    }

    if (endDate != null) {
      params['ad_delivery_date_max'] = endDate!
          .toIso8601String()
          .split('T')
          .first;
    }

    return params;
  }
}
