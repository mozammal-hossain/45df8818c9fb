import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:device_vital_monitor_flutter_app/core/assets/assets.dart';
import 'package:device_vital_monitor_flutter_app/core/config/app_config.dart';
import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
import 'package:device_vital_monitor_flutter_app/core/layout/responsive.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/settings/widgets/language_selector.dart';
import 'package:device_vital_monitor_flutter_app/presentation/settings/widgets/theme_selector.dart';

final _packageInfoFuture = PackageInfo.fromPlatform();

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final padding = AppInsets.pagePadding(context);
    final wide = isWideScreen(context);
    final maxW = AppInsets.settingsMaxWidth(context);

    Widget content = Column(
      children: [
        _buildBranding(context, scheme, l10n),
        SizedBox(height: AppInsets.spacingXL(context)),
        _buildLanguageSection(context, scheme, l10n),
        SizedBox(height: AppInsets.spacingL(context)),
        _buildThemeSection(context, scheme, l10n),
        SizedBox(height: AppInsets.spacingXXL(context)),
        _buildFooter(context, scheme, l10n),
      ],
    );

    if (wide) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Padding(padding: padding, child: content),
        ),
      );
    } else {
      content = Padding(padding: padding, child: content);
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: scheme.primary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
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
      body: SingleChildScrollView(child: content),
    );
  }

  Widget _buildBranding(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    final sz = AppInsets.chartSize(context);
    final r = AppInsets.radiusL(context);
    final sSM = AppInsets.spacingSM(context);
    final sX = AppInsets.spacingXS(context);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(r),
          child: Image.asset(
            Assets.logo,
            width: sz,
            height: sz,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: sSM),
        Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        SizedBox(height: sX),
        Text(
          l10n.settingsSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    final sS = AppInsets.spacingS(context);
    final sSM = AppInsets.spacingSM(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.language, color: scheme.primary, size: 22),
            SizedBox(width: sS),
            Text(
              l10n.languageLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: sSM),
        const LanguageSelector(),
      ],
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    final sS = AppInsets.spacingS(context);
    final sSM = AppInsets.spacingSM(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.palette_outlined, color: scheme.primary, size: 22),
            SizedBox(width: sS),
            Text(
              l10n.themeLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: sSM),
        const ThemeSelector(),
      ],
    );
  }

  Widget _buildFooter(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    final sX = AppInsets.spacingXS(context);
    return Column(
      children: [
        Text(
          'DEVICE VITAL MONITOR',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: sX),
        FutureBuilder<PackageInfo>(
          future: _packageInfoFuture,
          builder: (context, snapshot) {
            final version = snapshot.data?.version ?? AppConfig.version;
            final build = snapshot.data?.buildNumber ?? AppConfig.build;
            return Text(
              l10n.versionBuild(version, build),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            );
          },
        ),
      ],
    );
  }
}
