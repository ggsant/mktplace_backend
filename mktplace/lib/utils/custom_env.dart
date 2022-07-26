import 'dart:io';

import 'parser_extension.dart';

class CustomEnv {
  CustomEnv._();

  factory CustomEnv.fromEnv(String env) {
    _file = _file + env;
    return CustomEnv._();
  }

  static Map<String, String> _map = {};

  static String _file = '.env.';

  static Future<Type> get<Type>({required String key}) async {
    if (_map.isEmpty) await _loadFile();
    return _map[key]!.toType(Type);
  }

  static Future<String> _readFile() async => await File(_file).readAsString();

  static Future<void> _loadFile() async {
    List<String> rows = (await _readFile()).split('\n');
    _map = {
      for (var itens in rows) itens.split('=')[0]: itens.split('=')[1],
    };
  }
}
