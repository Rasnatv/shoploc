import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../data/models/order_model.dart';

class TrackOrderScreen extends StatelessWidget {
  final OrderModel order;
  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Track Order', style: AppTextStyle.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Estimate Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.id, style: AppTextStyle.sectionHeading.copyWith(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(
                          'Estimated Delivery: 2-3 Business Days',
                          style: AppTextStyle.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text('Timeline', style: AppTextStyle.sectionHeading),
            const SizedBox(height: 14),

            // Timeline Steps
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: List.generate(order.trackingSteps.length, (index) {
                  final step = order.trackingSteps[index];
                  final isLast = index == order.trackingSteps.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Node and connecting line
                      Column(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: step.isCompleted
                                  ? AppColors.primary
                                  : (step.isCurrent ? AppColors.accent : AppColors.surfaceVariant),
                              border: Border.all(
                                color: step.isCompleted || step.isCurrent
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: step.isCompleted
                                ? const Icon(Icons.check, size: 13, color: Colors.white)
                                : (step.isCurrent
                                    ? const Center(
                                        child: SizedBox(
                                          width: 8,
                                          height: 8,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : null),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 48,
                              color: step.isCompleted
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    step.title,
                                    style: AppTextStyle.labelLarge.copyWith(
                                      color: step.isCompleted || step.isCurrent
                                          ? AppColors.textPrimary
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                  Text(
                                    step.timestamp,
                                    style: AppTextStyle.caption.copyWith(color: AppColors.textTertiary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                step.subtitle,
                                style: AppTextStyle.caption.copyWith(
                                  color: step.isCompleted || step.isCurrent
                                      ? AppColors.textSecondary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

