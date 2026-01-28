import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/domain/entities/paged_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/vitals_repository.dart';

@injectable
class GetHistoryUsecase {
  GetHistoryUsecase(this._vitalsRepository);

  final VitalsRepository _vitalsRepository;

  Future<PagedResult<VitalLog>> call({
    int page = 1,
    int pageSize = 20,
  }) =>
      _vitalsRepository.getHistoryPage(page: page, pageSize: pageSize);
}
