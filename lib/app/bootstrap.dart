import 'package:flutter/widgets.dart';
import '../cores/notification/app_notifications.dart';
import '../cores/timezone/app_timezone.dart';
import 'di/injection.dart';

/// Inisialisasi sebelum `runApp`: binding, zona waktu, notifikasi, lalu rakit dependensi.
Future<AppDependencies> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppTimezone.init();
  await AppNotifications.init();
  return Injection.build();
}
