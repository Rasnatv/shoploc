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
        appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 1,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            titleSpacing: 16,
            title: Text('Trending Right Now',style: AppTextStyle.appBarTitle)),
        body: ProductListBody(
          onProductTap: (product) {
            context.push(AppRouter.productPath(product.id));
          },
        ),
      ),
    );
  }
}