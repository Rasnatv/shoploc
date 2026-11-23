
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shoploc/app/bloc/authbloc/auth_bloc.dart';
import 'package:shoploc/app/core/device_helper.dart';
import 'package:shoploc/app/core/utils/object_factory.dart';
import 'package:shoploc/app/router/app_router.dart';

import 'app/bloc/addressbloc/address_bloc.dart';
import 'app/bloc/checkout/checkout_bloc.dart';
import 'app/bloc/homebloc/home_bloc.dart';
import 'app/bloc/myorders/myorders_bloc.dart';
import 'app/widgets/appsnackbar.dart';
import 'app/widgets/responsive.dart';
import 'app/bloc/cartbloc/cart_bloc.dart';
import 'app/bloc/cartbloc/cart_event.dart';
import 'app/bloc/whishlistbloc/wishlist_bloc.dart';
import 'app/bloc/whishlistbloc/wishlist_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ObjectFactory().initPrefs();
  await DeviceHelper.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<HomeBloc>(create: (_) => HomeBloc()),
        // Global: hearts on every screen + the Wishlist tab share this one bloc
        BlocProvider<WishlistBloc>(
          create: (_) => WishlistBloc()..add(const LoadWishlistEvent()),
        ),
        // Global: Cart tab + "Add to Cart" on the product page share this bloc
        BlocProvider<CartBloc>(
          create: (_) => CartBloc()..add(const LoadCartEvent()),
        ),
        BlocProvider<AddressBloc>(create: (_) => AddressBloc()),
        BlocProvider<CheckoutBloc>(create: (_) => CheckoutBloc()),
    BlocProvider<OrderBloc>(create: (_) => OrderBloc()),
      ],
      child: MaterialApp.router(
        title: 'Shoploc',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        scaffoldMessengerKey: AppSnackbar.messengerKey,
        // Responsive.init must run before any screen uses Responsive.*
        builder: (context, child) {
          Responsive.init(context);
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}