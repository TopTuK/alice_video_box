// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alice_video_box/main.dart';

class Counter {
  int value = 0;

  void increment() => value++;
  void decrement() => value--;
}

void main() {
  group('Test group', () {
    test('Test Increment', (){
      final counter = Counter();

      counter.increment();

      expect(counter.value, 1);
    });

    test('Test Decrement', (){
      final counter = Counter();

      counter.decrement();

      expect(counter.value, -1);
    });
  });
}
