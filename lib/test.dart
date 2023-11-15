import 'package:flutter/material.dart';
import 'package:statewrapper/UI/wrappers/StateVariable.dart';

class Counter extends ReactiveClass<Counter> {
  int counter = 0;
  Counter._();

  static final _instance = Counter._();

  factory Counter() => _instance;

  void increment() {
    ++counter;
    react();
  }
}

class CounterReactful extends StatefulVariableWrapper {
  const CounterReactful({super.key});

  @override
  ReactiveState<CounterReactful, Counter> createState() =>
      _CounterReactfulState(this);
}

class _CounterReactfulState extends ReactiveState<CounterReactful, Counter> {
  _CounterReactfulState(super.reference);
  final Counter counter = Counter();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      color: Color(0xfff0a09 + counter.counter),
      child: Column(
        children: [Text("Hello ${counter.counter}")],
      ),
    );
  }
}

class CounterReactful2 extends StatefulVariableWrapper {
  const CounterReactful2({super.key});

  @override
  ReactiveState<CounterReactful2, Counter> createState() =>
      _CounterReactful2State(this);
}

class _CounterReactful2State extends ReactiveState<CounterReactful2, Counter> {
  _CounterReactful2State(super.reference);
  final Counter counter = Counter();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Text("Hello ${counter.counter}")],
    );
  }
}
