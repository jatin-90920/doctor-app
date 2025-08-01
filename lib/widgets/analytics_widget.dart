import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? percentage;
  final bool isPositive;
  final VoidCallback? onTap;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.percentage,
    this.isPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  if (percentage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? MdiIcons.trendingUp
                                : MdiIcons.trendingDown,
                            size: 12,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${percentage!.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartWidget extends StatelessWidget {
  final String title;
  final List<ChartData> data;
  final ChartType type;
  final Color primaryColor;
  final double height;

  const ChartWidget({
    super.key,
    required this.title,
    required this.data,
    required this.type,
    required this.primaryColor,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: _buildChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    switch (type) {
      case ChartType.bar:
        return _buildBarChart(context);
      case ChartType.line:
        return _buildLineChart(context);
      case ChartType.pie:
        return _buildPieChart(context);
    }
  }

  Widget _buildBarChart(BuildContext context) {
    if (data.isEmpty) return _buildEmptyChart(context);

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final height = (item.value / maxValue) * 160;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    if (data.isEmpty) return _buildEmptyChart(context);

    return CustomPaint(
      size: Size.infinite,
      painter: LineChartPainter(
        data: data,
        color: primaryColor,
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    if (data.isEmpty) return _buildEmptyChart(context);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomPaint(
            size: const Size(120, 120),
            painter: PieChartPainter(
              data: data,
              primaryColor: primaryColor,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item.color ?? primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      item.value.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.chartLine,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No data available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String label;
  final double value;
  final Color? color;
  final DateTime? date;

  const ChartData({
    required this.label,
    required this.value,
    this.color,
    this.date,
  });
}

enum ChartType { bar, line, pie }

class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color color;

  LineChartPainter({
    required this.data,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final valueRange = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].value - minValue) / valueRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw points
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color primaryColor;

  PieChartPainter({
    required this.data,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final total = data.map((e) => e.value).reduce((a, b) => a + b);

    double startAngle = -90 * (3.14159 / 180); // Start from top

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = data[i].color ?? _generateColor(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  Color _generateColor(int index) {
    final colors = [
      primaryColor,
      primaryColor.withValues(alpha: 0.8),
      primaryColor.withValues(alpha: 0.6),
      primaryColor.withValues(alpha: 0.4),
      primaryColor.withValues(alpha: 0.2),
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnalyticsSummary extends StatelessWidget {
  final Map<String, dynamic> summaryData;

  const AnalyticsSummary({
    super.key,
    required this.summaryData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.chartBox,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Analytics Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...summaryData.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      entry.value.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class DateRangeSelector extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final Function(DateTimeRange?) onRangeChanged;
  final List<String> presetRanges;

  const DateRangeSelector({
    super.key,
    this.selectedRange,
    required this.onRangeChanged,
    this.presetRanges = const ['Today', 'This Week', 'This Month', 'This Year'],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presetRanges.map((range) {
                return FilterChip(
                  label: Text(range),
                  selected: _isRangeSelected(range),
                  onSelected: (selected) {
                    if (selected) {
                      onRangeChanged(_getDateRangeForPreset(range));
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectCustomRange(context),
                    icon: Icon(MdiIcons.calendar),
                    label: Text(
                      selectedRange != null
                          ? '${DateFormat('MMM dd').format(selectedRange!.start)} - ${DateFormat('MMM dd').format(selectedRange!.end)}'
                          : 'Custom Range',
                    ),
                  ),
                ),
                if (selectedRange != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => onRangeChanged(null),
                    icon: Icon(MdiIcons.close),
                    tooltip: 'Clear selection',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isRangeSelected(String range) {
    if (selectedRange == null) return false;
    final presetRange = _getDateRangeForPreset(range);
    return presetRange?.start.day == selectedRange!.start.day &&
           presetRange?.end.day == selectedRange!.end.day;
  }

  DateTimeRange? _getDateRangeForPreset(String preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (preset) {
      case 'Today':
        return DateTimeRange(start: today, end: today);
      case 'This Week':
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return DateTimeRange(start: startOfWeek, end: endOfWeek);
      case 'This Month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        return DateTimeRange(start: startOfMonth, end: endOfMonth);
      case 'This Year':
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year, 12, 31);
        return DateTimeRange(start: startOfYear, end: endOfYear);
      default:
        return null;
    }
  }

  Future<void> _selectCustomRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedRange,
    );
    
    if (range != null) {
      onRangeChanged(range);
    }
  }
}

