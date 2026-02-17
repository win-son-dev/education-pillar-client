import 'package:flutter/material.dart';
import 'package:education/data/bookings/booking.dart';

// ── Constants ──────────────────────────────────────────────────────────────────

const _kHourHeight = 100.0;
const _kGutterWidth = 52.0;
const _kDayHeaderHeight = 48.0;

const _kWeekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
const _kMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

// ── Helpers ────────────────────────────────────────────────────────────────────

/// Parses "9 AM", "12 PM" etc. into fractional hour 0–24.
double _parseHour(String time) {
  final parts = time.trim().split(' ');
  final hour = int.tryParse(parts[0]) ?? 0;
  final isPm = parts.length > 1 && parts[1].toUpperCase() == 'PM';
  if (hour == 12) return isPm ? 12.0 : 0.0;
  return isPm ? hour + 12.0 : hour.toDouble();
}

String _formatHour(int hour) {
  if (hour == 0 || hour == 24) return '12am';
  if (hour == 12) return '12pm';
  if (hour < 12) return '${hour}am';
  return '${hour - 12}pm';
}

Color _statusColor(BookingStatus status) {
  switch (status) {
    case BookingStatus.confirmed:
      return Colors.green;
    case BookingStatus.pending:
      return Colors.orange;
    case BookingStatus.completed:
      return Colors.grey;
    case BookingStatus.cancelled:
      return Colors.red;
  }
}

DateTime _weekStart(DateTime day) {
  // Monday-based week start (DateTime weekday: Mon=1..Sun=7)
  final diff = day.weekday - 1;
  return DateTime(day.year, day.month, day.day - diff);
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// ── View mode ──────────────────────────────────────────────────────────────────

enum _ViewMode { week, month, agenda }

// ── Main widget ────────────────────────────────────────────────────────────────

class BookingCalendarView extends StatefulWidget {
  final List<Booking> bookings;
  final ThemeData theme;
  final void Function(Booking booking)? onCancel;
  final void Function(Booking booking, DateTime newDate, String newStartTime, String newEndTime)? onReschedule;

  const BookingCalendarView({
    super.key,
    required this.bookings,
    required this.theme,
    this.onCancel,
    this.onReschedule,
  });

  @override
  State<BookingCalendarView> createState() => _BookingCalendarViewState();
}

class _BookingCalendarViewState extends State<BookingCalendarView> {
  _ViewMode _viewMode = _ViewMode.week;
  late DateTime _weekStartDate;
  late DateTime _monthDate; // any day in the displayed month
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStartDate = _weekStart(now);
    _monthDate = DateTime(now.year, now.month);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToNow() {
    if (!_scrollController.hasClients) return;
    final now = TimeOfDay.now();
    final offset = ((now.hour - 1).clamp(0, 23)) * _kHourHeight;
    _scrollController.jumpTo(offset.clamp(0.0, _scrollController.position.maxScrollExtent));
  }

  List<Booking> _bookingsForDay(DateTime day) {
    return widget.bookings.where((b) => _sameDay(b.date, day)).toList()
      ..sort((a, b) => _parseHour(a.startTime).compareTo(_parseHour(b.startTime)));
  }

  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekStartDate.add(Duration(days: i)));

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _weekStartDate = _weekStart(now);
      _monthDate = DateTime(now.year, now.month);
    });
    if (_viewMode == _ViewMode.week) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
    }
  }

  void _goPrev() {
    setState(() {
      if (_viewMode == _ViewMode.week) {
        _weekStartDate = _weekStartDate.subtract(const Duration(days: 7));
      } else {
        _monthDate = DateTime(_monthDate.year, _monthDate.month - 1);
        _weekStartDate = _weekStart(_monthDate);
      }
    });
  }

  void _goNext() {
    setState(() {
      if (_viewMode == _ViewMode.week) {
        _weekStartDate = _weekStartDate.add(const Duration(days: 7));
      } else {
        _monthDate = DateTime(_monthDate.year, _monthDate.month + 1);
        _weekStartDate = _weekStart(_monthDate);
      }
    });
  }

  String get _headerTitle {
    final days = _weekDays;
    final start = days.first;
    final end = days.last;
    if (_viewMode == _ViewMode.month || _viewMode == _ViewMode.agenda) {
      return '${_kMonths[_monthDate.month - 1]} ${_monthDate.year}';
    }
    if (start.month == end.month) {
      return '${_kMonths[start.month - 1]} ${start.day} — ${end.day}, ${start.year}';
    }
    return '${_kMonths[start.month - 1]} ${start.day} — ${_kMonths[end.month - 1]} ${end.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        const Divider(height: 1),
        Expanded(
          child: switch (_viewMode) {
            _ViewMode.week => _buildWeekView(),
            _ViewMode.month => _buildMonthView(),
            _ViewMode.agenda => _buildAgendaView(),
          },
        ),
      ],
    );
  }

  // ── Toolbar (Canvas-style) ─────────────────────────────────────────────────

  Widget _buildToolbar() {
    final t = widget.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          // Top row: Today, nav arrows, title
          Row(
            children: [
              OutlinedButton(
                onPressed: _goToday,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  side: BorderSide(color: t.colorScheme.outline),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text('Today', style: t.textTheme.labelMedium),
              ),
              IconButton(
                onPressed: _goPrev,
                icon: const Icon(Icons.chevron_left, size: 20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                onPressed: _goNext,
                icon: const Icon(Icons.chevron_right, size: 20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _headerTitle,
                  style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Bottom row: view mode toggle
          Align(
            alignment: Alignment.centerRight,
            child: SegmentedButton<_ViewMode>(
              segments: const [
                ButtonSegment(value: _ViewMode.week, label: Text('Week')),
                ButtonSegment(value: _ViewMode.month, label: Text('Month')),
                ButtonSegment(value: _ViewMode.agenda, label: Text('Agenda')),
              ],
              selected: {_viewMode},
              onSelectionChanged: (s) => setState(() => _viewMode = s.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                textStyle: WidgetStateProperty.all(t.textTheme.labelSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Week view ──────────────────────────────────────────────────────────────

  Widget _buildWeekView() {
    final days = _weekDays;
    final now = DateTime.now();
    final isCurrentWeek = days.any((d) => _sameDay(d, now));

    return Column(
      children: [
        // Day column headers
        _DayHeaderRow(days: days, theme: widget.theme),
        const Divider(height: 1),
        // Scrollable hour grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dayWidth = (constraints.maxWidth - _kGutterWidth) / 7;
              const totalHeight = 24 * _kHourHeight;

              return SingleChildScrollView(
                controller: _scrollController,
                child: SizedBox(
                  height: totalHeight,
                  child: Stack(
                    children: [
                      // Hour grid lines + time labels
                      for (int h = 0; h < 24; h++) ...[
                        // Time label
                        Positioned(
                          top: h * _kHourHeight - 7,
                          left: 0,
                          width: _kGutterWidth - 4,
                          child: Text(
                            _formatHour(h),
                            textAlign: TextAlign.right,
                            style: widget.theme.textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              color: widget.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        // Horizontal line
                        Positioned(
                          top: h * _kHourHeight,
                          left: _kGutterWidth,
                          right: 0,
                          child: Container(
                            height: 0.5,
                            color: widget.theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                      // Vertical day separators
                      for (int d = 0; d <= 7; d++)
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: _kGutterWidth + d * dayWidth,
                          child: Container(
                            width: 0.5,
                            color: widget.theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      // Current time indicator
                      if (isCurrentWeek)
                        _CurrentTimeIndicator(
                          theme: widget.theme,
                          dayWidth: dayWidth,
                          todayIndex: days.indexWhere((d) => _sameDay(d, now)),
                        ),
                      // Events
                      for (int d = 0; d < 7; d++)
                        for (final b in _bookingsForDay(days[d]))
                          _PositionedEventBlock(
                            booking: b,
                            theme: widget.theme,
                            left: _kGutterWidth + d * dayWidth + 2,
                            width: dayWidth - 4,
                            onTap: () => _showActionsSheet(context, b),
                          ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Month view ─────────────────────────────────────────────────────────────

  Widget _buildMonthView() {
    final firstOfMonth = DateTime(_monthDate.year, _monthDate.month, 1);
    final startWeekday = firstOfMonth.weekday - 1; // Mon=0
    final daysInMonth = DateUtils.getDaysInMonth(_monthDate.year, _monthDate.month);
    final gridStart = firstOfMonth.subtract(Duration(days: startWeekday));
    final totalCells = ((startWeekday + daysInMonth + 6) ~/ 7) * 7;
    final now = DateTime.now();

    return Column(
      children: [
        // Day-of-week header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: _kWeekdays.map((d) => Expanded(
              child: Center(
                child: Text(d, style: widget.theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.theme.colorScheme.onSurfaceVariant,
                )),
              ),
            )).toList(),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final day = gridStart.add(Duration(days: index));
              final isCurrentMonth = day.month == _monthDate.month;
              final isToday = _sameDay(day, now);
              final dayBookings = _bookingsForDay(day);

              return InkWell(
                onTap: () {
                  setState(() {
                    _weekStartDate = _weekStart(day);
                    _viewMode = _ViewMode.week;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date number
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: isToday
                            ? BoxDecoration(
                                color: widget.theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              )
                            : null,
                        child: Text(
                          '${day.day}',
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            fontWeight: isToday ? FontWeight.bold : null,
                            color: isToday
                                ? Colors.white
                                : isCurrentMonth
                                    ? null
                                    : widget.theme.colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      // Event indicators
                      ...dayBookings.take(3).map((b) => Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: _statusColor(b.status),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Agenda view ────────────────────────────────────────────────────────────

  Widget _buildAgendaView() {
    // Show upcoming bookings sorted by date then time
    final upcoming = widget.bookings.toList()
      ..sort((a, b) {
        final cmp = a.date.compareTo(b.date);
        if (cmp != 0) return cmp;
        return _parseHour(a.startTime).compareTo(_parseHour(b.startTime));
      });

    if (upcoming.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available, size: 40, color: widget.theme.colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              'No sessions scheduled',
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                color: widget.theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: upcoming.length,
      itemBuilder: (context, index) {
        final b = upcoming[index];
        final showDateHeader = index == 0 || !_sameDay(upcoming[index - 1].date, b.date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) ...[
              if (index > 0) const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _formatDate(b.date),
                  style: widget.theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            _AgendaEventTile(
              booking: b,
              theme: widget.theme,
              onTap: () => _showActionsSheet(context, b),
            ),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime day) {
    final now = DateTime.now();
    if (_sameDay(day, now)) return 'Today';
    final tomorrow = now.add(const Duration(days: 1));
    if (_sameDay(day, tomorrow)) return 'Tomorrow';
    return '${_kWeekdays[day.weekday - 1]}, ${_kMonths[day.month - 1]} ${day.day}';
  }

  // ── Actions sheet ──────────────────────────────────────────────────────────

  void _showActionsSheet(BuildContext context, Booking booking) {
    final isActive = booking.status == BookingStatus.pending || booking.status == BookingStatus.confirmed;
    if (!isActive) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _statusColor(booking.status),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tutor ${booking.tutorId}', style: widget.theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        Text('${booking.startTime} – ${booking.endTime}', style: widget.theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  BookingStatusChip(status: booking.status, theme: widget.theme),
                ],
              ),
            ),
            const Divider(height: 1),
            if (widget.onReschedule != null)
              ListTile(
                leading: const Icon(Icons.edit_calendar),
                title: const Text('Reschedule'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showRescheduleDialog(context, booking);
                },
              ),
            if (widget.onCancel != null)
              ListTile(
                leading: Icon(Icons.cancel, color: widget.theme.colorScheme.error),
                title: Text('Cancel Booking', style: TextStyle(color: widget.theme.colorScheme.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCancelDialog(context, booking);
                },
              ),
          ],
        ),
      ),
    );
  }

  static const _timeSlots = ['9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM', '6 PM', '7 PM'];

  void _showRescheduleDialog(BuildContext context, Booking booking) {
    var selectedDate = booking.date;
    var selectedStartTime = booking.startTime;

    String endTimeFor(String start) {
      final idx = _timeSlots.indexOf(start);
      if (idx >= 0 && idx < _timeSlots.length - 1) return _timeSlots[idx + 1];
      return booking.endTime;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Reschedule Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pick a new date and time', style: widget.theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setDialogState(() => selectedDate = date);
                  }
                },
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _timeSlots.contains(selectedStartTime) ? selectedStartTime : _timeSlots.first,
                decoration: const InputDecoration(
                  labelText: 'Start time',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _timeSlots.where((t) => _timeSlots.indexOf(t) < _timeSlots.length - 1).map((t) =>
                  DropdownMenuItem(value: t, child: Text(t)),
                ).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedStartTime = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onReschedule?.call(booking, selectedDate, selectedStartTime, endTimeFor(selectedStartTime));
              },
              child: const Text('Reschedule'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onCancel?.call(booking);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

// ── Day column header row ────────────────────────────────────────────────────

class _DayHeaderRow extends StatelessWidget {
  final List<DateTime> days;
  final ThemeData theme;

  const _DayHeaderRow({required this.days, required this.theme});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return SizedBox(
      height: _kDayHeaderHeight,
      child: Row(
        children: [
          // Gutter space
          const SizedBox(width: _kGutterWidth),
          // Day headers
          for (final day in days)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${day.day}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _sameDay(day, now) ? theme.colorScheme.primary : null,
                      ),
                    ),
                    Text(
                      _kWeekdays[day.weekday - 1],
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: _sameDay(day, now)
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Current time red line ────────────────────────────────────────────────────

class _CurrentTimeIndicator extends StatelessWidget {
  final ThemeData theme;
  final double dayWidth;
  final int todayIndex;

  const _CurrentTimeIndicator({
    required this.theme,
    required this.dayWidth,
    required this.todayIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (todayIndex < 0) return const SizedBox.shrink();
    final now = TimeOfDay.now();
    final top = (now.hour + now.minute / 60.0) * _kHourHeight;
    final left = _kGutterWidth + todayIndex * dayWidth;

    return Positioned(
      top: top,
      left: left - 4,
      width: dayWidth + 8,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: Container(height: 2, color: theme.colorScheme.error)),
        ],
      ),
    );
  }
}

// ── Positioned event block (week view) ───────────────────────────────────────

class _PositionedEventBlock extends StatelessWidget {
  final Booking booking;
  final ThemeData theme;
  final double left;
  final double width;
  final VoidCallback onTap;

  const _PositionedEventBlock({
    required this.booking,
    required this.theme,
    required this.left,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startH = _parseHour(booking.startTime);
    final endH = _parseHour(booking.endTime);
    final duration = (endH - startH).clamp(0.5, 24.0);
    final top = startH * _kHourHeight + 1;
    final height = duration * _kHourHeight - 2;
    final color = _statusColor(booking.status);

    return Positioned(
      top: top,
      left: left,
      width: width,
      height: height,
      child: Material(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking.startTime} - ${booking.endTime}',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Tutor ${booking.tutorId}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Agenda event tile ────────────────────────────────────────────────────────

class _AgendaEventTile extends StatelessWidget {
  final Booking booking;
  final ThemeData theme;
  final VoidCallback onTap;

  const _AgendaEventTile({
    required this.booking,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(booking.status);
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.startTime, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                    Text(booking.endTime, style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant, fontSize: 11,
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tutor ${booking.tutorId}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              BookingStatusChip(status: booking.status, theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status chip ──────────────────────────────────────────────────────────────

class BookingStatusChip extends StatelessWidget {
  final BookingStatus status;
  final ThemeData theme;

  const BookingStatusChip({super.key, required this.status, required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
