
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/bloc/addressbloc/address_bloc.dart';
import 'app/bloc/addressbloc/address_event.dart';
import 'app/bloc/authbloc/auth_bloc.dart';
import 'app/bloc/authbloc/auth_event.dart';
import 'app/bloc/cartbloc/cart_bloc.dart';
import 'app/bloc/cartbloc/cart_event.dart';
import 'app/bloc/categoriesbloc/category_bloc.dart';
import 'app/bloc/categoriesbloc/category_event.dart';
import 'app/bloc/checkoutbloc/checkout_bloc.dart';
import 'app/bloc/homebloc/home_bloc.dart';
import 'app/bloc/homebloc/home_event.dart';
import 'app/bloc/notificationbloc/notification_bloc.dart';
import 'app/bloc/notificationbloc/notification_event.dart';
import 'app/bloc/ordersbloc/order_bloc.dart';
import 'app/bloc/ordersbloc/order_event.dart';
import 'app/bloc/productbloc/product_bloc.dart';
import 'app/bloc/productbloc/product_event.dart';
import 'app/bloc/profilebloc/profile_bloc.dart';
import 'app/bloc/profilebloc/profile_event.dart';
import 'app/bloc/whishlistbloc/wishlist_bloc.dart';
import 'app/bloc/whishlistbloc/wishlist_event.dart';
import 'app/core/storage/local_storage_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/ui/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Loaded once; getInstance() is cached so it is safe to reuse
  static final Future<LocalStorageService> _storageFuture =
  LocalStorageService.getInstance();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocalStorageService>(
      future: _storageFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: SizedBox.shrink()),
          );
        }

        final storageService = snapshot.data!;

        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (_) => AuthBloc(storageService: storageService)
                ..add(const CheckAuthStatusEvent()),
            ),
            BlocProvider<HomeBloc>(
              create: (_) => HomeBloc(storageService: storageService)
                ..add(const LoadHomeDataEvent()),
            ),
            BlocProvider<CategoryBloc>(
              create: (_) => CategoryBloc()..add(const LoadCategoriesEvent()),
            ),
            BlocProvider<ProductBloc>(
              create: (_) => ProductBloc(storageService: storageService)
                ..add(const LoadProductsEvent()),
            ),
            BlocProvider<WishlistBloc>(
              create: (_) => WishlistBloc(storageService: storageService)
                ..add(const LoadWishlistEvent()),
            ),
            BlocProvider<CartBloc>(
              create: (_) => CartBloc(storageService: storageService)
                ..add(const LoadCartEvent()),
            ),
            BlocProvider<AddressBloc>(
              create: (_) => AddressBloc(storageService: storageService)
                ..add(const LoadAddressesEvent()),
            ),
            BlocProvider<OrderBloc>(
              create: (_) => OrderBloc(storageService: storageService)
                ..add(const LoadOrdersEvent()),
            ),
            BlocProvider<CheckoutBloc>(
              create: (_) => CheckoutBloc(),
            ),
            BlocProvider<ProfileBloc>(
              create: (_) => ProfileBloc(storageService: storageService)
                ..add(const LoadProfileEvent()),
            ),
            BlocProvider<NotificationBloc>(
              create: (_) => NotificationBloc(storageService: storageService)
                ..add(const LoadNotificationsEvent()),
            ),
          ],
          child: MaterialApp(
            title: 'Shoploc',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}