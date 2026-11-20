import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/termsbloc/terms_bloc.dart';
import '../bloc/termsbloc/terms_event.dart';
import '../bloc/termsbloc/terms_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../data/models/privacypolicymodel.dart';
import '../data/models/termsmodel.dart';
import '../widgets/responsive.dart';
import 'enquiry_screen.dart';

/// Terms & Conditions loaded from GET /terms-and-conditions.
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TermsBloc()..add(const LoadTermsEvent()),
      child: const _TermsView(),
    );
  }
}

class _TermsView extends StatefulWidget {
  const _TermsView();

  @override
  State<_TermsView> createState() => _TermsViewState();
}

class _TermsViewState extends State<_TermsView> {
  static const Color _ink = Color(0xFF111827);

  /// One key per section, used by the contents chips to scroll to a card.
  final Map<int, GlobalKey> _sectionKeys = {};

  GlobalKey _keyFor(int i) => _sectionKeys.putIfAbsent(i, () => GlobalKey());

  // ---------------- text styles ----------------
  TextStyle _body(double size,
      {Color color = const Color(0xFF374151),
        FontWeight weight = FontWeight.normal,
        double? height,
        double? letterSpacing,
        TextDecoration? decoration}) =>
      GoogleFonts.plusJakartaSans(
        textStyle: TextStyle(
          fontFamily: AppTextStyle.bodyFont,
          fontSize: Responsive.sp(size),
          fontWeight: weight,
          color: color,
          height: height,
          letterSpacing: letterSpacing,
          decoration: decoration,
        ),
      );

  TextStyle _heading(double size, {FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.playfairDisplay(
        textStyle: TextStyle(
          fontFamily: AppTextStyle.headingFont,
          fontSize: Responsive.sp(size),
          fontWeight: weight,
          color: _ink,
          letterSpacing: -0.2,
        ),
      );

  // ---------------- actions ----------------
  void _scrollToSection(int index) {
    final ctx = _keyFor(index).currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _copyToClipboard(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied: $value',
            style: TextStyle(fontFamily: AppTextStyle.bodyFont)),
        backgroundColor: AppColors.brandBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openEnquiry() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EnquiryScreen()),
    );
  }

  Future<void> _refresh() async {
    final bloc = context.read<TermsBloc>();
    bloc.add(const RefreshTermsEvent());
    await bloc.stream.first
        .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
  }

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text('Terms & Conditions', style: AppTextStyle.appBarTitle),
      ),
      body: SafeArea(
        child: BlocBuilder<TermsBloc, TermsState>(
          builder: (context, state) {
            if (state is TermsLoadedState) {
              return _loaded(state.terms);
            }
            if (state is TermsErrorState) {
              return _error(state.errorMessage);
            }
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _error(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.sp(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 44, color: AppColors.textTertiary),
            SizedBox(height: Responsive.sp(12)),
            Text('Could not load terms & conditions',
                style: AppTextStyle.sectionHeading),
            SizedBox(height: Responsive.sp(6)),
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyle.caption),
            SizedBox(height: Responsive.sp(14)),
            ElevatedButton(
              onPressed: () =>
                  context.read<TermsBloc>().add(const LoadTermsEvent()),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loaded(TermsResponse policy) {
    final sections = policy.sections;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ResponsiveCenter(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.sp(18), vertical: Responsive.sp(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(policy.title),
                SizedBox(height: Responsive.sp(18)),
                if (sections.isNotEmpty) ...[
                  _contents(sections),
                  SizedBox(height: Responsive.sp(22)),
                ],
                for (int i = 0; i < sections.length; i++) ...[
                  _card(index: i, section: sections[i]),
                  SizedBox(height: Responsive.sp(16)),
                ],
                SizedBox(height: Responsive.sp(4)),
                _contactButton(),
                SizedBox(height: Responsive.sp(28)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- header ----------------
  Widget _header(String title) {
    return Container(
      padding: EdgeInsets.all(Responsive.sp(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.sp(10), vertical: Responsive.sp(4)),
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'LEGAL AGREEMENT',
              style: _body(11,
                  color: AppColors.brandBlue,
                  weight: FontWeight.w800,
                  letterSpacing: 0.8),
            ),
          ),
          SizedBox(height: Responsive.sp(12)),
          Text(title, style: _heading(26, weight: FontWeight.w800)),
          SizedBox(height: Responsive.sp(8)),
          Text(
            'Please read these terms carefully before using Shoploc or placing an order.',
            style: _body(13, color: const Color(0xFF6B7280), height: 1.45),
          ),
        ],
      ),
    );
  }

  // ---------------- contents chips ----------------
  Widget _contents(List<PolicySectionModel> sections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTENTS',
          style: _body(12,
              color: const Color(0xFF9CA3AF),
              weight: FontWeight.w800,
              letterSpacing: 1.2),
        ),
        SizedBox(height: Responsive.sp(8)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(sections.length, (i) {
            return ActionChip(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              label: Text(
                '${i + 1}. ${sections[i].title}',
                style: _body(12.5,
                    color: AppColors.brandBlue, weight: FontWeight.w600),
              ),
              onPressed: () => _scrollToSection(i),
            );
          }),
        ),
      ],
    );
  }

  // ---------------- section card ----------------
  Widget _card({required int index, required PolicySectionModel section}) {
    final isContact = section.title.toLowerCase().contains('contact');
    return Container(
      key: _keyFor(index),
      padding: EdgeInsets.all(Responsive.sp(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.sp(9), vertical: Responsive.sp(4)),
                decoration: BoxDecoration(
                  color: _ink,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text((index + 1).toString().padLeft(2, '0'),
                    style: _body(12,
                        color: Colors.white, weight: FontWeight.w800)),
              ),
              SizedBox(width: Responsive.sp(12)),
              Expanded(child: Text(section.title, style: _heading(19))),
            ],
          ),
          SizedBox(height: Responsive.sp(14)),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          SizedBox(height: Responsive.sp(14)),
          ..._blocks(section, isContact: isContact),
        ],
      ),
    );
  }

  /// Turns parsed blocks into widgets.
  ///  - highlight-box                              -> blue info box
  ///  - labelled bullets in the contact section    -> tappable contact rows
  List<Widget> _blocks(PolicySectionModel section, {required bool isContact}) {
    final out = <Widget>[];

    for (final b in section.blocks) {
      switch (b.type) {
        case PolicyBlockType.paragraph:
          out.add(Padding(
            padding: EdgeInsets.only(bottom: Responsive.sp(10)),
            child: Text(b.text, style: _body(13.5, height: 1.5)),
          ));
          break;

        case PolicyBlockType.highlight:
          out.add(Padding(
            padding: EdgeInsets.only(bottom: Responsive.sp(10)),
            child: _infoBox(b.text),
          ));
          break;

        case PolicyBlockType.bullet:
          if (isContact && b.label.isNotEmpty) {
            out.add(_contactRow(b));
          } else {
            out.add(_bullet(b));
          }
          break;
      }
    }
    return out;
  }

  // ---------------- block widgets ----------------
  Widget _bullet(PolicyBlock b) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.sp(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: Responsive.sp(6)),
            child: const Icon(Icons.circle, size: 6, color: AppColors.brandBlue),
          ),
          SizedBox(width: Responsive.sp(10)),
          Expanded(
              child: _richText(
                  b, _body(13.5, color: const Color(0xFF4B5563), height: 1.45))),
        ],
      ),
    );
  }

  Widget _richText(PolicyBlock b, TextStyle base) {
    return RichText(
      text: TextSpan(
        style: base,
        children: [
          if (b.label.isNotEmpty)
            TextSpan(
              text: '${b.label} ',
              style: base.copyWith(color: _ink, fontWeight: FontWeight.w700),
            ),
          TextSpan(text: b.text),
        ],
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      padding: EdgeInsets.all(Responsive.sp(14)),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: Responsive.sp(18), color: AppColors.brandBlue),
          SizedBox(width: Responsive.sp(10)),
          Expanded(
            child: Text(
              text,
              style: _body(13,
                  color: const Color(0xFF1E3A8A),
                  weight: FontWeight.w600,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- contact rows ----------------
  Widget _contactRow(PolicyBlock b) {
    final label = b.label.toLowerCase();
    final isEmail = label.contains('email');
    final isHours = label.contains('hour');
    final isPage = label.contains('page') ||
        label.contains('website') ||
        label.contains('contact');
    final isPhone = label.contains('phone') || label.contains('call');

    final IconData icon = isEmail
        ? Icons.email_outlined
        : isHours
        ? Icons.access_time_rounded
        : isPhone
        ? Icons.phone_outlined
        : Icons.language_rounded;

    VoidCallback? onTap;
    if (isEmail) {
      onTap = () => _copyToClipboard('Email', b.text);
    } else if (isPhone) {
      onTap = () => _copyToClipboard('Phone', b.text);
    } else if (isPage) {
      onTap = _openEnquiry;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.sp(5)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: Responsive.sp(16), color: AppColors.brandBlue),
            SizedBox(width: Responsive.sp(8)),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: _body(13, color: _ink),
                  children: [
                    TextSpan(
                      text: '${b.label} ',
                      style: _body(13, color: _ink, weight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: b.text,
                      style: onTap != null
                          ? _body(13,
                          color: AppColors.brandBlue,
                          decoration: TextDecoration.underline)
                          : _body(13, color: const Color(0xFF4B5563)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- bottom button ----------------
  Widget _contactButton() {
    return SizedBox(
      width: double.infinity,
      height: Responsive.sp(48),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: _openEnquiry,
        icon: Icon(Icons.send_rounded, size: Responsive.sp(16)),
        label: Text('Have a question? Contact Us',
            style: _body(14, color: Colors.white, weight: FontWeight.w700)),
      ),
    );
  }
}