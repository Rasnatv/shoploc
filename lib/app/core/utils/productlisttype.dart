enum ProductListType { newArrivals, trending, bestSellers }

extension ProductListTypeX on ProductListType {
  String get title {
    switch (this) {
      case ProductListType.newArrivals:
        return 'New Arrivals';
      case ProductListType.trending:
        return 'Trending Right Now';
      case ProductListType.bestSellers:
        return 'Best Sellers';
    }
  }
}