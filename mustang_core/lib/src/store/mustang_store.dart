import 'dart:collection';
import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:mustang_core/src/cache/mustang_cache.dart';

/// [MustangStore] is an in-memory key-value object database.
///
/// - Objects are saved to the store using it's type as the key
/// - Types should not be null. E.g User? is not valid
/// - If an object exists, saving that object in the store will overwrite
/// the existing object
class MustangStore {
  // Underlying data structure for the objects in the store
  static final HashMap<String, Object> _hashStore = HashMap();

  static const String _nullTypeError =
      'Mustang store accepts only non-nullable types';

  // Flag to toggle persistence
  static bool _persistent = false;

  // Identifier for the persisted objects
  static String? _storeName;

  // Identifier for the cached objects
  static String? _cacheStoreName;

  // File system path for persisted and cached objects
  static String? _storeLocation;

  /// Looks up for an object of type [T].
  /// Returns null if the object is not found.
  static T? get<T>() {
    if (_hashStore.containsKey('$T')) {
      return _hashStore['$T']! as T;
    }
    return null;
  }

  /// Saves an object [t] of type [T].
  /// If the object of the same type exists, it will be replaced.
  static void update<T>(T t) {
    assert(!('$T'.endsWith('?')), _nullTypeError);
    _hashStore.update(
      T.toString(),
      (_) => t as Object,
      ifAbsent: () => t as Object,
    );

    assert(() {
      postEvent('Mustang Store', {
        'persistentStoreName': _storeName,
        'persistentStoreLocation': _storeLocation,
        'persistentCacheStore': _cacheStoreName,
        'persistentCacheStoreLocation': _storeLocation,
        'objects': _hashStore.length,
      });
      return true;
    }());
  }

  /// Saves objects [t], [s] of type [T] and [S] respectively.
  /// If any object of the same type exists, it will be replaced.
  static void update2<T, S>(T t, S s) {
    assert(
      !(T.toString().endsWith('?') || S.toString().endsWith('?')),
      _nullTypeError,
    );
    update<T>(t);
    update<S>(s);
  }

  /// Saves objects [t], [s], [u] of type [T],[S] and [U] respectively.
  /// If an object of the same type exists, it will be replaced.
  static void update3<T, S, U>(T t, S s, U u) {
    assert(
      !(T.toString().endsWith('?') ||
          S.toString().endsWith('?') ||
          U.toString().endsWith('?')),
      _nullTypeError,
    );
    update<T>(t);
    update<S>(s);
    update<U>(u);
  }

  /// Saves objects [t], [s], [u], [v] of type [T],[S], [U] and [V] respectively.
  /// If an object of the same type exists, it will be replaced.
  static void update4<T, S, U, V>(T t, S s, U u, V v) {
    assert(
      !(T.toString().endsWith('?') ||
          S.toString().endsWith('?') ||
          U.toString().endsWith('?') ||
          V.toString().endsWith('?')),
      _nullTypeError,
    );
    update<T>(t);
    update<S>(s);
    update<U>(u);
    update<V>(v);
  }

  /// Removes an object of type [T]
  static void delete<T>() {
    _hashStore.remove(T.toString());
  }

  /// Delete all objects from the store
  static void nuke() async {
    _hashStore.clear();
    if (_persistent && _storeName != null) {
      Box box = Hive.box(_storeName!);
      if (box.isOpen) {
        await box.deleteAll(box.keys);
      }
    }
  }

  /// Configures persistence for the store
  @Deprecated('Use configPersistence method')
  static void config({
    bool isPersistent = false,
    String? storeName,
  }) async {
    _persistent = isPersistent;
    _storeName = storeName;
  }

  /// If persistence is enabled, it saves stringified object to the disk.
  static Future<void> persistObject(String key, String value) async {
    if (_persistent && _storeName != null) {
      Box box = Hive.box(_storeName!);
      if (box.isOpen) {
        await box.put(key, value);
      }
    }
  }

  /// Creates a directory on the disk to save stringified objects.
  /// [storeLocation] is optional for Web.
  /// Persistence also enables cache behind the scenes.
  static Future<void> configPersistence(
      String storeName, String? storeLocation) async {
    _persistent = true;
    _storeName = storeName;
    _cacheStoreName = '${storeName}Cache';
    _storeLocation = storeLocation;

    if (storeLocation != null) {
      Hive.init(storeLocation);
    }
    await Hive.openBox(_storeName!);

    // Config cache when persistence is in use
    await MustangCache.initCache(_cacheStoreName!, storeLocation);
  }

  /// Creates a directory on the disk to save stringified objects.
  /// [storeLocation] is optional for Web.
  /// Persistence also enables cache behind the scenes.
  @Deprecated('Use configPersistence method')
  static Future<void> initPersistence(String? storeLocation) async {
    if (_persistent && _storeName != null) {
      if (storeLocation != null) {
        Hive.init(storeLocation);
      }
      await Hive.openBox(_storeName!);

      // Config cache when persistence is in use
      await MustangCache.initCache(_cacheStoreName!, storeLocation);
    }
  }

  /// Allows the caller to deserialize and load them into the Mustang Store.
  /// Note: Deserialization has to be done by the caller. This method only
  /// returns serialized objects and their types.
  static Future<void> restoreState(
    void Function(
      void Function<T>(T t) update,
      String modelName,
      String jsonStr,
    ) callback,
    List<String> serializerNames,
  ) async {
    if (_persistent && _storeName != null) {
      Box box = Hive.box(_storeName!);
      if (box.isOpen) {
        for (dynamic key in box.keys) {
          if (serializerNames.contains(key)) {
            callback(MustangStore.update, key, box.get(key));
          }
        }
      }
    }
  }

  /// If persistence is enabled, it deletes all persisted objects
  static Future<void> deletePersistedState(List<String> deleteModels) async {
    if (_persistent && _storeName != null) {
      Box box = Hive.box(_storeName!);
      if (box.isOpen) {
        await box.deleteAll(deleteModels);
      }
    }
  }

  /// Returns persistence status of the store
  static bool get persistent => _persistent;
}
