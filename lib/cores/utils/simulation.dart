import '../config/app_config.dart';

/// Jeda buatan untuk repository in-memory (hilang saat diganti Firebase).
Future<void> simulateLatency([Duration duration = AppConfig.simulatedDelay]) =>
    Future<void>.delayed(duration);
