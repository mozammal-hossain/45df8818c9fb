import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/vitals_repository.dart';

@injectable
class GetHistoryUsecase {
  GetHistoryUsecase(this._vitalsRepository);

  final VitalsRepository _vitalsRepository;

  Future<List<VitalLog>> call() => _vitalsRepository.getHistory();
}
