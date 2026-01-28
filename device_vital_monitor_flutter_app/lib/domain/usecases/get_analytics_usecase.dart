import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/domain/entities/analytics_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/vitals_repository.dart';

@injectable
class GetAnalyticsUsecase {
  GetAnalyticsUsecase(this._vitalsRepository);

  final VitalsRepository _vitalsRepository;

  Future<AnalyticsResult> call() => _vitalsRepository.getAnalytics();
}
