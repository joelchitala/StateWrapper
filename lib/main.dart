import 'package:flutter/material.dart';
import 'package:statewrapper/UI/wrappers/StateVariable.dart';
import 'package:statewrapper/plugins/StateManager/StateManager.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final StateManager _stateManager = StateManager();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4d3c3c)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
                onPressed: () {
                  var open =
                      _stateManager.getObject<BoxChange, VariableWrapper>(
                          identifier: "_", objectName: "open");

                  if (open != null) {
                    open.value = open.value ? false : true;
                  }
                },
                child: const Text("Change"))
          ],
        ),
        body: MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChangeBtn(),
        Center(
          child: BoxChange(),
        ),
        Center(
          child: BoxChange(identifier: "box2"),
        ),
      ],
    );
  }
}

class ChangeBtn extends StatefulWidget {
  const ChangeBtn({super.key});

  @override
  State<ChangeBtn> createState() => _ChangeBtnState();
}

class _ChangeBtnState extends State<ChangeBtn> {
  final StateManager _stateManager = StateManager();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          var open = _stateManager.getObject<BoxChange, VariableWrapper>(
              identifier: "_", objectName: "open");
          if (open != null) {
            open.value = open.value ? false : true;
          }
        },
        child: const Text("Change"));
  }
}

class BoxChange extends StatefulVariableWrapper {
  const BoxChange({super.key, super.identifier});

  @override
  StateVariableWrapper<BoxChange> createState() => _BoxChangeState(this);
}

class _BoxChangeState extends StateVariableWrapper<BoxChange> {
  _BoxChangeState(super.reference);

  late VariableWrapper<BoxChange, bool> open = VariableWrapper<BoxChange, bool>(
      identifier: ref.identifier, obj: false, variableName: "open");
  late VariableWrapper<BoxChange, int> counter =
      VariableWrapper<BoxChange, int>(
          identifier: ref.identifier, obj: 0, variableName: "counter");

  @override
  void dispose() {
    open.dispose();
    counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double factor = 0.3;
    return Container(
      color: open.value ? Colors.blue : Colors.amber,
      width: screenSize.width * factor,
      height: screenSize.height * factor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("${counter.value}"),
          ElevatedButton(
              onPressed: () {
                counter.value += 1;
              },
              child: const Text("Increment")),
        ],
      ),
    );
  }
}
