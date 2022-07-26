import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../utils/custom_env.dart';

abstract class SecurityService<T> {
  Future<String> generateJwt(String userId);
  Future<T?> validateJwt(String token);
  Middleware get verifyJwt;
  Middleware get authorization;
}

class SecurityServiceImpl implements SecurityService<JWT> {
  @override
  Future<String> generateJwt(String userId) async {
    final payload = {
      'iat': DateTime.now().millisecondsSinceEpoch,
      'userId': userId,
      'roles': ['adm', 'user'],
    };

    final jwt = JWT(payload);

    final token = jwt.sign(SecretKey(await CustomEnv.get<String>(key: 'jwt_key')));

    print('Signed token: $token\n');
    return token;
  }

  @override
  Future<JWT?> validateJwt(String token) async {
    try {
      final jwt = JWT.verify(token, SecretKey(await CustomEnv.get<String>(key: 'jwt_key')));
      print('Payload: ${jwt.payload}');
      return jwt;
    } on JWTExpiredError {
      print('jwt expired');
      return null;
    } on JWTNotActiveError {
      print('jwt NotActive');
      return null;
    } on JWTUndefinedError {
      print('jwt Undefined');
      return null;
    } on JWTError catch (ex) {
      print(ex.message);
      return null;
    }
  }

  @override
  Middleware get authorization {
    return (Handler handler) {
      return (Request request) async {
        final String? authorizationHeader = request.headers['Authorization'];

        JWT? jwt;

        if (authorizationHeader != null) {
          if (authorizationHeader.startsWith('Bearer ')) {
            final token = authorizationHeader.substring(7);
            jwt = await validateJwt(token);
          }
        }

        final newRequest = request.change(
          context: {'jwt': jwt},
        );

        return handler(newRequest);
      };
    };
  }

  @override
  Middleware get verifyJwt {
    return createMiddleware(
      requestHandler: (Request request) {
        if (request.context['jwt'] == null) return Response.forbidden('Not authorized');

        return null;
      },
    );
  }
}
