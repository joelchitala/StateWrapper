import 'package:flutter/material.dart';
import 'package:statewrapper/plugins/StateManager/StateManager.dart';

class StatelessVariableWrapper extends StatelessWidget {
  StatelessVariableWrapper({super.key});

  final StateManager stateManager = StateManager();

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

class StatefulVariableWrapper extends StatefulWidget {
  final String identifier;
  const StatefulVariableWrapper({super.key, this.identifier = "_"});

  @override
  StateVariableWrapper<StatefulVariableWrapper> createState() =>
      // ignore: no_logic_in_create_state
      StateVariableWrapper(this);
}

class StateVariableWrapper<T extends StatefulVariableWrapper> extends State {
  late T ref;
  final StateManager stateManager = StateManager();

  StateVariableWrapper(T reference) {
    ref = reference;
    stateManager.addFunction<T>(
        identifier: ref.identifier,
        function: () {
          if (mounted) {
            setState(() {});
          }
        },
        functionName: "setState");
  }

  @override
  void dispose() {
    stateManager.removeFunction<T>(functionName: "setState");
    stateManager;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

// class ThemeWidget extends StatefulTheme {
//   final int counter = 0;
//   const ThemeWidget({super.key});

//   @override
//   StateTheme<ThemeWidget> createState() => ThemeWidgetState(this);
// }

// class ThemeWidgetState extends StateTheme<ThemeWidget> {
//   ThemeWidgetState(reference) : super(reference);

//   @override
//   Widget build(BuildContext context) {
//     return const Text("ThemeWidgetState");
//   }
// }
