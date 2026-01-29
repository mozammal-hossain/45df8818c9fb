import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/common/widgets/error_view.dart';
import 'package:device_vital_monitor_flutter_app/presentation/history/bloc/history_bloc.dart';
import 'package:device_vital_monitor_flutter_app/presentation/history/widgets/analytics_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/history/widgets/vital_log_item.dart';

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
          _loadMoreThreshold = AppInsets.loadMoreThreshold(context);
          final padding = AppInsets.pagePadding(context);
          final sL = AppInsets.spacingL(context);
          final sSM = AppInsets.spacingSM(context);
          final loaderSize = AppInsets.iconS(context);
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
                          AnalyticsCard(analytics: state.analytics!),
                          SizedBox(height: sL),
                        ],
                        Text(l10n.historyTitle, style: textTheme.titleLarge),
                        SizedBox(height: sSM),
                      ],
                    ),
                  ),
                ),
                if (state.logs.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.only(left: padding.left, right: padding.right),
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
                    padding: EdgeInsets.only(left: padding.left, right: padding.right),
                    sliver: SliverList.builder(
                      itemCount: state.logs.length,
                      itemBuilder: (context, index) =>
                          VitalLogItem(log: state.logs[index]),
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
                          child: const CircularProgressIndicator(strokeWidth: 2),
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
