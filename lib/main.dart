import 'package:flutter/material.dart';

import 'app.dart';
import 'core/dependencies/app_dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PcjApp(dependencies: AppDependencies.create()));
}
