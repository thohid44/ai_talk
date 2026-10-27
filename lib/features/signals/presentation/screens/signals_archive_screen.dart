import 'package:ai_talk_test/core/theme/app_colors.dart';
import 'package:ai_talk_test/core/widgets/custom_button.dart';
import 'package:ai_talk_test/core/widgets/custom_text_field.dart';
import 'package:ai_talk_test/core/widgets/empty_view.dart';
import 'package:ai_talk_test/core/widgets/error_view.dart';
import 'package:ai_talk_test/core/widgets/loading_view.dart';
import 'package:ai_talk_test/core/widgets/responsive_frame.dart';
import 'package:ai_talk_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:ai_talk_test/features/signals/domain/entities/analytic_signal.dart';
import 'package:ai_talk_test/features/signals/presentation/providers/signals_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SignalsArchiveScreen extends StatefulWidget {
  const SignalsArchiveScreen({super.key});

  @override
  State<SignalsArchiveScreen> createState() => _SignalsArchiveScreenState();
}

class _SignalsArchiveScreenState extends State<SignalsArchiveScreen> {
  static const List<String> _pairs = [
    'EURUSD',
    'GBPUSD',
    'USDJPY',
    'USDCHF',
    'USDCAD',
    'AUDUSD',
    'NZDUSD',
  ];

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  String _selectedPair = _pairs.first;
  late DateTime _fromDate;
  late DateTime _toDate;
  String? _filterError;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _fromDate = today;
    _toDate = today;
    final label = _formatDate(today);
    _fromController.text = label;
    _toController.text = label;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyFilter();
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initialDate = isFrom ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null || !mounted) return;

    final selected = _dateOnly(picked);
    setState(() {
      _filterError = null;
      if (isFrom) {
        _fromDate = selected;
        _fromController.text = _formatDate(selected);
      } else {
        _toDate = selected;
        _toController.text = _formatDate(selected);
      }
    });
    await _applyFilter();
  }

  Future<void> _applyFilter() async {
    final from = _dateOnly(_fromDate);
    final to = _dateOnly(_toDate);
    if (from.isAfter(to)) {
      setState(() => _filterError = 'From date must be on or before to date.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final login = auth.session?.login;
    final partnerToken = auth.passkey;
    if (login == null || !auth.hasValidPasskey || partnerToken == null) {
      setState(() {
        _filterError = auth.passkeyUnavailable
            ? 'Signals could not be authorized for this session.'
            : 'Log in again to load signals.';
      });
      return;
    }

    setState(() => _filterError = null);
    final archive = context.read<SignalsProvider>();
    await archive.load(
      login: login,
      partnerToken: partnerToken,
      pair: _selectedPair,
      from: from,
      to: to,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final archive = context.watch<SignalsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Signals Archive')),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ResponsiveFrame(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                sliver: SliverToBoxAdapter(
                  child: _filterCard(primary, archive),
                ),
              ),
              _resultsSliver(archive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterCard(Color primary, SignalsProvider archive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Currency pair',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final pair in _pairs)
                ChoiceChip(
                  label: Text(pair),
                  selected: _selectedPair == pair,
                  showCheckmark: false,
                  selectedColor: primary,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: _selectedPair == pair
                        ? primary
                        : AppColors.fieldBorder,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _selectedPair == pair ? Colors.white : primary,
                  ),
                  onSelected: (_) {
                    if (_selectedPair == pair) return;
                    setState(() => _selectedPair = pair);
                    _applyFilter();
                  },
                ),
            ],
          ),
          SizedBox(height: 16.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 420;
              final fromField = _dateField(
                label: 'From date',
                controller: _fromController,
                onTap: () => _pickDate(isFrom: true),
              );
              final toField = _dateField(
                label: 'To date',
                controller: _toController,
                onTap: () => _pickDate(isFrom: false),
              );
              if (stacked) {
                return Column(
                  children: [
                    fromField,
                    SizedBox(height: 12.h),
                    toField,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: fromField),
                  SizedBox(width: 12.w),
                  Expanded(child: toField),
                ],
              );
            },
          ),
          SizedBox(height: 16.h),
          CustomButton(
            width: double.infinity,
            height: 48.h,
            text: archive.isLoading ? 'Loading...' : 'Load Signals',
            backgroundColor: primary,
            textColor: Colors.white,
            onPressed: archive.isLoading ? null : _applyFilter,
          ),
        ],
      ),
    );
  }

  Widget _dateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: controller,
          hintText: 'Select',
          readOnly: true,
          onTap: onTap,
          suffixIcon: Icon(Icons.calendar_today_outlined, size: 18.sp),
        ),
      ],
    );
  }

  Widget _resultsSliver(SignalsProvider archive) {
    final Widget? status = archive.isLoading
        ? const LoadingView()
        : _filterError != null
        ? ErrorBanner(
            message: 'Unable to load signals',
            detail: _filterError,
            actionLabel: 'Retry',
            onAction: _applyFilter,
          )
        : !archive.hasLoaded
        ? const EmptyView(
            icon: Icons.filter_alt_outlined,
            title: 'No signals loaded',
            message:
                'Choose a currency pair and date range, then load signals.',
          )
        : archive.errorMessage != null
        ? ErrorBanner(
            message: 'Signals archive',
            detail: archive.errorMessage,
            actionLabel: 'Retry',
            onAction: _applyFilter,
          )
        : archive.signals.isEmpty
        ? const EmptyView(
            icon: Icons.inbox_outlined,
            title: 'No signals found',
            message:
                'No signals are available for the selected pair and dates.',
          )
        : null;

    if (status != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
          child: Center(child: status),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
      sliver: SliverList.separated(
        itemCount: archive.signals.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          return _SignalCard(signal: archive.signals[index]);
        },
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({required this.signal});

  final AnalyticSignal signal;

  Color _directionColor(String? direction) {
    final value = direction?.toLowerCase() ?? '';
    if (value == 'buy' || value == 'long') return AppColors.buy;
    if (value == 'sell' || value == 'short') return AppColors.danger;
    return AppColors.line;
  }

  String? _displayTime(AnalyticSignal signal) {
    final date = signal.date?.toLocal();
    if (date == null) return signal.time?.trim();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final direction = signal.direction?.trim();
    final accent = _directionColor(direction);
    final time = _displayTime(signal);
    final note = signal.note?.trim();
    final prices = <String, String>{
      if (signal.openPrice != null && signal.openPrice!.isNotEmpty)
        'Open': signal.openPrice!,
      if (signal.takeProfit != null && signal.takeProfit!.isNotEmpty)
        'Take profit': signal.takeProfit!,
      if (signal.stopLoss != null && signal.stopLoss!.isNotEmpty)
        'Stop loss': signal.stopLoss!,
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4.w, color: accent),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              signal.pair,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (direction != null && direction.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: _directionColor(
                                  direction,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                direction,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _directionColor(direction),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (prices.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 16.w,
                          runSpacing: 8.h,
                          children: [
                            for (final price in prices.entries)
                              _PriceLabel(label: price.key, value: price.value),
                          ],
                        ),
                      ],
                      if (time != null && time.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                      if (note != null && note.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Text(
                          note,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
