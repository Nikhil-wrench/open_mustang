import 'package:hive/hive.dart';
import 'package:mustang_core/src/store/mustang_store.dart';

/// [MustangCache] is disk-based key-value database
///
/// It allows clients to save stringified objects to the disk. When a
/// serialized object is read from the cache, it will be deserialized and
/// saved to the MustangStore.
class MustangCache {
  /// Identifier for the cached data
  static String _cacheName = '';

  /// Creates a directory on the disk to save stringified objects.
  /// [storeLocation] is optional for Web.
  static Future<void> initCache(String cacheName, String? storeLocation) async {
    if (storeLocation != null) {
      Hive.init(storeLocation);
    }
    _cacheName = cacheName;
    await Hive.openLazyBox(_cacheName);
  }

  /// Writes stringified object to the disk.
  static Future<void> addObject(
    String key,
    String modelKey,
    String modelValue,
  ) async {
    LazyBox lazyBox = Hive.lazyBox(_cacheName);
    Map<String, String> value;

    if (lazyBox.isOpen) {
      value = (await lazyBox.get(key))?.cast<String, String>() ?? {};
      value.update(
        modelKey,
        (_) => modelValue,
        ifAbsent: () => modelValue,
      );
      await lazyBox.put(key, value);
    }
  }

  /// Deserializes objects in the cache and load them into the Mustang Store.
  /// Note: Deserialization has to be done by the caller. This method only
  /// returns serialized objects and their types.
  static Future<void> restoreObjects(
    String key,
    void Function(
      void Function<T>(T t) update,
      String modelName,
      String jsonStr,
    )
        callback,
  ) async {
    LazyBox lazyBox = Hive.lazyBox(_cacheName);
    if (lazyBox.isOpen) {
      Map<String, String> cacheData =
          (await lazyBox.get(key))?.cast<String, String>() ?? {};
      for (String modelKey in cacheData.keys) {
        MustangStore.persistObject(modelKey, cacheData[modelKey]!);
        callback(MustangStore.update, modelKey, cacheData[modelKey]!);
      }
    }
  }

  /// Delete all serialized objects from the cache
  static Future<void> deleteObjects(String key) async {
    LazyBox lazyBox = Hive.lazyBox(_cacheName);
    if (lazyBox.isOpen) {
      await lazyBox.delete(key);
    }
  }

  /// Checks if an object exists in the cache using it's key
  static bool itemExists(String key) {
    LazyBox lazyBox = Hive.lazyBox(_cacheName);
    return ((lazyBox.isOpen) && lazyBox.containsKey(key));
  }
}
