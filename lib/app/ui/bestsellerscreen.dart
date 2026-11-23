import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/productlistbloc/productlist_bloc.dart';
import '../bloc/productlistbloc/productlist_event.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/productlisttype.dart';
import '../widgets/productlistbody.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

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
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 1,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleSpacing: 16,
          title: Text('Best Seller', style: AppTextStyle.appBarTitle),
        ),
        body: ProductListBody(
          onProductTap: (product) {
            context.push(AppRouter.productPath(product.id));
          },
        ),
      ),
    );
  }
}
