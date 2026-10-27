import 'package:ai_talk_test/core/theme/app_colors.dart';
import 'package:ai_talk_test/core/widgets/empty_view.dart';
import 'package:ai_talk_test/core/widgets/error_view.dart';
import 'package:ai_talk_test/core/widgets/responsive_frame.dart';
import 'package:ai_talk_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:ai_talk_test/features/profile/domain/entities/account_information.dart';
import 'package:ai_talk_test/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  Future<void> _load() {
    final session = context.read<AuthProvider>().session;
    return context.read<ProfileProvider>().load(session);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final login = context.watch<AuthProvider>().session?.login;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        top: false,
        bottom: false,
        child: login == null && !profile.hasDetails
            ? const EmptyView(
                icon: Icons.person_outline,
                title: 'No profile details',
                message: 'Sign in to view your account information.',
              )
            : RefreshIndicator(
                color: primary,
                onRefresh: () async => _load(),
                child: ResponsiveFrame(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                    children: [
                      if (profile.isLoading)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              minHeight: 3.h,
                              color: primary,
                              backgroundColor: AppColors.track,
                            ),
                          ),
                        ),
                      _ProfileHeader(
                        name: _text(profile.account?.name),
                        login: login,
                        country: _text(profile.account?.country),
                        city: _text(profile.account?.city),
                      ),
                      if (profile.errorMessage != null) ...[
                        SizedBox(height: 12.h),
                        ErrorBanner(
                          message: profile.errorMessage!,
                          detail: profile.statusDetail,
                          actionLabel: 'Retry',
                          onAction: profile.isLoading ? null : _load,
                        ),
                      ] else if (profile.warningMessage != null) ...[
                        SizedBox(height: 12.h),
                        ErrorBanner(
                          message: profile.warningMessage!,
                          detail: profile.statusDetail,
                          warning: true,
                          actionLabel: 'Retry',
                          onAction: profile.isLoading ? null : _load,
                        ),
                      ],
                      if (profile.account != null) ...[
                        SizedBox(height: 12.h),
                        _BalanceRow(account: profile.account!),
                      ],
                      ..._sections(profile),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _sections(ProfileProvider profile) {
    final account = profile.account;
    final sections = <_ProfileSection>[
      _ProfileSection(
        title: 'Contact',
        rows: [
          _field('Phone', _text(profile.phone)),
          _field('Country', _text(account?.country)),
          _field('City', _text(account?.city)),
          _field('Address', _text(account?.address)),
          _field('ZIP code', _text(account?.zipCode)),
        ],
      ),
      _ProfileSection(
        title: 'Account',
        rows: [
          _field('Currency', _currency(account?.currency)),
          _field(
            'Leverage',
            account?.leverage == null ? null : '1:${account!.leverage}',
          ),
          _field('Account type', _accountType(account?.type)),
          _field('Verification', _verification(account?.verificationLevel)),
          _field('Swap free', _yesNo(account?.isSwapFree)),
        ],
      ),
      _ProfileSection(
        title: 'Trading',
        rows: [
          _field('Open trades', account?.currentTradesCount?.toString()),
          _field('Open volume', _amount(account?.currentTradesVolume)),
          _field('Total trades', account?.totalTradesCount?.toString()),
          _field('Total volume', _amount(account?.totalTradesVolume)),
          _field('Any open trades', _yesNo(account?.isAnyOpenTrades)),
        ],
      ),
    ];

    return [
      for (final section in sections)
        if (section.visible.isNotEmpty) ...[
          SizedBox(height: 16.h),
          _SectionCard(section: section),
        ],
    ];
  }

  _ProfileField? _field(String label, String? value) {
    if (value == null || value.isEmpty) return null;
    return _ProfileField(label: label, value: value);
  }

  String? _text(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  String? _amount(num? value) {
    if (value == null) return null;
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  String? _yesNo(bool? value) {
    if (value == null) return null;
    return value ? 'Yes' : 'No';
  }

  String? _currency(int? code) {
    const labels = <int, String>{
      0: 'USD',
      1: 'EUR',
      2: 'RUB',
      3: 'GBP',
      4: 'JPY',
      5: 'CHF',
      6: 'CAD',
      7: 'AUD',
      8: 'NZD',
    };
    if (code == null) return null;
    return labels[code];
  }

  String? _accountType(int? type) {
    const labels = <int, String>{
      0: 'Standard',
      1: 'Cent',
      2: 'ECN',
      3: 'Pro',
      4: 'Zero',
      5: 'Raw',
    };
    if (type == null) return null;
    return labels[type];
  }

  String? _verification(int? level) {
    switch (level) {
      case null:
        return null;
      case 0:
        return 'Not verified';
      case 1:
        return 'Level 1 · Identity';
      case 2:
        return 'Level 2 · Address';
      default:
        return 'Level $level';
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.login,
    required this.country,
    required this.city,
  });

  final String? name;
  final int? login;
  final String? country;
  final String? city;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final title = name ?? 'My account';
    final initials = _initials(name);
    final place = [?city, ?country].join(', ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            height: 56.w,
            width: 56.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: initials == null
                ? Icon(Icons.person, color: primary, size: 28.sp)
                : Text(
                    initials,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (login != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Login ID $login',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
                if (place.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    place,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _initials(String? name) {
    final parts =
        name
            ?.trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList() ??
        const <String>[];
    if (parts.isEmpty) return null;
    String letter(String word) {
      final iterator = word.runes.iterator;
      if (!iterator.moveNext()) return '';
      return String.fromCharCode(iterator.current).toUpperCase();
    }

    if (parts.length == 1) return letter(parts.first);
    return '${letter(parts.first)}${letter(parts.last)}';
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({required this.account});

  final AccountInformation account;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 360;
        final tiles = [
          _BalanceTile(
            label: 'Balance',
            value: _money(account.balance),
            icon: Icons.account_balance_wallet_outlined,
          ),
          _BalanceTile(
            label: 'Equity',
            value: _money(account.equity),
            icon: Icons.pie_chart_outline,
          ),
          _BalanceTile(
            label: 'Free margin',
            value: _money(account.freeMargin),
            icon: Icons.savings_outlined,
          ),
        ];
        if (stacked) {
          return Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) SizedBox(height: 8.h),
                tiles[i],
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) SizedBox(width: 8.w),
              Expanded(child: tiles[i]),
            ],
          ],
        );
      },
    );
  }

  String _money(double? value) {
    if (value == null) return '—';
    final negative = value < 0;
    final fixed = value.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    final digits = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    final text = '${buffer.toString()}.${parts.last}';
    return negative ? '-$text' : text;
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: primary),
          SizedBox(height: 8.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection {
  const _ProfileSection({required this.title, required this.rows});

  final String title;
  final List<_ProfileField?> rows;

  List<_ProfileField> get visible =>
      rows.whereType<_ProfileField>().toList(growable: false);
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final _ProfileSection section;

  @override
  Widget build(BuildContext context) {
    final rows = section.visible;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 4.h),
          for (var i = 0; i < rows.length; i++) ...[
            _ProfileRow(field: rows[i]),
            if (i != rows.length - 1)
              const Divider(height: 1, color: AppColors.line),
          ],
        ],
      ),
    );
  }
}

class _ProfileField {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.field});

  final _ProfileField field;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              field.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 6,
            child: Text(
              field.value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
