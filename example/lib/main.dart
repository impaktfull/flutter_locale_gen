import 'package:flutter/material.dart';
import 'package:locale_gen_example/app.dart';
import 'package:locale_gen_example/di/injector.dart' as kiwi;

Future<void> main() async {
  kiwi.setupDependencyTree();
  runApp(MyApp());
}
