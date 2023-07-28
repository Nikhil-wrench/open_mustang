# Mustang

Mustang is an opinionated framework to build Flutter applications. It comes with the following features out of the box.

- State Management
- Persistence
- Cache
- Event management

Mustang expects project files to follow pre-defined conventions. [open_mustang_cli](https://pub.dev/packages/open_mustang_cli) assists in creating files
as per the conventions.

## Contents
- [Framework Components](#framework-components)
- [Component Communication](#component-communication)
- [Model](#model)
- [State](#state)
- [Service](#service)
- [Screen](#screen)
- [Persistence](#persistence)
- [Cache](#cache)
- [Events](#events)
- [Aspects](#aspects)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)

### Framework Components
- **Model** - *Models* defines data needed for a view.

- **Screen** - *Screen* is a Flutter widget. *Screens* can be embedded in other screens.

- **State** - *State* allows access to the specified models for the associated screen.

- **Service** - Data fetching operations and business logic specific to the associated screen are defined in a service. 

### Component Communication
- Every *Screen* is associated with a *Service* and a *State*

    [<img src="https://github.com/getwrench/open_mustang/raw/master/mustang_core/01-components.png"/>](Architecture)

Following steps outline the lifecycle of a screen

1. `Screen` reads `State` while building the UI
2. `Screen` invokes methods in the `Service` as a response to user events (`scroll`, `tap` etc.)
3. `Service` 
    - reads/updates `Models`. `Models` are saved in memory and managed by `MustangStore`
    - makes API calls, when needed
    - informs `State` when `Models` are modified
4. `State` informs `Screen` to rebuild the UI
5. Back to Step 1

### Model
- An abstract class annotated with `appModel`
- Model name should start with `$`
- Initialize fields with `InitField` annotation
- Methods/Getters/Setters are `NOT` supported inside `Model` classes
    
    ```dart
    @appModel
    abstract class $User {
      late String name;
    
      late int age;
    
      @InitField(false)
      late bool admin; 
  
      @WireNameField('postalCode')  // While de-serializing, map postalCode to zip
      late int zip;
    
      @InitField(['user', 'default'])
      late BuiltList<String> roles;
      
      late $Address address;  // Model can be a field in other models
      
      late BuiltList<$Vehicle> vehicles;  // Use only immutable versions of List/Map as fields
      
      @InitField('')          // field can have multiple annotations
      @SerializeField(false)  // errorMsg field will not be included when $User model is persisted
      late String errorMsg; 
    }
    ```
  
### State
- An abstract class annotated with `screenState`
- State name should start with `$`
- Only *Models* are allowed as fields 

    ```dart      
    @screenState
    abstract class $ExampleScreenState {
      late $User user; // Model
      
      late $Vehicle vehicle; // Model
    }
    ```
    
### Service
- An abstract class annotated with `ScreenService`
- Service name should start with `$`
  
    ```dart
    @screenService
    abstract class $ExampleScreenService {
      void getUser() {
        User user = MustangStore.get<User>() ?? User();
          updateState1(user);
        }
    }
    ```
    
- Every service has access to the following important APIs
    - `updateState` -  Updates models and triggers screen rebuild. To update the models without re-building the screen,
  set `reload` argument to `false`.
        - `updateState()`
        - `updateState1(T model1, { reload: false })` - only updates the state; screen will not be re-built
        - `updateState2(T model1, S model2, { reload: true })`
        - `updateState3(T model1, S model2, U model3, { reload: true })`
        - `updateState4(T model1, S model2, U mode3, V model4, { reload: true })`

    - `memoizeScreen` - Invokes any method passed as argument only once.
        - `T memoizeScreen<T>(T Function() methodName)`
            ```dart
            // In the snippet below, getScreenData method caches the response of getData method, a Future.
            // Even when getData method is called multiple times, method execution happens only once and uses the
            // already fetched response.
            Future<void> getData() async {
              // ...   
            }

            Future<void> getScreenData() async {
              return memoize(getData);
            }
            ```
    - `clearMemoizedScreen` - Clears the data cached by `memoizeScreen` method.
        - `void clearMemoizedScreen()`
            ```dart
            Future<void> getData() async {
              // ...
            }

            Future<void> getScreenData() async {
              return memoizeScreen(getData);
            }

            void resetScreen() {
              clearMemoizedScreen(); // clears Future<void> cached by memoizeScreen()
            }
            ``` 

### Screen
- `MustangScreen` widget should be the top-level widget for every screen
  
    ```dart
    Widget build(BuildContext context) {
      return MustangScreen<CounterState>(
        state: CounterState(context: context),
        builder: (BuildContext context, CounterState state) {
          // access counter model from the state
          int counter = state.counter.value;
          return Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('$counter'),
                ),
                // ...
              ],
            ),
          );
        },
      );
    }
    ```

### Persistence

[<img src="https://github.com/getwrench/open_mustang/raw/master/mustang_core/02-persistence.png"/>](Persistence)

By default, *models* are saved only in the memory. When the app is terminated, models are lost
permanently. There are cases where it is desirable to persist and restore these models across app restarts.

Following code snippet enables persistence for the app.

```dart
// In main.dart, before calling runApp method,
WidgetsFlutterBinding.ensureInitialized();

// enable persistence like below
Directory dir = await getApplicationDocumentsDirectory();
await MustangStore.configPersistence(UnifiedConstants.persistentStoreName, dir.path);
```

Following code restores the saved state of the app
```dart
// Restore persisted state before the app starts
await MustangStore.restoreState(app_serializer.json2Type, app_serializer.serializerNames);
```

### Cache

[<img src="https://github.com/getwrench/open_mustang/raw/master/mustang_core/03-cache.png"/>](Cache)

`Cache` feature allows switching between instances of the same type on need basis.

`Persistence` creates snapshots of the *models* in the memory, to the disk. However, there are times when data
need to be saved for later use and does not need to loaded into memory unless needed. An example would be a technician working on multiple jobs at the same time i.e, technician switches between jobs.
Since the `MustangStore` allows only one instance of a *type*, there cannot be two instances of *Job* object in the memory.

Every *Service* instance has the following `Cache` related APIs

- ```
  Future<void> addObjectToCache<T>(String key, T t)
  ```
  Save an instance of type `T` in the cache. `key` is an identifier for the cached object.

- ```
  Future<void> deleteObjectsFromCache(String key)
  ```
  Delete all cached objects having the identifier `key`

- ```
  static Future<void> restoreObjects(
      String key,
      void Function(
          void Function<T>(T t) update,
          String modelName,
          String jsonStr,
      ) callback,
  )
  ```
  Restores all objects in the cache identified by the `key` into memory and also into the persisted store
  so that the in-memory and the persisted data remain consistent.

- ```
  bool itemExistsInCache(String key)
  ```
  Returns `true` if an identifier `key` exists in the Cache, `false` otherwise.

### Events

[<img src="https://github.com/getwrench/open_mustang/raw/master/mustang_core/04-events.png"/>](Events)

There are use cases where application has to react to various events. Following are the examples of such events:
- Internet connectivity events
- Data update events from the server
- Push notifications


#### Subscribe to an event:

Mustang allows the app to subscribe to such events. When subscribed, `Service` of the currently visible `Screen` receives
event notifications. `Service` then triggers the `Screen` rebuild.
It is important to keep in mind that every event is an instance of `Model`. And, to use a model as an event, it needs to be
annotated with `@appEvent`. Following is an example of creating of a model event inside `models` folder

```dart
@appModel
@appEvent
abstract class $TimerEvent {
  @InitField(0)
  late int value;
}
```

For events to work, register `MustangRouteObserver` in the app

```dart
Widget build(BuildContext context) {
    return MaterialApp(
      // ...
      navigatorObservers: [
        MustangRouteObserver.getInstance(), // this is needed for Events to work
      ],
    );
}

```
#### Publish an event:

Following snippet is an example of app publishing an event generated by an external service

```dart
connectivity_plus.Connectivity().onConnectivityChanged.listen((var connectivityResult) {
    MustangAppConfig mustangAppConfig = _connectivityStatus(connectivityResult);
    EventStream.pushEvent(mustangAppConfig);
});
```

Visible screen of the app automatically rebuilds itself after consuming the event. It is upto the screen
to show appropriate UI based on the received event.

### Aspects

Aspects are hooks defined on a method. Hooks change the execution flow based on the type of hook defined.
Mustang supports three kinds of aspects.

In Mustang, *Aspect* is
- an abstract class annotated with `@aspect`
- Class name should start with `$`
- created inside `aspects` directory

#### Before Aspect

Method annotated with *@Before* executes the method passed as argument before running the actual method

```dart
@aspect
abstract class $BeforeAspectExample {
  @invoke
  Future<void> run(Map<String, dynamic> args) async { // runs before requestCode
    // ...
  }
}
```
Annotate method with *@Before*
```dart
@Before([r'$BeforeAspectExample'], args: {'one': 1, 'two': 2.2})
Future<void> requestCode() async {
  // ...
}
```
#### After Aspect
Method annotated with *@After* executes the annotated method first followed by the method passed as argument

```dart
@aspect
abstract class $AfterAspectExample {
  @invoke
  Future<void> run(Map<String, dynamic> args) async { // runs after requestCode
    // ...
  }
}
```
Annotated a method with *@After*
```dart
@After([r'$AfterAspectExample'], args: {'one': 1, 'two': 2.2})
Future<void> requestCode() async {
  // ...
}
```

#### Around Aspect

Method annotated with *@Around* passes itself as argument to the method passed as argument
```dart
@aspect
abstract class $AroundAspectExample {
  @invoke
  Future<void> run(Map<String, dynamic> args, Function sourceMethod) async {
    // before requestCode()
    // ...
    await sourceMethod(); // runs requestCode()
    // after requestCode()
    // ...
  }
```

Annotated a method with *@Around*
```dart
  @Around(r'$AroundAspectExample', args: {'service': 'DemoScreenService'})
  Future<void> requestCode() async {
    // ...
  }
```

### Project Structure
- Project structure of a Flutter application created with Mustang framework looks as below
    ```
      lib/
        - main.dart
        - src
          - models/
            - model1.dart
            - model2.dart
          - screens/
            - first/
              - first_screen.dart
              - first_state.dart
              - first_service.dart
            - second/
              - second_screen.dart
              - second_state.dart
              - second_service.dart
    ```
- Every `Screen` needs a `State` and a `Service`. So, `Screen, State, Service` files are grouped inside a directory
- All `Model` classes must be inside `models` directory

### Quick Start

- Install Flutter
  ```bash
    mkdir -p ~/lib && cd ~/lib
    
    git clone https://github.com/flutter/flutter.git -b stable

    # Add PATH in ~/.zshrc 
    export PATH=$PATH:~/lib/flutter/bin
    export PATH=$PATH:~/.pub-cache/bin
  ```
    
- Install Mustang CLI
  ```bash
    dart pub global activate open_mustang_cli
  ```
  
- Create Flutter project
  ```bash
    cd /tmp
    
    flutter create quick_start
    
    cd quick_start
    
    # Open the project in editor of your choice
    # vscode - code .
    # IntelliJ - idea .
  ```

- Update `pubspec.yaml`
  ```yaml
    ...
    dependencies:
      ...
      built_collection: ^5.1.1
      built_value: ^8.1.3
      mustang_core: ^1.1.2
      mustang_widgets: ^1.0.2
      path_provider: ^2.0.6

    dev_dependencies:
      ...
      build_runner: ^2.1.4
      mustang_codegen: ^1.1.4    
  ```
  
- Install dependencies
  ```bash
    flutter pub get
  ```

- Generate files for a screen called `counter`. Following command creates file representing a `Model`, and also files representing `Screen`, `Service` and `State`.
  ```bash
    omcli -s counter
  ```

- Generate runtime files and watch for changes. 
  ```bash
    omcli -w # omcli -b generates runtime files once
  ```
  
- Update the generated `counter.dart` model
  ```dart
    @appModel 
    abstract class $Counter {
      ...
  
      @InitField(0)
      late int value;
    }
  ```
  
- Update `counter_screen.dart` screen
  ```dart
    import 'package:flutter/material.dart';
    import 'package:mustang_widgets/mustang_widgets.dart';
    
    import 'counter_service.service.dart';
    import 'counter_state.state.dart';
    
    class CounterScreen extends StatelessWidget {
      const CounterScreen({
        Key key,
      }) : super(key: key);
        
      @override
      Widget build(BuildContext context) {
        return StateProvider<CounterState>(
          state: CounterState(),
          child: Builder(
            builder: (BuildContext context) {
              CounterState? state = StateConsumer<CounterState>().of(context);
              return _body(state, context);
            },
          ),
        );
      }
    
      Widget _body(CounterState? state, BuildContext context) {
        int counter = state?.counter?.value ?? 0;
        return Scaffold(
          appBar: AppBar(
            title: Text('Counter'),
          ),
          body: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('$counter'),
                ),
                ElevatedButton(
                  onPressed: CounterService().increment,
                  child: const Text('Increment'),
                ),
              ],
            ),
          ),
        );
      }
    }
  ```
  
- Update `counter_service.dart` service
  ```dart
    import 'package:mustang_core/mustang_core.dart';
    import 'package:quick_start/src/models/counter.model.dart';
        
    import 'counter_service.service.dart';
        
    @screenService
    abstract class CounterService {
      void increment() {
        Counter counter = MustangStore.get<Counter>() ?? Counter();
        counter = counter.rebuild((b) => b.value = (b.value ?? 0) + 1);
        updateState1(counter);
      }
    }
  ```
  
- Update `main.dart`
  ```dart
    ...
 
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          ...
          primarySwatch: Colors.blue,
        ),
        home: CounterScreen(), // Point to Counter screen
      );
    }
  
    ...  
  ```
