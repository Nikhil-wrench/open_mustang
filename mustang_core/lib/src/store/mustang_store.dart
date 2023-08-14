import 'dart:collection';
import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:mustang_core/src/cache/mustang_cache.dart';

/// [MustangStore] is an in-memory key-value object database.
///
/// - Objects are saved to the store using it's type as the key
/// - Types should not be null. E.g. User is a valid type but not User?
/// - If an object exists, existing object will be replaced
class MustangStore {
  // Underlying data structure for the objects in the store
  static final HashMap<String, Object> _hashStore = HashMap();

  static const String _nullTypeError =
      'Mustang store accepts only non-nullable types';

  // Flag to toggle persistence
  static bool _persistent = false;

  static String? _storeName;

  static String? _cacheStoreName;

  // File system path for the persisted and cached objects
  static String? _storeLocation;

  /// Returns persistence status of the store
  static bool get persistent => _persistent;

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

  /// Removes an object of type [T] from memory and from the persistent store
  static Future<void> delete<T>() async {
    _hashStore.remove(T.toString());
    await deletePersistedState([T.toString()]);
  }

  /// Removes an object of type [T] only from memory
  /// Note: This API is only for unit testing
  static Future<void> deleteFromStore<T>() async {
    _hashStore.remove(T.toString());
  }

  /// Delete all objects from the store
  static Future<void> nuke() async {
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
  static Future<void> config({
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
    String storeName,
    String? storeLocation,
  ) async {
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

  /// Allows the caller to deserialize and load objects into the Mustang Store.
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

  /// If persistence is enabled, delete specified persisted models
  static Future<void> deletePersistedState(List<String> deleteModels) async {
    if (_persistent && _storeName != null) {
      Box box = Hive.box(_storeName!);
      if (box.isOpen) {
        await box.deleteAll(deleteModels);
      }
    }
  }

  /// Deletes all objects except the ones passed in to the the
  /// preserveModels argument
  static Future<void> deleteObjects({
    required List<String> preserveModels,
  }) async {
    List<String> modelsToDelete = [];
    _hashStore.removeWhere((type, _) {
      bool preserve = preserveModels.contains(type);
      if (!preserve) {
        modelsToDelete.add(type);
      }
      return !preserve;
    });
    await deletePersistedState(modelsToDelete);
  }

  /// Returns the stringified model from the persistence store.
  /// Returns null if the model does not exist.
  static Future<String?> getPersistedObject(String modelName) async {
    if (_persistent && _storeName != null) {
      Box box = Hive.box(_storeName!);
      if (box.isOpen) {
        return await box.get(modelName);
      }
    }
    return null;
  }
}
