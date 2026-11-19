import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/ui/product_details_screen.dart';
import '../bloc/productlistbloc/productlist_bloc.dart';
import '../bloc/productlistbloc/productlist_event.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/productlisttype.dart';
import '../widgets/productlistbody.dart';

/// Best Sellers - full list (GET /products/best-sellers)
class BestSellersScreen extends StatelessWidget {
  const BestSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductListBloc(type: ProductListType.bestSellers)
        ..add(const LoadProductListEvent()),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          title: Text('Best Seller', style: AppTextStyle.appBarTitle),
        ),
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
