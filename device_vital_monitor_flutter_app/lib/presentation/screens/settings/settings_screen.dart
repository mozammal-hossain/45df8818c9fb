import 'package:flutter/material.dart';

import 'package:device_vital_monitor_flutter_app/core/config/app_config.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/screens/settings/widgets/language_selector.dart';
import 'package:device_vital_monitor_flutter_app/presentation/screens/settings/widgets/theme_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          child: Icon(Icons.show_chart, size: 40, color: scheme.primary),
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
        const LanguageSelector(),
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
        const ThemeSelector(),
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
          l10n.versionBuild(AppConfig.version, AppConfig.build),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
        ),
      ],
    );
  }
}
