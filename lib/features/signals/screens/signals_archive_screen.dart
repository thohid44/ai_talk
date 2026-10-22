import 'package:ai_talk_test/widgets/custom_button.dart';
import 'package:ai_talk_test/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignalItem {
  const SignalItem({
    required this.pair,
    this.direction,
    this.status,
    this.time,
    this.date,
    this.note,
  });

  final String pair;
  final String? direction;
  final String? status;
  final String? time;
  final DateTime? date;
  final String? note;
}

class SignalsArchiveScreen extends StatefulWidget {
  const SignalsArchiveScreen({super.key, this.signals = const []});

  final List<SignalItem> signals;

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
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _filterError;
  bool _isLoading = false;
  bool _hasApplied = false;
  List<SignalItem> _visibleSignals = const [];

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initialDate = isFrom ? (_fromDate ?? now) : (_toDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) return;

    setState(() {
      _filterError = null;
      if (isFrom) {
        _fromDate = picked;
        _fromController.text = _formatDate(picked);
      } else {
        _toDate = picked;
        _toController.text = _formatDate(picked);
      }
    });
  }

  void _applyFilter() {
    if (_isLoading) return;

    if (_fromDate == null || _toDate == null) {
      setState(() => _filterError = 'Select a from date and a to date.');
      return;
    }

    final from = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
    final to = DateTime(_toDate!.year, _toDate!.month, _toDate!.day);
    if (from.isAfter(to)) {
      setState(() => _filterError = 'From date must be on or before to date.');
      return;
    }

    final matched = widget.signals.where((signal) {
      if (signal.pair != _selectedPair) return false;
      final signalDate = signal.date;
      if (signalDate == null) return true;
      final day = DateTime(signalDate.year, signalDate.month, signalDate.day);
      return !day.isBefore(from) && !day.isAfter(to);
    }).toList();

    setState(() {
      _filterError = null;
      _isLoading = false;
      _hasApplied = true;
      _visibleSignals = matched;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Signals Archive')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            Text(
              'Currency pair',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5C6B7A),
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
                      color: _selectedPair == pair ? primary : const Color(0xFFD0D7E2),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _selectedPair == pair ? Colors.white : primary,
                    ),
                    onSelected: (_) => setState(() => _selectedPair = pair),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From date',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5C6B7A),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      CustomTextField(
                        controller: _fromController,
                        hintText: 'Select',
                        readOnly: true,
                        onTap: () => _pickDate(isFrom: true),
                        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To date',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5C6B7A),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      CustomTextField(
                        controller: _toController,
                        hintText: 'Select',
                        readOnly: true,
                        onTap: () => _pickDate(isFrom: false),
                        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_filterError != null) ...[
              SizedBox(height: 8.h),
              Text(
                _filterError!,
                style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.error),
              ),
            ],
            SizedBox(height: 16.h),
            CustomButton(
              width: double.infinity,
              height: 48.h,
              text: _isLoading ? 'Loading...' : 'Load Signals',
              backgroundColor: primary,
              textColor: Colors.white,
              onPressed: _isLoading ? null : _applyFilter,
            ),
            SizedBox(height: 20.h),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (!_hasApplied)
              const _SignalsMessage(
                icon: Icons.filter_alt_outlined,
                title: 'No signals loaded',
                message: 'Choose a currency pair and date range, then load signals.',
              )
            else if (_visibleSignals.isEmpty)
              const _SignalsMessage(
                icon: Icons.inbox_outlined,
                title: 'No signals found',
                message: 'No signals are available for the selected pair and dates.',
              )
            else
              for (final signal in _visibleSignals) ...[
                _SignalCard(signal: signal),
                SizedBox(height: 12.h),
              ],
          ],
        ),
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({required this.signal});

  final SignalItem signal;

  Color _directionColor(String direction) {
    final value = direction.toLowerCase();
    if (value == 'buy' || value == 'long') return const Color(0xFF1B7F4E);
    if (value == 'sell' || value == 'short') return const Color(0xFFC0392B);
    return const Color(0xFF5C6B7A);
  }

  @override
  Widget build(BuildContext context) {
    final direction = signal.direction?.trim();
    final status = signal.status?.trim();
    final time = signal.time?.trim();
    final note = signal.note?.trim();

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
          Row(
            children: [
              Expanded(
                child: Text(
                  signal.pair,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2332),
                  ),
                ),
              ),
              if (direction != null && direction.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _directionColor(direction).withValues(alpha: 0.12),
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
          if (status != null && status.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              'Status',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5C6B7A),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              status,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1A2332)),
            ),
          ],
          if (time != null && time.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              'Time',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5C6B7A),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              time,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1A2332)),
            ),
          ],
          if (note != null && note.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              note,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF5C6B7A),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SignalsMessage extends StatelessWidget {
  const _SignalsMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 12.w),
      child: Column(
        children: [
          Icon(icon, size: 40.sp, color: const Color(0xFF8A97A6)),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
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
        ],
      ),
    );
  }
}
