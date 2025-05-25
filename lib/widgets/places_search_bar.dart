import 'dart:async';
import 'package:allycall/services/api_service.dart';
import 'package:flutter/material.dart';

final api = ApiService();

class CustomPlacesSearchBar extends StatefulWidget {
  final void Function(double lat, double lng, String description)
  onPlaceSelected;

  const CustomPlacesSearchBar({super.key, required this.onPlaceSelected});

  @override
  State<CustomPlacesSearchBar> createState() => _CustomPlacesSearchBarState();
}

class _CustomPlacesSearchBarState extends State<CustomPlacesSearchBar> {
  final SearchController _searchController = SearchController();
  List<Map<String, dynamic>> _predictions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchInputChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchInputChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchInputChanged() {
    final query = _searchController.text;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchPredictions(query);
    });
  }

  Future<void> _fetchPredictions(String query) async {
    if (query.isEmpty) {
      setState(() => _predictions = []);
      return;
    }
    final data = await api.get('places/autocomplete?input=$query');
    final preds = (data['predictions'] as List).cast<Map<String, dynamic>>();
    setState(() => _predictions = preds);
  }

  Future<void> _selectPlace(String placeId, String description) async {
    final data = await api.get('places/details?place_id=$placeId');
    final location = data['result']['geometry']?['location'];
    if (location != null) {
      widget.onPlaceSelected(location['lat'], location['lng'], description);
    }
    _searchController.closeView(description);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: SearchAnchor.bar(
        viewBackgroundColor: Colors.white,
        searchController: _searchController,
        barHintText: 'Where do you want to check?',
        viewHintText: 'Where do you want to check?',
        barLeading: const Icon(Icons.search),
        barHintStyle: WidgetStatePropertyAll(
          const TextStyle(fontSize: 14, color: Color(0xFF8A8A8A)),
        ),
        viewHeaderHeight: 40,
        viewHeaderTextStyle: TextStyle(fontSize: 14),
        viewHeaderHintStyle: TextStyle(fontSize: 14, color: Color(0xFF8A8A8A)),
        barBackgroundColor: WidgetStatePropertyAll(Colors.white),
        dividerColor: Color(0xFF8A8A8A),
        isFullScreen: false,
        suggestionsBuilder: (context, controller) {
          return _predictions.map((p) {
            return ListTile(
              title: Text(p['description']),
              onTap: () => _selectPlace(p['place_id'], p['description']),
            );
          }).toList();
        },
      ),
    );
  }
}
