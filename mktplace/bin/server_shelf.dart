import 'package:server_shelf/apis/login_api.dart';
import 'package:server_shelf/di/injector.dart';
import 'package:server_shelf/infra/custom_server.dart';
import 'package:server_shelf/infra/middleware_interceptor.dart';
import 'package:server_shelf/utils/custom_env.dart';
import 'package:shelf/shelf.dart';

void main() async {
  final di = Injector.initialize();
  final cascadeHandler = Cascade() //
      .add(di.get<LoginApi>().getHandler())
      // .add(di.get<CrudApi>().getHandler())
      .handler;

  final handler = Pipeline() //
      .addMiddleware(logRequests())
      .addMiddleware(MiddlewareInterceptor().middleware)
      .addHandler(cascadeHandler);

  CustomEnv.fromEnv('test');

  await CustomServer().initializeServer(
    address: await CustomEnv.get<String>(key: 'server_address'),
    port: await CustomEnv.get<int>(key: 'server_port'),
    handler: handler,
  );
}
