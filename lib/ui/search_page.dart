import 'package:flutter/material.dart';
import '../core/appcolors.dart';
import '../core/apptheme.dart';
import '../core/responsive.dart';
import '../data/app_data.dart';
import '../widgets/heart_button.dart';
import '../widgets/product_image.dart';
import '../widgets/star_rating.dart';
import 'product_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController(text: 'kurta set');
  String _chip = 'All';
  static const _chips = ['All', 'Dresses', 'Kurta Sets', 'Tops'];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _ctrl.text.trim().toLowerCase().split(' ').first;
    var results = AppData.products
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
    if (_chip == 'Kurta Sets') {
      results = results.where((p) => p.category == 'Kurta Sets').toList();
    } else if (_chip == 'Dresses') {
      results = results.where((p) => p.category == 'Midi Dress').toList();
    } else if (_chip == 'Tops') {
      results = results.where((p) => p.category == 'Tops & Tunics').toList();
    }
    final pad = Responsive.hPad(context);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 800,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context)),
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.search, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                              border: InputBorder.none, isDense: true),
                        ),
                      ),
                      GestureDetector(
                          onTap: () => setState(_ctrl.clear),
                          child: const Icon(Icons.close, size: 18)),
                    ]),
                  ),
                ),
              ]),
            ),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: pad),
                children: _chips
                    .map((t) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(t,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _chip == t
                                        ? Colors.white
                                        : AppColors.dark)),
                            selected: _chip == t,
                            showCheckmark: false,
                            onSelected: (_) => setState(() => _chip = t),
                          ),
                        ))
                    .toList(),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView.separated(
                      padding: EdgeInsets.all(pad),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) {
                        final p = results[i];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(p))),
                          child: Row(children: [
                            Stack(children: [
                              ProductImage(p.color, width: 95, height: 95),
                              Positioned(
                                  top: 4,
                                  right: 4,
                                  child: HeartButton(p, size: 24)),
                            ]),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: AppText.body),
                                    const SizedBox(height: 4),
                                    Text('₹${p.price}',
                                        style: AppText.price
                                            .copyWith(fontSize: 16)),
                                    const SizedBox(height: 6),
                                    StarRating(p.rating, p.reviews),
                                  ]),
                            ),
                          ]),
                        );
                      },
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}
