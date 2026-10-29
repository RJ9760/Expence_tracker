import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:expence/src/features/expenses/domain/entities/chart_bucket.dart';

class ExpenseBarChart extends StatelessWidget {
  const ExpenseBarChart({
    super.key,
    required this.buckets,
    required this.currency,
    this.height = 230,
  });

  final List<ChartBucket> buckets;
  final String currency;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = buckets.fold<double>(0, (m, b) => max(m, b.value));
    final maxY = maxValue == 0 ? 100.0 : maxValue * 1.3;
    final interval = maxY / 4;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (v) => FlLine(
              color: theme.dividerColor.withValues(alpha: 0.35),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    _compact(value),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: theme.hintColor,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= buckets.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      buckets[i].label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.hintColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => theme.colorScheme.inverseSurface,
              tooltipBorderRadius: BorderRadius.circular(10),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final bucket = buckets[group.x];
                return BarTooltipItem(
                  '${bucket.fullLabel}\n',
                  TextStyle(
                    color: theme.colorScheme.onInverseSurface,
                    fontSize: 11,
                  ),
                  children: [
                    TextSpan(
                      text: '$currency${rod.toY.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: theme.colorScheme.onInverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: List.generate(buckets.length, (i) {
            final isCurrent = i == buckets.length - 1;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: buckets[i].value,
                  width: buckets.length > 9 ? 10 : 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: isCurrent
                        ? [
                            theme.colorScheme.primary.withValues(alpha: 0.55),
                            theme.colorScheme.primary,
                          ]
                        : [
                            theme.colorScheme.primary.withValues(alpha: 0.22),
                            theme.colorScheme.primary.withValues(alpha: 0.55),
                          ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _compact(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}
