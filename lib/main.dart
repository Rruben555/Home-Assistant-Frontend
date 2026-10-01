import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_router.dart';
import 'repository/auth_repository.dart';
import 'repository/member_repository.dart';
import 'repository/task_repository.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HomeAssistantApp());
}

class HomeAssistantApp extends StatefulWidget {
  const HomeAssistantApp({super.key});

  @override
  State<HomeAssistantApp> createState() => _HomeAssistantAppState();
}

class _HomeAssistantAppState extends State<HomeAssistantApp> {
  // Dua repository untuk seluruh aplikasi (data simulasi in-memory):
  // TaskRepository (modul aktivitas) dan MemberRepository (modul anggota
  // keluarga), berelasi lewat assignedMemberId.
  late final _authRepository = AuthRepository();
  late final _router = createAppRouter(_authRepository);
  late final _taskRepository = TaskRepository();
  late final _memberRepository = MemberRepository(_taskRepository);

  @override
  void dispose() {
    _router.dispose();
    _authRepository.dispose();
    _memberRepository.dispose();
    _taskRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      repository: _authRepository,
      child: TaskScope(
      repository: _taskRepository,
      child: MemberScope(
        repository: _memberRepository,
        child: MaterialApp.router(
          title: 'Home Assistant',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          // Date/Time picker tampil dalam Bahasa Indonesia.
          locale: const Locale('id', 'ID'),
          supportedLocales: const [Locale('id', 'ID')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
          // Izinkan geser dengan mouse/trackpad (web & desktop) pada daftar
          // horizontal seperti filter kategori dan saran cepat.
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.stylus,
              PointerDeviceKind.trackpad,
            },
          ),
          // Batasi skala teks sistem agar tata letak tidak pecah pada
          // pengaturan font sangat besar, tanpa mematikan aksesibilitas.
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: mq.textScaler
                    .clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
      ),
    );
  }
}