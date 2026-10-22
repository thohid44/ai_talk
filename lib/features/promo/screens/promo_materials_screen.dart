import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PromoMaterialItem {
  const PromoMaterialItem({
    required this.title,
    this.description,
    this.imageUrl,
    this.linkUrl,
  });

  final String title;
  final String? description;
  final String? imageUrl;
  final String? linkUrl;
}

class PromoMaterialsScreen extends StatelessWidget {
  const PromoMaterialsScreen({
    super.key,
    this.materials = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onOpenLink,
  });

  final List<PromoMaterialItem> materials;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final void Function(String url)? onOpenLink;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promo Materials')),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = errorMessage?.trim();
    if (error != null && error.isNotEmpty) {
      return _PromoMessage(
        icon: Icons.error_outline,
        title: 'Unable to load materials',
        message: error,
        actionLabel: onRetry == null ? null : 'Retry',
        onAction: onRetry,
      );
    }

    if (materials.isEmpty) {
      return const _PromoMessage(
        icon: Icons.campaign_outlined,
        title: 'No promo materials',
        message: 'Promotional materials are not available yet.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      itemCount: materials.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return _PromoCard(
          item: materials[index],
          onOpenLink: onOpenLink,
        );
      },
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.item, this.onOpenLink});

  final PromoMaterialItem item;
  final void Function(String url)? onOpenLink;

  @override
  Widget build(BuildContext context) {
    final description = item.description?.trim();
    final imageUrl = item.imageUrl?.trim();
    final linkUrl = item.linkUrl?.trim();
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE3E8EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: _PromoImage(imageUrl: imageUrl),
          ),
          SizedBox(height: 12.h),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2332),
            ),
          ),
          if (description != null && description.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF5C6B7A),
                height: 1.4,
              ),
            ),
          ],
          if (linkUrl != null && linkUrl.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onOpenLink == null ? null : () => onOpenLink!(linkUrl),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open link'),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
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
      color: const Color(0xFFEEF2F6),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 36.sp,
        color: const Color(0xFF8A97A6),
      ),
    );
  }
}

class _PromoMessage extends StatelessWidget {
  const _PromoMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.sp, color: const Color(0xFF8A97A6)),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A2332),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF5C6B7A),
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 16.h),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
