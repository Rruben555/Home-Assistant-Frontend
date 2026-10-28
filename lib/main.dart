import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  final dependencies = await bootstrap();
  runApp(HouseChoreApp(dependencies: dependencies));
}
