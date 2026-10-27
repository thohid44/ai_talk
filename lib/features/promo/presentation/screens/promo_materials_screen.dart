import 'package:ai_talk_test/core/theme/app_colors.dart';
import 'package:ai_talk_test/core/widgets/custom_button.dart';
import 'package:ai_talk_test/core/widgets/empty_view.dart';
import 'package:ai_talk_test/core/widgets/error_view.dart';
import 'package:ai_talk_test/core/widgets/loading_view.dart';
import 'package:ai_talk_test/core/widgets/responsive_frame.dart';
import 'package:ai_talk_test/features/promo/domain/entities/cc_promo.dart';
import 'package:ai_talk_test/features/promo/presentation/providers/promo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PromoMaterialsScreen extends StatefulWidget {
  const PromoMaterialsScreen({super.key});

  @override
  State<PromoMaterialsScreen> createState() => _PromoMaterialsScreenState();
}

class _PromoMaterialsScreenState extends State<PromoMaterialsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PromoProvider>().load();
    });
  }

  Future<void> _load() => context.read<PromoProvider>().load();

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url.trim());
    final scheme = uri?.scheme.toLowerCase();
    if (uri == null || (scheme != 'http' && scheme != 'https')) {
      _showMessage('This link cannot be opened.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showMessage('Unable to open the link.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final promo = context.watch<PromoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Promo')),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ResponsiveFrame(child: _buildBody(context, promo)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PromoProvider promo) {
    if (!promo.hasLoaded || (promo.isLoading && promo.materials.isEmpty)) {
      return const LoadingView();
    }

    final error = promo.errorMessage?.trim();
    if (error != null && error.isNotEmpty && promo.materials.isEmpty) {
      return ErrorView(
        title: 'Unable to load materials',
        message: error,
        actionLabel: 'Retry',
        onAction: _load,
      );
    }

    if (promo.materials.isEmpty) {
      return const EmptyView(
        icon: Icons.campaign_outlined,
        title: 'No promo materials',
        message: 'Promotional materials are not available yet.',
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        itemCount: promo.materials.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          return _PromoCard(
            item: promo.materials[index],
            onOpenLink: _openLink,
          );
        },
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.item, required this.onOpenLink});

  final CcPromo item;
  final Future<void> Function(String url) onOpenLink;

  @override
  Widget build(BuildContext context) {
    final text = item.text?.trim();
    final imageUrl = item.imageUrl?.trim();
    final linkUrl = item.linkUrl?.trim();
    final buttonText = item.buttonText?.trim();
    final buttonColor =
        _parseHex(item.buttonColor) ?? Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: _PromoImage(imageUrl: imageUrl),
          ),
          if (text != null && text.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                height: 1.4,
              ),
            ),
          ],
          if (linkUrl != null && linkUrl.isNotEmpty) ...[
            SizedBox(height: 12.h),
            CustomButton(
              width: double.infinity,
              height: 44.h,
              text: buttonText == null || buttonText.isEmpty
                  ? 'Open link'
                  : buttonText,
              backgroundColor: buttonColor,
              textColor: Colors.white,
              onPressed: () => onOpenLink(linkUrl),
            ),
          ],
        ],
      ),
    );
  }
}

Color? _parseHex(String? value) {
  if (value == null) return null;
  var hex = value.trim();
  if (hex.startsWith('#')) hex = hex.substring(1);
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return null;
  final color = int.tryParse(hex, radix: 16);
  if (color == null) return null;
  return Color(color);
}

class _PromoImage extends StatelessWidget {
  const _PromoImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return const _ImagePlaceholder();
    }

    return Image.network(
      url,
      height: 150.h,
      width: double.infinity,
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: 150.h,
          width: double.infinity,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.h,
      width: double.infinity,
      color: AppColors.imageWell,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: 36.sp, color: AppColors.hint),
    );
  }
}
