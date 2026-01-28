import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/bloc/history/history_bloc.dart';
import 'package:device_vital_monitor_flutter_app/presentation/screens/history/widgets/analytics_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/screens/history/widgets/vital_log_item.dart';
import 'package:device_vital_monitor_flutter_app/presentation/widgets/common/error_view.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _scrollController = ScrollController();
  static const _loadMoreThreshold = 200.0;

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
      appBar: AppBar(title: Text(l10n.historyTitle)),
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
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HistoryBloc>().add(const HistoryRequested());
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.analytics != null) ...[
                          AnalyticsCard(analytics: state.analytics!),
                          const SizedBox(height: 24),
                        ],
                        Text(l10n.historyTitle, style: textTheme.titleLarge),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (state.logs.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.builder(
                      itemCount: state.logs.length,
                      itemBuilder: (context, index) =>
                          VitalLogItem(log: state.logs[index]),
                    ),
                  ),
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )),
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
