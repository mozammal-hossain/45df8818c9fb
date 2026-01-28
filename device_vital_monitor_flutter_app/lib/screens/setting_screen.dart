import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/locale/locale_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../l10n/app_localizations.dart';

/// App version and build for display. Update to match pubspec or use package_info_plus.
const String kAppVersion = '1.0.0';
const String kAppBuild = '1';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.appSettingsTitle,
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: scheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _buildBranding(context, scheme, l10n),
            const SizedBox(height: 32),
            _buildLanguageSection(context, scheme, l10n),
            const SizedBox(height: 24),
            _buildThemeSection(context, scheme, l10n),
            const SizedBox(height: 48),
            _buildFooter(context, scheme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildBranding(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.show_chart,
            size: 40,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.settingsSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.language, color: scheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              l10n.languageLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, state) {
            // Use override locale, or current app locale when following system
            final current = state.locale?.languageCode ??
                Localizations.localeOf(context).languageCode;
            return Column(
              children: [
                _SelectOptionTile<String?>(
                  value: 'bn',
                  groupValue: current,
                  label: l10n.languageBangla,
                  onChanged: (v) {
                    context.read<LocaleBloc>().add(LocaleChanged(const Locale('bn')));
                  },
                  scheme: scheme,
                ),
                const SizedBox(height: 8),
                _SelectOptionTile<String?>(
                  value: 'en',
                  groupValue: current,
                  label: l10n.languageEnglish,
                  onChanged: (v) {
                    context.read<LocaleBloc>().add(LocaleChanged(const Locale('en')));
                  },
                  scheme: scheme,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.palette_outlined, color: scheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              l10n.themeLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            final mode = state.mode;
            return Column(
              children: [
                _SelectOptionTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: mode,
                  label: l10n.themeLight,
                  leading: Icon(Icons.light_mode_outlined, size: 20, color: scheme.onSurface),
                  onChanged: (v) {
                    context.read<ThemeBloc>().add(ThemeModeChanged(ThemeMode.light));
                  },
                  scheme: scheme,
                ),
                const SizedBox(height: 8),
                _SelectOptionTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: mode,
                  label: l10n.themeDark,
                  leading: Icon(Icons.dark_mode_outlined, size: 20, color: scheme.onSurface),
                  onChanged: (v) {
                    context.read<ThemeBloc>().add(ThemeModeChanged(ThemeMode.dark));
                  },
                  scheme: scheme,
                ),
                const SizedBox(height: 8),
                _SelectOptionTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: mode,
                  label: l10n.themeSystemDefault,
                  leading: Icon(Icons.settings_suggest_outlined, size: 20, color: scheme.onSurface),
                  onChanged: (v) {
                    context.read<ThemeBloc>().add(ThemeModeChanged(ThemeMode.system));
                  },
                  scheme: scheme,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        Text(
          'DEVICE VITAL MONITOR',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.versionBuild(kAppVersion, kAppBuild),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
        ),
      ],
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
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: scheme.primary,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return scheme.primary;
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
