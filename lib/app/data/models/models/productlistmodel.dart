
import 'homemodel.dart';

/// Shared shape of every product-list endpoint:
/// { message, data: [ {product}, ... ] }
class ProductListResponse {
  final String message;
  final List<HomeProductModel> products;

  const ProductListResponse({required this.message, required this.products});

  static List<HomeProductModel> parseProducts(dynamic raw) => raw is List
      ? raw
      .map((e) => HomeProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList()
      : <HomeProductModel>[];
}

/// GET /products/new-arrivals
class NewArrivalsResponse extends ProductListResponse {
  const NewArrivalsResponse({required super.message, required super.products});

  factory NewArrivalsResponse.fromJson(Map<String, dynamic> json) =>
      NewArrivalsResponse(
        message: json['message']?.toString() ?? '',
        products: ProductListResponse.parseProducts(json['data']),
      );
}

/// GET /products/trending
class TrendingResponse extends ProductListResponse {
  const TrendingResponse({required super.message, required super.products});

  factory TrendingResponse.fromJson(Map<String, dynamic> json) =>
      TrendingResponse(
        message: json['message']?.toString() ?? '',
        products: ProductListResponse.parseProducts(json['data']),
      );
}

/// GET /products/best-sellers  and  GET /home/best-sellers
class BestSellersResponse extends ProductListResponse {
  const BestSellersResponse({required super.message, required super.products});

  factory BestSellersResponse.fromJson(Map<String, dynamic> json) =>
      BestSellersResponse(
        message: json['message']?.toString() ?? '',
        products: ProductListResponse.parseProducts(json['data']),
      );
}