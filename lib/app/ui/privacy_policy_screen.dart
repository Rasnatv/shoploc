
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/privacypolicy/privacypolicy_bloc.dart';
import '../bloc/privacypolicy/privacypolicy_event.dart';
import '../bloc/privacypolicy/privacypolicy_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../data/models/privacypolicymodel.dart';
import '../widgets/responsive.dart';
import 'enquiry_screen.dart';

/// Privacy policy loaded from GET /privacy-policy.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PrivacyBloc()..add(const LoadPrivacyPolicyEvent()),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  static const Color _teal = Color(0xFF0D9488);
  static const Color _ink = Color(0xFF111827);

  TextStyle _body(double size,
      {Color color = const Color(0xFF374151),
        FontWeight weight = FontWeight.normal,
        double? height,
        double? letterSpacing}) =>
      GoogleFonts.plusJakartaSans(
        textStyle: TextStyle(
          fontFamily: AppTextStyle.bodyFont,
          fontSize: Responsive.sp(size),
          fontWeight: weight,
          color: color,
          height: height,
          letterSpacing: letterSpacing,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Privacy Policy', style: AppTextStyle.appBarTitle),
      ),
      body: SafeArea(
        child: BlocBuilder<PrivacyBloc, PrivacyState>(
          builder: (context, state) {
            if (state is PrivacyLoadedState) {
              return _loaded(context, state.policy);
            }
            if (state is PrivacyErrorState) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.sp(24)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded,
                          size: 44, color: AppColors.textTertiary),
                      SizedBox(height: Responsive.sp(12)),
                      Text('Could not load privacy policy',
                          style: AppTextStyle.sectionHeading),
                      SizedBox(height: Responsive.sp(6)),
                      Text(state.errorMessage,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.caption),
                      SizedBox(height: Responsive.sp(14)),
                      ElevatedButton(
                        onPressed: () => context
                            .read<PrivacyBloc>()
                            .add(const LoadPrivacyPolicyEvent()),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
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

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<PrivacyBloc>();
    bloc.add(const RefreshPrivacyPolicyEvent());
    await bloc.stream.first
        .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
  }

  Widget _loaded(BuildContext context, PrivacyPolicyResponse policy) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _refresh(context),
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
                SizedBox(height: Responsive.sp(20)),
                for (int i = 0; i < policy.sections.length; i++) ...[
                  _card(
                    number: (i + 1).toString().padLeft(2, '0'),
                    section: policy.sections[i],
                  ),
                  SizedBox(height: Responsive.sp(16)),
                ],
                SizedBox(height: Responsive.sp(4)),
                _contactButton(context),
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
              color: _teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'DATA PROTECTION & PRIVACY',
              style: _body(11,
                  color: _teal, weight: FontWeight.w800, letterSpacing: 0.8),
            ),
          ),
          SizedBox(height: Responsive.sp(12)),
          Text(title, style: _heading(26, weight: FontWeight.w800)),
          SizedBox(height: Responsive.sp(8)),
          Text(
            'We value your trust and are committed to safeguarding your personal data.',
            style: _body(13, color: const Color(0xFF6B7280), height: 1.45),
          ),
        ],
      ),
    );
  }

  // ---------------- section card ----------------
  Widget _card({required String number, required PolicySectionModel section}) {
    return Container(
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
                  color: _teal,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(number,
                    style: _body(12,
                        color: Colors.white, weight: FontWeight.w800)),
              ),
              SizedBox(width: Responsive.sp(12)),
              Expanded(
                child: Text(section.title, style: _heading(18.5)),
              ),
            ],
          ),
          SizedBox(height: Responsive.sp(14)),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          SizedBox(height: Responsive.sp(14)),
          ...section.blocks.map(_block),
        ],
      ),
    );
  }

  Widget _block(PolicyBlock b) {
    switch (b.type) {
      case PolicyBlockType.paragraph:
        return Padding(
          padding: EdgeInsets.only(bottom: Responsive.sp(10)),
          child: Text(b.text, style: _body(13.5, height: 1.5)),
        );
      case PolicyBlockType.highlight:
        return Padding(
          padding: EdgeInsets.only(bottom: Responsive.sp(10)),
          child: _highlight(b.text),
        );
      case PolicyBlockType.bullet:
        return _bullet(b);
    }
  }

  Widget _highlight(String text) {
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
          Icon(Icons.security_rounded,
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

  Widget _bullet(PolicyBlock b) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.sp(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: Responsive.sp(6)),
            child: const Icon(Icons.circle, size: 6, color: _teal),
          ),
          SizedBox(width: Responsive.sp(10)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: _body(13.5, color: const Color(0xFF4B5563), height: 1.45),
                children: [
                  if (b.label.isNotEmpty)
                    TextSpan(
                      text: '${b.label} ',
                      style: _body(13.5,
                          color: _ink, weight: FontWeight.w700, height: 1.45),
                    ),
                  TextSpan(text: b.text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- contact button ----------------
  Widget _contactButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Responsive.sp(48),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _teal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EnquiryScreen()),
          );
        },
        icon: Icon(Icons.mail_outline_rounded, size: Responsive.sp(18)),
        label: Text('Contact Us',
            style: _body(14, color: Colors.white, weight: FontWeight.w700)),
      ),
    );
  }
}