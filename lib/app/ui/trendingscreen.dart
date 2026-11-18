import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/ui/product_details_screen.dart';
import '../bloc/productlistbloc/productlist_bloc.dart';
import '../bloc/productlistbloc/productlist_event.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/productlisttype.dart';
import '../widgets/productlistbody.dart';

/// Trending Right Now - full list (GET /products/trending)
class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductListBloc(type: ProductListType.trending)
        ..add(const LoadProductListEvent()),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(title: const Text('Trending Right Now')),
        body: ProductListBody(
          onProductTap: (product) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productId: product.id),
            ));
          },
        ),
      ),
    );
  }
}