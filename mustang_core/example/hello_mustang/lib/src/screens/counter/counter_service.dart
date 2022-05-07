import 'package:hello_mustang/src/models/counter.model.dart';
import 'package:hello_mustang/src/screens/counter/counter_service.service.dart';
import 'package:mustang_core/mustang_core.dart';

// import 'counter_service.service.dart';

@screenService
abstract class $CounterService {
  void clearCacheAndReload({bool reload = true}) {
    clearMemoizedScreen(reload: reload);
  }

  void increment() {
    Counter counter = MustangStore.get<Counter>() ?? Counter();
    counter = counter.rebuild((b) => b..value = (b.value ?? 0) + 1);
    updateState1(counter);
  }
}
