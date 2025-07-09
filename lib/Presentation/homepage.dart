import 'package:flutter/material.dart';
import 'package:mu_teaser/Presentation/add_details_page.dart';
import 'package:mu_teaser/utils/auth_tokens.dart';
import 'package:mu_teaser/utils/meta_api/meta_api_query_model.dart';
import 'package:mu_teaser/utils/meta_api/meta_api_response_model.dart';
import 'package:mu_teaser/utils/meta_api/meta_api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  String _selectedPlatform = 'facebook';
  String _selectedAdType = 'ALL';
  List<String> _selectedCountry = ['IN'];

  bool _isLoading = false;
  List<AdModel> _ads = [];

  Future<void> _searchAds() async {
    setState(() => _isLoading = true);

    final filter = AdsSearchFilter(
      searchTerm: _searchController.text.trim(),
      platform: _selectedPlatform,
      adType: _selectedAdType,
      countryCode: _selectedCountry,
      limit: 20,
    );

    try {
      final ads = await fetchAdsTyped(filter);
      setState(() {
        _ads = ads;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching ads: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("AdPulse"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search input
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter brand name...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 1,
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 30),

            // Dropdown filters
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    "Platform",
                    ['facebook', 'instagram'],
                    _selectedPlatform,
                    (value) => setState(() => _selectedPlatform = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    "Ad Type",
                    ['ALL', 'POLITICAL_AND_ISSUE_ADS', 'HOUSING_ADS'],
                    _selectedAdType,
                    (value) => setState(() => _selectedAdType = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    "Country",
                    ['IN', 'US', 'UK'],
                    _selectedCountry[0],
                    (value) => setState(() => _selectedCountry[0] = value!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _searchAds,
                icon: const Icon(Icons.search),
                label: const Text("Search"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    )
                  : _ads.isEmpty
                  ? const Center(
                      child: Text(
                        "No ads found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _ads.length,
                      itemBuilder: (context, index) {
                        final ad = _ads[index];
                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              ad.id,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              ad.adCreativeBodies.join(', '),
                              style: const TextStyle(color: Colors.white70),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white30,
                            ),
                            onTap: () {
                              // open snapshot url
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdDetailPage(
                                    adCreativeBody: ad.adCreativeBodies.join(', '),
                                    snapshotUrl: ad.adSnapshotUrl,
                                    startTime: ad.adStartTime,
                                    stopTime: ad.adStopTime,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String currentValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      dropdownColor: Colors.grey[900],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      isExpanded: true, // This prevents dropdown text overflow
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            _getDisplayText(value),
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Helper method to handle long text in dropdown options
  String _getDisplayText(String value) {
    switch (value) {
      case 'POLITICAL_AND_ISSUE_ADS':
        return 'POLITICAL & ISSUE';
      case 'HOUSING_ADS':
        return 'HOUSING';
      default:
        return value.toUpperCase();
    }
  }
}
