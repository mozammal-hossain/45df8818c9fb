import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/common/widgets/error_view.dart';
import 'package:device_vital_monitor_flutter_app/presentation/history/bloc/history_bloc.dart';
import 'package:device_vital_monitor_flutter_app/presentation/history/widgets/analytics_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/history/widgets/vital_log_item.dart';

/// Section label and logs for one day (e.g. "Today", "Yesterday", or formatted date).
class _HistorySection {
  const _HistorySection({required this.label, required this.logs});
  final String label;
  final List<VitalLog> logs;
}

/// Groups [logs] by local date into "Today", "Yesterday", or a formatted date.
List<_HistorySection> _groupLogsByDay(List<VitalLog> logs) {
  if (logs.isEmpty) return [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateFormat = DateFormat('MMM d');

  final map = <DateTime, List<VitalLog>>{};
  for (final log in logs) {
    final local = log.timestamp.isUtc ? log.timestamp.toLocal() : log.timestamp;
    final day = DateTime(local.year, local.month, local.day);
    map.putIfAbsent(day, () => []).add(log);
  }

  final orderedDays = map.keys.toList()..sort((a, b) => b.compareTo(a));
  final sections = <_HistorySection>[];
  for (final day in orderedDays) {
    final dayLogs = map[day]!;
    dayLogs.sort((a, b) {
      final ta = a.timestamp.isUtc ? a.timestamp.toLocal() : a.timestamp;
      final tb = b.timestamp.isUtc ? b.timestamp.toLocal() : b.timestamp;
      return tb.compareTo(ta);
    });
    final label = day == today
        ? 'TODAY'
        : day == yesterday
        ? 'YESTERDAY'
        : dateFormat.format(day).toUpperCase();
    sections.add(_HistorySection(label: label, logs: dayLogs));
  }
  return sections;
}

/// Thermal values 0–1 for sparkline (oldest to newest, left to right). From [logs] newest-first, take up to [maxPoints].
List<double> _thermalSparklineValues(
  List<VitalLog> logs, {
  int maxPoints = 24,
}) {
  if (logs.isEmpty) return [];
  final take = logs.take(maxPoints).map((l) => l.thermalValue / 3.0).toList();
  return take.reversed.toList();
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _scrollController = ScrollController();
  double _loadMoreThreshold = 200;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final bloc = context.read<HistoryBloc>();
    final state = bloc.state;
    if (!state.hasNextPage || state.isLoadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - _loadMoreThreshold) {
      bloc.add(const HistoryLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      appBar: AppBar(title: Text(l10n.detailedHistoryTitle)),
      body: BlocConsumer<HistoryBloc, HistoryState>(
        listener: (context, state) {
          if (state.status == HistoryStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: scheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == HistoryStatus.initial ||
              state.status == HistoryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == HistoryStatus.failure && state.logs.isEmpty) {
            return ErrorView(
              message: state.errorMessage ?? 'Could not load history.',
              onRetry: () =>
                  context.read<HistoryBloc>().add(const HistoryRequested()),
            );
          }
          _loadMoreThreshold = AppInsets.loadMoreThreshold(context);
          final padding = AppInsets.pagePadding(context);
          final sL = AppInsets.spacingL(context);
          final sSM = AppInsets.spacingSM(context);
          final loaderSize = AppInsets.iconS(context);
          final sections = _groupLogsByDay(state.logs);
          final thermalSparkline = _thermalSparklineValues(state.logs);

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HistoryBloc>().add(const HistoryRequested());
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: padding,
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.analytics != null) ...[
                          AnalyticsCard(
                            analytics: state.analytics!,
                            thermalSparklineValues: thermalSparkline,
                          ),
                          SizedBox(height: sL),
                        ],
                        Text(
                          l10n.historyTitle,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: sSM),
                      ],
                    ),
                  ),
                ),
                if (state.logs.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: padding.left,
                      right: padding.right,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: sL),
                        child: Text(
                          l10n.historyEmpty,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: padding.left,
                      right: padding.right,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var offset = 0;
                          for (var i = 0; i < sections.length; i++) {
                            final section = sections[i];
                            final sectionSize = 1 + section.logs.length;
                            if (index >= offset &&
                                index < offset + sectionSize) {
                              final local = index - offset;
                              if (local == 0) {
                                final label = section.label == 'TODAY'
                                    ? l10n.sectionToday.toUpperCase()
                                    : section.label == 'YESTERDAY'
                                    ? l10n.sectionYesterday.toUpperCase()
                                    : section.label;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: i == 0 ? 0 : sL,
                                    bottom: sSM,
                                  ),
                                  child: Text(
                                    label,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }
                              return VitalLogItem(log: section.logs[local - 1]);
                            }
                            offset += sectionSize;
                          }
                          return null;
                        },
                        childCount: sections.fold<int>(
                          0,
                          (sum, s) => sum + 1 + s.logs.length,
                        ),
                      ),
                    ),
                  ),
                if (state.isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: padding,
                      child: Center(
                        child: SizedBox(
                          height: loaderSize,
                          width: loaderSize,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
