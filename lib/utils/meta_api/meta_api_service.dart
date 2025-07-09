// services/ad_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:mu_teaser/utils/auth_tokens.dart';
import 'package:mu_teaser/utils/meta_api/meta_api_query_model.dart';
import 'package:mu_teaser/utils/meta_api/meta_api_response_model.dart';

Future<List<AdModel>> fetchAdsTyped(AdsSearchFilter filter) async {
  final baseUrl = 'https://graph.facebook.com/v19.0/ads_archive';

  final uri = Uri.parse(
    baseUrl,
  ).replace(queryParameters: filter.toQueryParameters(AuthTokens.accessToken));

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List<dynamic> adList = data['data'];
    print(adList);
    return adList.map((ad) => AdModel.fromJson(ad)).toList();
  } else {
    final error = jsonDecode(response.body);
    final message = error['error']?['message'] ?? 'Unknown error';
    print('Meta API Error: $message');
    throw Exception('Failed to fetch ads: $message');
  }
}
