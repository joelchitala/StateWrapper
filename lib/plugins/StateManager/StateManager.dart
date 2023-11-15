import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class Isolated<T> {
  Type type = T;
  final Map<String, Map<String, T>> _repositories = {};

  Isolated();

  addToRepo({String? identifier, required typeName, required T typeInstance}) {
    identifier = identifier == null ? "_" : identifier.toLowerCase();
    try {
      var instance = getRepo(identifier: identifier);
      if (instance == null) {
        _repositories.addAll({identifier: {}});
      }
      instance = getRepo(identifier: identifier);

      if (instance != null) {
        if (instance[typeName] == null) {
          instance.addAll({typeName: typeInstance});
        }
      }
    } catch (e) {}
  }

  Map<String, T>? getRepo({String? identifier}) {
    identifier = identifier == null ? "_" : identifier.toLowerCase();

    return _repositories[identifier];
  }

  getFromRepo({String? identifier, required String typeName}) {
    identifier = identifier == null ? "_" : identifier.toLowerCase();
    Map<String, T>? obj = _repositories[identifier];

    if (obj != null) {
      return obj[typeName];
    }
    return null;
  }

  removeIdentifierFromRepo({String? identifier}) {
    identifier = identifier == null ? "_" : identifier.toLowerCase();
    Map<String, T>? obj = _repositories[identifier];
    if (obj != null) _repositories.remove(identifier);
    return obj;
  }

  removeInstanceFromRepo({String? identifier, required String typeName}) {
    identifier = identifier == null ? "_" : identifier.toLowerCase();
    Map<String, T>? obj = _repositories[identifier];

    var object = obj![typeName];
    obj.remove(typeName);

    return object;
  }

  getRepos() {
    return _repositories;
  }

  getRepoObjects() {
    _repositories.forEach((key, value) {
      value.forEach((key, val) {
        print(val);
      });
    });
  }
}

class StateManager {
  Map<Type, Isolated> _functions = {};
  Map<Type, Isolated> _variables = {};
  Map<Type, Map<Type, Isolated>> _watchers = {};
  Map<Type, Isolated> _objects = {};

  StateManager._();
  static final _instance = StateManager._();

  factory StateManager() => _instance;

  initializeIsolated<T, G>(Map<Type, Isolated> isolatedObject) {
    if (isolatedObject[T] == null) {
      isolatedObject.addAll({T: Isolated<G>()});
    }
  }

  addFunction<T>(
      {String? identifier, String? functionName, required Function function}) {
    initializeIsolated<T, Function>(_functions);
    try {
      if (_functions[T] != null) {
        String funcName;

        if (functionName != null) {
          funcName = functionName;
        } else {
          funcName = extractFunctionName(function);
        }

        if (funcName.isNotEmpty) {
          _functions[T]!.addToRepo(
              identifier: identifier,
              typeName: funcName,
              typeInstance: function);
        }
      }
    } catch (e) {}
  }

  Function? getFunction<T>({String? identifier, required String functionName}) {
    if (_functions[T] != null) {
      return _functions[T]!
          .getFromRepo(identifier: identifier, typeName: functionName);
    }
    return null;
  }

  removeFunction<T>({String? identifier, required String functionName}) {
    if (_functions[T] != null) {
      _functions[T]!.removeInstanceFromRepo(
          identifier: identifier, typeName: functionName);
    }
  }

  addVariable<T>(
      {String? identifier,
      required String variableName,
      required Function function}) {
    initializeIsolated<T, Object>(_variables);
    try {
      if (_variables[T] != null) {
        if (variableName.isNotEmpty) {
          _variables[T]!.addToRepo(
              identifier: identifier,
              typeName: variableName,
              typeInstance: function);
        }
      }
    } catch (e) {}
  }

  Object? getVariable<T>(
      {required String identifier, required String variableName}) {
    if (_variables[T] != null) {
      return _variables[T]!
          .getFromRepo(identifier: identifier, typeName: variableName)!();
    }
    return null;
  }

  removeVariable<T>(
      {required String identifier, required String variableName}) {
    if (_variables[T] != null) {
      _variables[T]!.removeInstanceFromRepo(
          identifier: identifier, typeName: variableName);
    }
  }

  addObject<T, G>({String? identifier, String? objectName, required G object}) {
    initializeIsolated<T, G>(_objects);
    try {
      if (_objects[T] != null) {
        _objects[T]!.addToRepo(
            identifier: identifier,
            typeName: objectName ?? T.toString(),
            typeInstance: object);
      }
    } catch (e) {}
  }

  G? getObject<T, G>({String? identifier, String? objectName}) {
    if (_objects[T] != null) {
      return _objects[T]!.getFromRepo(
          identifier: identifier, typeName: objectName ?? T.toString());
    }
    return null;
  }

  List<G>? getObjects<T, G>({String? identifier}) {
    if (_objects[T] != null) {
      return _objects[T]!.getRepoObjects();
    }
    return null;
  }

  removeObject<T>({required String identifier, required String objectName}) {
    if (_objects[T] != null) {
      _objects[T]!
          .removeInstanceFromRepo(identifier: identifier, typeName: objectName);
    }
  }

  setWatcherIsolated<T, G>() {
    if (_watchers[T] == null) {
      _watchers.addAll({
        T: {G: Isolated<ObjectWatcher<G>>()}
      });
    } else {
      if (_watchers[T]![G] == null) {
        _watchers[T]!.addAll({G: Isolated<ObjectWatcher<G>>()});
      }
    }
  }

  addWatcher<T, G>({String? identifier, required String typeName, G? object}) {
    setWatcherIsolated<T, G>();

    try {
      if (_watchers[T] != null && typeName.isNotEmpty) {
        _watchers[T]![G]!.addToRepo(
            identifier: identifier,
            typeName: typeName,
            typeInstance: ObjectWatcher<G>(object));
      }
    } catch (e) {}
  }

  ObjectWatcher<G>? getWatcher<T, G>(
      {String? identifier, required String typeName}) {
    try {
      if (_watchers[T] != null && typeName.isNotEmpty) {
        return _watchers[T]![G]!
            .getFromRepo(identifier: identifier, typeName: typeName);
      }
    } catch (e) {}

    return null;
  }

  G? objectWatched<T, G>({String? identifier, required String typeName}) {
    ObjectWatcher<G>? obj =
        getWatcher<T, G>(identifier: identifier, typeName: typeName);

    if (obj != null) {
      return obj.object;
    }
    return null;
  }

  updateObject<T, G>(
      {String? identifier,
      required String typeName,
      required G Function(G? current) update}) {
    ObjectWatcher<G>? object =
        getWatcher<T, G>(identifier: identifier, typeName: typeName);

    if (object != null) {
      object.setObject(update(object.object));
    }
  }

  StreamSubscription<G>? watch<T, G>(
      {String? identifier,
      required String typeName,
      required Function(G? value) function}) {
    try {
      if (_watchers[T] != null && typeName.isNotEmpty) {
        ObjectWatcher<G>? object =
            getWatcher<T, G>(identifier: identifier, typeName: typeName);
        return object!.watch(function: (G value) => function(value));
      }
    } catch (e) {}

    return null;
  }

  void removeWatcher<T, G>({
    String? identifier,
    required String typeName,
  }) {
    var watcher = getWatcher<T, G>(identifier: identifier, typeName: typeName);

    if (watcher != null) {
      watcher.dispose();
    }
    if (_watchers[T] != null) {
      _watchers[T]![G]!
          .removeInstanceFromRepo(identifier: identifier, typeName: typeName);
    }
  }

  String extractFunctionName(Function function) {
    String input = function.toString();
    final RegExp pattern = RegExp(r"Function '(\w+)'");
    final Match? match = pattern.firstMatch(input);

    if (match != null) {
      return match.group(1) ?? "";
    }
    return "";
  }

  printRepos() {
    // print(_functions);
    // _functions.forEach((key, value) {
    //   print(value.getRepos());
    // });
    // print(_variables);
    // _variables.forEach((key, value) {
    //   print(value.getRepos());
    // });
    // print(_objects);
    // _objects.forEach((key, value) {
    //   print(value.getRepos());
    // });
    print(_watchers);
    _watchers.forEach((key, value) {
      value.forEach((key, val) {
        print(val.getRepos());
      });
    });
  }
}

class ManagedState {
  String identifier;
  final StateManager manager = StateManager();

  ManagedState({required this.identifier});
}

class ObjectWatcher<T> {
  T? _object;
  final _controller = StreamController<T>.broadcast();

  ObjectWatcher(T? object) : _object = object;

  Stream<T> get objectStream => _controller.stream;
  StreamSubscription<T> watch({required Function function}) {
    return _controller.stream.listen((event) => function(event));
  }

  T? get object => _object;

  setObject(T value) {
    if (value != _object) {
      _object = value;
      _controller.add(value);
    }
  }

  void dispose() {
    _controller.close();
  }
}

class VariableWrapper<T, G> {
  final StateManager _stateManager = StateManager();

  G obj;
  String variableName;
  late final String uuid;
  final String identifier;
  Function(G current)? function;
  State? widget;

  VariableWrapper(
      {this.widget,
      required this.obj,
      required this.variableName,
      this.identifier = "_"}) {
    uuid = generateUUID();
    _stateManager.addVariable<T>(
        identifier: identifier,
        variableName: variableName,
        function: () => obj);

    _stateManager.addObject<T, VariableWrapper>(
        identifier: identifier, objectName: variableName, object: this);

    _stateManager.addWatcher<T, G>(
        identifier: identifier, typeName: variableName, object: obj);

    _stateManager.watch<T, G>(
        identifier: identifier,
        typeName: variableName,
        function: (current) {
          var func = _stateManager.getFunction<T>(
              identifier: identifier, functionName: "setState");

          if (func != null) {
            func();
          }
          if (current != null && function != null) {
            function!(current);
          }
        });
  }

  get value => _stateManager.getVariable<T>(
        identifier: identifier,
        variableName: variableName,
      );
  get object => _stateManager.getObject<T, VariableWrapper>(
      identifier: identifier, objectName: variableName);

  set value(val) => _stateManager.updateObject<T, G>(
        identifier: identifier,
        typeName: variableName,
        update: (current) {
          obj = val;
          return val;
        },
      );

  void setValue(G value) {
    _stateManager.updateObject<T, G>(
      identifier: identifier,
      typeName: variableName,
      update: (current) {
        obj = value;
        return value;
      },
    );
  }

  void watch(Function(G curr) func) {
    function = func;
  }

  void dispose() {
    _stateManager.removeVariable<T>(
        identifier: identifier, variableName: variableName);
    _stateManager.removeWatcher<T, G>(
        identifier: identifier, typeName: variableName);
  }
}

class FunctionWrapper<T, G> {
  StateManager _stateManager = StateManager();

  Function function;
  String functionName;
  late final String uuid;
  final String indentifier;

  FunctionWrapper(
      {required this.function,
      required this.functionName,
      this.indentifier = "_"}) {
    uuid = generateUUID();
    _stateManager.addFunction<G>(
        identifier: indentifier,
        functionName: functionName,
        function: () => function);
  }

  get value => _stateManager.getFunction<G>(
        identifier: indentifier,
        functionName: functionName,
      );

  void dispose() {
    _stateManager.removeFunction<G>(
        identifier: indentifier, functionName: functionName);
  }
}

int generateRandomNumber(int min, int max) {
  final random = Random();
  return min + random.nextInt(max - min + 1);
}

String generateUUID() {
  return "${generateRandomNumber(1, 100000)}-${DateTime.now()}";
}
