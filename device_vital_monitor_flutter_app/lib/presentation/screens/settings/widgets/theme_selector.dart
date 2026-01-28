import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/bloc/settings/theme/theme_bloc.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final mode = state.mode;
        return Column(
          children: [
            _SelectOptionTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: mode,
              label: l10n.themeLight,
              leading: Icon(
                Icons.light_mode_outlined,
                size: 20,
                color: scheme.onSurface,
              ),
              onChanged: (_) {
                context
                    .read<ThemeBloc>()
                    .add(ThemeModeChanged(ThemeMode.light));
              },
              scheme: scheme,
            ),
            const SizedBox(height: 8),
            _SelectOptionTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: mode,
              label: l10n.themeDark,
              leading: Icon(
                Icons.dark_mode_outlined,
                size: 20,
                color: scheme.onSurface,
              ),
              onChanged: (_) {
                context
                    .read<ThemeBloc>()
                    .add(ThemeModeChanged(ThemeMode.dark));
              },
              scheme: scheme,
            ),
            const SizedBox(height: 8),
            _SelectOptionTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: mode,
              label: l10n.themeSystemDefault,
              leading: Icon(
                Icons.settings_suggest_outlined,
                size: 20,
                color: scheme.onSurface,
              ),
              onChanged: (_) {
                context
                    .read<ThemeBloc>()
                    .add(ThemeModeChanged(ThemeMode.system));
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
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
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
