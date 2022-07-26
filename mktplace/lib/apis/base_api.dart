import 'package:server_shelf/di/dependency_injector.dart';
import 'package:server_shelf/infra/security_service.dart';
import 'package:shelf/shelf.dart';

abstract class BaseApi {
  /// Returns the Handler of an API
  ///
  /// [middlewares] is optional.
  /// If this [middlewares] is not declared, then it will be initialized as an empty list.
  ///
  /// If [isProtected] is true, the API will only have access if it is authenticated.
  /// If [isProtected] is false, the API is public
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isProtected = true,
  });

  Handler createHandler({
    required Handler router,
    required bool isProtected,
    List<Middleware>? middlewares,
  }) {
    middlewares ??= [];

    if (isProtected) {
      final securityService = DependencyInjector().get<SecurityService>();

      middlewares.addAll([
        securityService.authorization,
        securityService.verifyJwt,
      ]);
    }

    var pipeline = Pipeline();

    for (var middleware in middlewares) {
      pipeline = pipeline.addMiddleware((middleware));
    }

    return pipeline.addHandler(router);
  }
}
