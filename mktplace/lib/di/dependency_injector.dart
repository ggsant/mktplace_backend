typedef FactoryFunction<T> = T Function();

/// You register your object creation factory or an instance of an object with [registerFactory],
/// [registerSingleton] or [registerLazySingleton]
/// And retrieve the desired object using [get] or call your locator as function as its a
/// callable class
///
class DependencyInjector {
  DependencyInjector._();

  /// access to the Singleton instance of DependencyInjector
  static DependencyInjector get _instance => DependencyInjector._();

  factory DependencyInjector() => _instance;

  final _instances = <Type, _CreateInstance<Object>>{};

  /// Registers a type so that a new instance will be created on each call of [get] on that type
  /// [T] type to register
  /// [instance] is a factory function for this type
  void registerFactory<T extends Object>(FactoryFunction<T> instance) {
    _instances[T] = _CreateInstance(instance);
  }

  /// Registers a type as Singleton by passing an [instance] of that type
  /// that will be returned on each call of [get] on that type
  /// [T] type to register
  void registerSingleton<T extends Object>(FactoryFunction<T> instance) {
    _instances[T] = _CreateInstance.singleton(instance);
  }

  /// Retrieves an instance of a registered type [T] depending on the registration
  /// function used for this type
  T get<T extends Object>() {
    final Object? instance = _instances[T]?.getInstance();
    if (instance != null && instance is T) return instance;
    throw Exception('[ERROR] -> Instance ${T.toString()} not founded ');
  }

  call<T extends Object>() => get<T>();
}

class _CreateInstance<T> {
  _CreateInstance(this._createInstance) : _isFirstGetInstance = false;
  _CreateInstance.singleton(this._createInstance) : _isFirstGetInstance = true;

  final FactoryFunction<T> _createInstance;

  T? _instance;
  bool _isFirstGetInstance;

  T? getInstance() {
    if (_isFirstGetInstance) {
      _instance = _createInstance();
      _isFirstGetInstance = false;
    }
    return _instance ?? _createInstance();
  }
}
