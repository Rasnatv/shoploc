import 'package:shoploc/app/data/models/productlistmodel.dart';

/// GET /recent-views/top  and  GET /recent-views?page=&per_page=
/// Items have the same shape as every other product list
/// (id, name, slug, price, original_price, badge, trend_type, rating,
/// category, image), so they are parsed into [HomeProductModel].
class RecentViewsResponse extends ProductListResponse {
  const RecentViewsResponse({required super.message, required super.products});

  factory RecentViewsResponse.fromJson(Map<String, dynamic> json) =>
      RecentViewsResponse(
        message: json['message']?.toString() ?? '',
        products: ProductListResponse.parseProducts(json['data']),
      );
}

/// POST /recent-views  ->  { "message": "Recent view saved.", "data": {} }
class SaveRecentViewResponse {
  final String message;
  const SaveRecentViewResponse({required this.message});

  factory SaveRecentViewResponse.fromJson(Map<String, dynamic> json) =>
      SaveRecentViewResponse(message: json['message']?.toString() ?? '');
}