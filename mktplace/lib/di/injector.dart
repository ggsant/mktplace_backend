import 'package:server_shelf/apis/login_api.dart';
import 'package:server_shelf/infra/security_service.dart';

import 'dependency_injector.dart';

class Injector {
  static DependencyInjector initialize() {
    final di = DependencyInjector();

    di.registerFactory<SecurityService>(() => SecurityServiceImpl());

    di.registerFactory<LoginApi>(() => LoginApi(di<SecurityService>()));

    return di;
  }
}
