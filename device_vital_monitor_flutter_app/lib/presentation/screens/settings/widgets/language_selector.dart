import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/bloc/settings/locale/locale_bloc.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final gap = AppInsets.spacingS(context);
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        final current = state.locale?.languageCode ??
            Localizations.localeOf(context).languageCode;
        return Column(
          children: [
            _SelectOptionTile<String?>(
              value: 'bn',
              groupValue: current,
              label: l10n.languageBangla,
              onChanged: (_) {
                context
                    .read<LocaleBloc>()
                    .add(LocaleChanged(const Locale('bn')));
              },
              scheme: scheme,
            ),
            SizedBox(height: gap),
            _SelectOptionTile<String?>(
              value: 'en',
              groupValue: current,
              label: l10n.languageEnglish,
              onChanged: (_) {
                context
                    .read<LocaleBloc>()
                    .add(LocaleChanged(const Locale('en')));
              },
              scheme: scheme,
            ),
          ],
        );
      },
    );
  }
}

class _SelectOptionTile<T> extends StatelessWidget {
  const _SelectOptionTile({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
    required this.scheme,
    this.leading,
  });

  final T value;
  final T groupValue;
  final String label;
  final ValueChanged<T?> onChanged;
  final ColorScheme scheme;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    final r = AppInsets.radiusM(context);
    final padH = AppInsets.spacingM(context);
    final padV = 14.0;
    final gap = AppInsets.spacingSM(context);
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(r),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: gap),
              ],
              Expanded(
                child: Text(
                  label,
                  style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Radio<T>(
                value: value,
                // ignore: deprecated_member_use
                groupValue: groupValue,
                // ignore: deprecated_member_use
                onChanged: onChanged,
                activeColor: scheme.primary,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return scheme.primary;
                  }
                  return scheme.outline;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
