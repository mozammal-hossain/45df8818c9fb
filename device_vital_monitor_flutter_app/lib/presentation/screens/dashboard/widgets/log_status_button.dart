import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/bloc/dashboard/dashboard_bloc.dart'
    show DashboardBloc, DashboardState, DashboardLoaded, LogStatusState,
        DashboardLogStatusRequested;

class LogStatusButton extends StatelessWidget {
  const LogStatusButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (a, b) {
        if (a is DashboardLoaded && b is DashboardLoaded) {
          return a.logStatus != b.logStatus;
        }
        return a != b;
      },
      builder: (context, state) {
        final isSubmitting = state is DashboardLoaded &&
            state.logStatus == LogStatusState.submitting;
        final iconSz = AppInsets.iconS(context);
        return FilledButton.icon(
          onPressed: isSubmitting
              ? null
              : () {
                  context
                      .read<DashboardBloc>()
                      .add(const DashboardLogStatusRequested());
                },
          icon: isSubmitting
              ? SizedBox(
                  width: iconSz,
                  height: iconSz,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.bar_chart),
          label: Text(
            isSubmitting ? l10n.loggingEllipsis : l10n.logStatusSnapshot,
          ),
        );
      },
    );
  }
}
