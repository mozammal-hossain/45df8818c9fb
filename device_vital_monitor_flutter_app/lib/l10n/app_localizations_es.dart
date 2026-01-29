// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Monitor de Vitales del Dispositivo';

  @override
  String get toggleThemeTooltip => 'Alternar tema claro / oscuro / sistema';

  @override
  String get thermalState => 'Estado térmico';

  @override
  String get thermalStateNone => 'NINGUNO';

  @override
  String get thermalStateLight => 'LEVE';

  @override
  String get thermalStateModerate => 'MODERADO';

  @override
  String get thermalStateSevere => 'GRAVE';

  @override
  String get thermalStateUnknown => 'DESCONOCIDO';

  @override
  String get thermalDescriptionNone =>
      'El sistema opera dentro de rangos de temperatura normales.';

  @override
  String get thermalDescriptionLight =>
      'Temperatura ligeramente elevada, se recomienda monitorear.';

  @override
  String get thermalDescriptionModerate =>
      'Estrés térmico moderado detectado. Considere reducir el uso.';

  @override
  String get thermalDescriptionSevere =>
      'Condición térmica grave. El dispositivo puede limitar rendimiento.';

  @override
  String get thermalDescriptionUnavailable => 'Estado térmico no disponible.';

  @override
  String get loadingThermalState => 'Cargando estado térmico...';

  @override
  String get batteryLevel => 'Nivel de batería';

  @override
  String get batteryStatusHealthy => 'SALUDABLE';

  @override
  String get batteryStatusModerate => 'MODERADO';

  @override
  String get batteryStatusLow => 'BAJO';

  @override
  String get batteryStatusCritical => 'CRÍTICO';

  @override
  String get batteryStatusLoading => 'CARGANDO';

  @override
  String estimatedTimeRemaining(int hours) {
    return 'Aprox. ${hours}h restantes';
  }

  @override
  String deviceHealthLabel(String health) {
    return 'Salud del dispositivo: $health';
  }

  @override
  String chargerLabel(String connection) {
    return 'Cargador: $connection';
  }

  @override
  String statusLabel(String status) {
    return 'Estado: $status';
  }

  @override
  String get batteryHealthGood => 'Buena';

  @override
  String get batteryHealthOverheat => 'Sobrecalentamiento';

  @override
  String get batteryHealthDead => 'Agotada';

  @override
  String get batteryHealthOverVoltage => 'Sobrevoltaje';

  @override
  String get batteryHealthUnspecifiedFailure => 'Fallo no especificado';

  @override
  String get batteryHealthCold => 'Fría';

  @override
  String get chargerAc => 'Cargador AC';

  @override
  String get chargerUsb => 'USB';

  @override
  String get chargerWireless => 'Inalámbrico';

  @override
  String get chargerNone => 'No conectado';

  @override
  String get batteryCharging => 'Cargando';

  @override
  String get batteryDischarging => 'Descargando';

  @override
  String get batteryFull => 'Completa';

  @override
  String get batteryNotCharging => 'No cargando';

  @override
  String get batteryUnknown => 'Desconocido';

  @override
  String get memoryUsage => 'Uso de memoria';

  @override
  String get memoryCritical => 'Crítico';

  @override
  String get memoryHigh => 'Alto';

  @override
  String get memoryModerate => 'Moderado';

  @override
  String get memoryNormal => 'Normal';

  @override
  String get memoryOptimized => 'Optimizado';

  @override
  String get used => 'usado';

  @override
  String get loading => 'cargando…';

  @override
  String get unavailable => 'no disponible';

  @override
  String get dash => '—';

  @override
  String get logStatusSnapshot => 'Registrar instantánea de estado';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyEmpty =>
      'Aún no hay registros. Usa «Registrar estado» en el panel.';

  @override
  String get analyticsTitle => 'Analíticas (ventana móvil)';

  @override
  String get averageThermalLabel => 'Térmico medio';

  @override
  String get averageBatteryLabel => 'Batería media';

  @override
  String get averageMemoryLabel => 'Memoria media';

  @override
  String get totalLogsLabel => 'Total registros';

  @override
  String get rollingWindowLogsLabel => 'Registros en ventana';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get loggingEllipsis => 'Registrando…';

  @override
  String get appSettingsTitle => 'Configuración';

  @override
  String get settingsSubtitle => 'Administra tus preferencias';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageBangla => 'Bengalí';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystemDefault => 'Predeterminado del sistema';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String versionBuild(String version, String build) {
    return 'Versión $version (Compilación $build)';
  }

  @override
  String get autoLoggingLabel => 'Registro automático';

  @override
  String get autoLoggingDescription =>
      'Registrar vitals en el backend cada 15 minutos (en la app y en segundo plano).';
}
