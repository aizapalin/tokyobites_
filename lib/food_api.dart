import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'tokyo_theme.dart';

// ============================================================================
// REST API Data Model & JSON Helpers
// ============================================================================

FoodData foodDataFromJson(String str) {
  try {
    final dynamic jsonData = json.decode(str);
    if (jsonData is List) {
      return FoodData(
        data: jsonData
            .whereType<Map>()
            .map((x) => FoodItem.fromJson(x.cast<String, dynamic>()))
            .toList(),
      );
    } else if (jsonData is Map) {
      final mapData = jsonData.cast<String, dynamic>();
      if (mapData['data'] is List) {
        return FoodData(
          data: (mapData['data'] as List)
              .whereType<Map>()
              .map((x) => FoodItem.fromJson(x.cast<String, dynamic>()))
              .toList(),
        );
      }
    }
  } catch (_) {}
  return FoodData(data: []);
}

String foodDataToJson(FoodData data) => json.encode(data.toJson());

List<FoodItem> foodListFromJson(String str) {
  try {
    final dynamic jsonData = json.decode(str);
    if (jsonData is List) {
      return jsonData
          .whereType<Map>()
          .map((x) => FoodItem.fromJson(x.cast<String, dynamic>()))
          .toList();
    } else if (jsonData is Map) {
      final mapData = jsonData.cast<String, dynamic>();
      if (mapData['data'] is List) {
        return (mapData['data'] as List)
            .whereType<Map>()
            .map((x) => FoodItem.fromJson(x.cast<String, dynamic>()))
            .toList();
      }
    }
  } catch (_) {}
  return [];
}

class FoodData {
  FoodData({required this.data});

  List<FoodItem> data;

  factory FoodData.fromJson(Map<String, dynamic> json) => FoodData(
    data: json["data"] is List
        ? (json["data"] as List)
              .whereType<Map>()
              .map((x) => FoodItem.fromJson(x.cast<String, dynamic>()))
              .toList()
        : [],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class FoodItem {
  FoodItem({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.imageAsset,
    required this.isAvailable,
  });

  int id;
  String category;
  String name;
  String description;
  double price;
  String imageAsset;
  bool isAvailable;

  String get title => name;
  String get image => imageAsset;
  String get priceLabel => '₱${price.toStringAsFixed(2)}';

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json["id"] is int
        ? json["id"] as int
        : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
    category: (json["category"] ?? '').toString(),
    name: (json["name"] ?? json["title"] ?? '').toString(),
    description: (json["description"] ?? '').toString(),
    price: json["price"] != null ? (json["price"] as num).toDouble() : 0.0,
    imageAsset: (json["imageAsset"] ?? json["image"] ?? '').toString(),
    isAvailable: json["isAvailable"] == null
        ? true
        : (json["isAvailable"] == true || json["isAvailable"] == 1),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category": category,
    "name": name,
    "description": description,
    "price": price,
    "imageAsset": imageAsset,
    "isAvailable": isAvailable,
  };
}

// ============================================================================
// REST API Service
// ============================================================================

class FoodApiService {
  static const String primaryUrl =
      'https://gist.githubusercontent.com/aizapalin/c4e3a1fcf2a5b12220ea45b237c3cd94/raw/a6d528a819fc8c2f1d2ac218f5557ca182689390/food.json';
  static const String fallbackUrl = 'https://fakestoreapi.com/products';

  static Future<FoodData> fetchProducts({http.Client? client}) async {
    final httpClient = client ?? http.Client();
    try {
      try {
        final response = await httpClient.get(Uri.parse(primaryUrl));
        if (response.statusCode == 200) {
          final FoodData parsed = foodDataFromJson(response.body);
          if (parsed.data.isNotEmpty) {
            return parsed;
          }
        }
      } catch (_) {
        // Fall through to fallback
      }

      final fallbackResponse = await httpClient.get(Uri.parse(fallbackUrl));
      if (fallbackResponse.statusCode == 200) {
        return foodDataFromJson(fallbackResponse.body);
      } else {
        throw Exception(
          'Failed to load products (HTTP ${fallbackResponse.statusCode})',
        );
      }
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}

// ============================================================================
// Data Catalog Screen & Widgets
// ============================================================================

class FoodApiPage extends StatefulWidget {
  const FoodApiPage({super.key, this.showAppBar = true, this.initialData});

  final bool showAppBar;
  final FoodData? initialData;

  @override
  State<FoodApiPage> createState() => _FoodApiPageState();
}

class _FoodApiPageState extends State<FoodApiPage> {
  // For holding response as FoodData
  FoodData foodData = FoodData(data: []);
  // for data is loaded flag
  bool isDataLoaded = false;
  // for ongoing loading state
  bool isLoading = true;
  // error holding
  String errorMessage = '';

  // Search filtering
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // API Call - preserves existing method signature
  Future<FoodData> getDataFromAPI() async {
    return await FoodApiService.fetchProducts();
  }

  Future<void> callAPIandAssignData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final FoodData fetched = await getDataFromAPI();
      if (!mounted) return;
      setState(() {
        foodData = fetched;
        isDataLoaded = true;
        isLoading = false;
        errorMessage = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (foodData.data.isEmpty) {
          foodData = FoodData(data: []);
        }
        isDataLoaded = true;
        isLoading = false;
        errorMessage =
            'Failed to load products. Please check your connection and try again.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      foodData = widget.initialData!;
      isDataLoaded = true;
      isLoading = false;
    } else {
      callAPIandAssignData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FoodItem> get filteredProducts {
    final List<FoodItem> all = foodData.data;
    if (_searchQuery.trim().isEmpty) {
      return all;
    }
    final String query = _searchQuery.trim().toLowerCase();
    return all.where((FoodItem item) {
      final bool nameMatch = item.name.toLowerCase().contains(query);
      final bool categoryMatch = item.category.toLowerCase().contains(query);
      return nameMatch || categoryMatch;
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  Widget _buildProductImage(FoodItem item) {
    final String imagePath = item.imageAsset.trim();
    Widget imageChild;

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      imageChild = Image.network(
        imagePath,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.fastfood, color: TokyoTheme.primary, size: 32),
      );
    } else if (imagePath.isNotEmpty) {
      imageChild = Image.asset(
        imagePath,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.fastfood, color: TokyoTheme.primary, size: 32),
      );
    } else {
      imageChild = const Icon(
        Icons.fastfood,
        color: TokyoTheme.primary,
        size: 32,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        color: TokyoTheme.elevated,
        child: imageChild,
      ),
    );
  }

  Widget getRow(int index, [FoodItem? specificItem]) {
    final List<FoodItem> currentList = filteredProducts;
    final FoodItem item =
        specificItem ??
        (index < currentList.length
            ? currentList[index]
            : foodData.data[index]);

    return Card(
      clipBehavior: Clip.hardEdge,
      color: TokyoTheme.cardDark,
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: TokyoTheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(item),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: TokyoTheme.darkText,
                          ),
                        ),
                      ),
                      if (item.category.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: TokyoTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: TokyoTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TokyoTheme.textMedium,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.priceLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TokyoTheme.primary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.isAvailable
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 15,
                            color: item.isAvailable ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isAvailable ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              fontSize: 12,
                              color: item.isAvailable
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (String value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(color: TokyoTheme.cream),
        decoration: InputDecoration(
          hintText: 'Search products by name or category...',
          hintStyle: const TextStyle(color: TokyoTheme.textMedium),
          prefixIcon: const Icon(Icons.search, color: TokyoTheme.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: TokyoTheme.textMedium),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: TokyoTheme.cardDark,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: TokyoTheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: TokyoTheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    Widget content;

    if (isLoading && !isDataLoaded) {
      content = const Center(
        child: CircularProgressIndicator(color: TokyoTheme.primary),
      );
    } else if (errorMessage.isNotEmpty && foodData.data.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: TokyoTheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to Load Products',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TokyoTheme.cream,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: TokyoTheme.textMedium),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: callAPIandAssignData,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    } else if (filteredProducts.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                size: 52,
                color: TokyoTheme.textMedium,
              ),
              const SizedBox(height: 12),
              Text(
                _searchQuery.isEmpty
                    ? 'No products available'
                    : 'No products found matching "$_searchQuery"',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TokyoTheme.cream,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty
                    ? 'Tap refresh to try fetching again.'
                    : 'Try searching for another dish or product title.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: TokyoTheme.textMedium),
              ),
              const SizedBox(height: 16),
              if (_searchQuery.isNotEmpty)
                FilledButton.tonal(
                  onPressed: _clearSearch,
                  child: const Text('Clear Search'),
                )
              else
                FilledButton.tonal(
                  onPressed: callAPIandAssignData,
                  child: const Text('Refresh'),
                ),
            ],
          ),
        ),
      );
    } else {
      content = RefreshIndicator(
        color: TokyoTheme.primary,
        backgroundColor: TokyoTheme.cardDark,
        onRefresh: callAPIandAssignData,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: filteredProducts.length,
          itemBuilder: (BuildContext context, int index) =>
              getRow(index, filteredProducts[index]),
        ),
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isLoading
                    ? 'Fetching products...'
                    : _searchQuery.isEmpty
                    ? 'All Products (${foodData.data.length})'
                    : 'Search Results (${filteredProducts.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: TokyoTheme.textMedium,
                ),
              ),
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: _clearSearch,
                  child: const Text(
                    'Clear Filter',
                    style: TextStyle(
                      fontSize: 12,
                      color: TokyoTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: content),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAppBar) {
      return Container(color: TokyoTheme.background, child: _buildBody());
    }

    return Scaffold(
      backgroundColor: TokyoTheme.background,
      appBar: AppBar(
        title: Text(
          'Data Catalog',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TokyoTheme.primary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: callAPIandAssignData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
