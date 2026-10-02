
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/apptheme.dart';
import '../core/appimages.dart';
import '../core/responsive.dart';
import '../data/app_data.dart';
import 'cart_page.dart';
import 'product_list_page.dart';
import 'search_page.dart';

/// ShopLoc palette (same as the onboarding screen).
class _C {
  static const bg = Color(0xFFFCFCFA);
  static const blue = Color(0xFF2F7BE8);
  static const blueLight = Color(0xFFD6E8FB);
  static const searchBg = Color(0xFFEAF2FC);
  static const orange = Color(0xFFFFA24C);
  static const orangeLight = Color(0xFFFFE3C9);
  static const navy = Color(0xFF2C3A55);
  static const grey = Color(0xFF8A94A6);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Banner image ratio (1456 x 720)
  static const double _bannerRatio = 1456 / 720;
  static const Duration _autoDelay = Duration(seconds: 4);

  /// Banner images (image only). Add more paths here to add more slides.
  static const List<String> _banners = [
    AppAssets.banner,
    AppAssets.banner3,
  ];

  final PageController _pageController = PageController();
  final ValueNotifier<int> _current = ValueNotifier<int>(0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _current.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoDelay, (_) {
      if (!_pageController.hasClients) return;
      final next = (_current.value + 1) % _banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _openNewArrivals(BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const ProductListPage(
              title: 'New Arrivals', products: AppData.products)));

  // ---------------------------------------------------------------- slides
  /// One banner slide: just the image (tap opens New Arrivals).
  Widget _imageSlide(BuildContext context, String path) => GestureDetector(
    onTap: () => _openNewArrivals(context),
    child: Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: _C.blueLight,
        child: const Center(
            child: Icon(Icons.image_outlined, color: _C.blue, size: 40)),
      ),
    ),
  );

  // ---------------------------------------------------------- banner carousel
  Widget _bannerCarousel(BuildContext context) {
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: _bannerRatio,
          // Pause auto-slide while the user is touching, resume after.
          child: Listener(
            onPointerDown: (_) => _timer?.cancel(),
            onPointerUp: (_) => _startAutoSlide(),
            onPointerCancel: (_) => _startAutoSlide(),
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => _current.value = i,
              children: [
                for (final path in _banners) _imageSlide(context, path),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      // Dots indicator
      ValueListenableBuilder<int>(
        valueListenable: _current,
        builder: (_, index, __) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
                (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: i == index ? 20 : 6,
              decoration: BoxDecoration(
                color: i == index ? _C.blue : _C.blueLight,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  // ---------------------------------------------------------- category image
  /// Uses product1 / product2 / product3 images (cycled) in the circles.
  Widget _categoryImage(int index) {
    return Image.asset(
      AppAssets.categoryImage(index),
      fit: BoxFit.cover,
      width: 56,
      height: 56,
      errorBuilder: (_, __, ___) => Icon(Icons.checkroom,
          color: index.isEven ? _C.blue : _C.orange),
    );
  }

  // ------------------------------------------------------- new arrivals grid
  Widget _newArrivals(int cols) {
    final items = AppData.products.take(cols).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (_, i) => _productCard(items[i], i),
    );
  }

  Widget _productCard(dynamic p, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.asset(
              AppAssets.productImage(index),
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: _C.blueLight,
                child: const Center(
                    child: Icon(Icons.checkroom, color: _C.blue, size: 36)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: _C.navy)),
            const SizedBox(height: 4),
            Row(children: [
              Text('\u20B9${p.price}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.blue)),
              if (p.oldPrice != null) ...[
                const SizedBox(width: 6),
                Text('\u20B9${p.oldPrice}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: _C.grey,
                        decoration: TextDecoration.lineThrough)),
              ],
              const Spacer(),
              const Icon(Icons.star, size: 12, color: _C.orange),
              const SizedBox(width: 2),
              Text('${p.rating}',
                  style: const TextStyle(fontSize: 10, color: _C.navy)),
            ]),
          ]),
        ),
      ]),
    );
  }

  // -------------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hPad(context);
    final cols = Responsive.gridCount(context);
    final cats = AppData.categories;

    return ColoredBox(
      color: _C.bg,
      child: SafeArea(
        child: ResponsiveCenter(
          child: ListView(padding: EdgeInsets.all(pad), children: [
            // Header
            Row(children: [
              const Icon(Icons.menu, color: _C.navy),
              const Spacer(),
              Image.asset(
                AppAssets.logo,
                height: 60,
                errorBuilder: (_, __, ___) => const Text('ShopLoc',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _C.blue)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartPage())),
                child: const Icon(Icons.shopping_cart_outlined, color: _C.navy),
              ),
            ]),
            const SizedBox(height: 14),

            // Search bar
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchPage())),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                    color: _C.searchBg,
                    borderRadius: BorderRadius.circular(14)),
                child: const Row(children: [
                  Icon(Icons.search, color: _C.blue, size: 20),
                  SizedBox(width: 8),
                  Text('Search for dresses, kurtas, tops...',
                      style: TextStyle(color: _C.grey, fontSize: 13)),
                ]),
              ),
            ),
            const SizedBox(height: 14),

            // Auto-moving banner (images only)
            _bannerCarousel(context),
            const SizedBox(height: 16),

            // Category circles with images
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProductListPage(
                              title: cats[i].name,
                              products: AppData.products
                                  .where((p) => p.category == cats[i].name)
                                  .toList()))),
                  child: Column(children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i.isEven ? _C.blueLight : _C.orangeLight,
                      ),
                      child: ClipOval(child: _categoryImage(i)),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 64,
                      child: Text(cats[i].name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style:
                          const TextStyle(fontSize: 10, color: _C.navy)),
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // New arrivals
            Row(children: [
              const Text('New Arrivals', style: AppText.title),
              const Spacer(),
              GestureDetector(
                onTap: () => _openNewArrivals(context),
                child: const Text('See All >',
                    style: TextStyle(
                        fontSize: 12,
                        color: _C.blue,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 10),
            _newArrivals(cols),
            const SizedBox(height: 14),
            const Divider(),

            // Trust row
            const Row(children: [
              Expanded(
                  child: ListTile(
                      dense: true,
                      leading: Icon(Icons.local_shipping_outlined,
                          color: _C.orange),
                      title: Text('Free Delivery',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _C.navy)),
                      subtitle: Text('on all orders',
                          style: TextStyle(fontSize: 10)))),
              Expanded(
                  child: ListTile(
                      dense: true,
                      leading: Icon(Icons.verified, color: _C.blue),
                      title: Text('Trusted Local',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _C.navy)),
                      subtitle: Text('Sellers (Kasaragod)',
                          style: TextStyle(fontSize: 10)))),
            ]),
          ]),
        ),
      ),
    );
  }
}