import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/notification_service.dart';
import 'data/repositories/sagara_repository.dart';
import 'providers/app_state_provider.dart';
import 'providers/agent_provider.dart';
import 'providers/task_provider.dart';
import 'providers/approval_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/chat_task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  final repository = SagaraRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider(repository: repository)),
        ChangeNotifierProvider(create: (_) => AgentProvider(repository: repository)),
        ChangeNotifierProvider(create: (_) => TaskProvider(repository: repository)),
        ChangeNotifierProvider(create: (_) => ApprovalProvider(repository: repository)),
        ChangeNotifierProvider(create: (_) => ScheduleProvider(repository: repository)),
        ChangeNotifierProvider(create: (_) => ChatTaskProvider(repository: repository)),
      ],
      child: const SagaraMobileApp(),
    ),
  );
}

class SagaraMobileApp extends StatelessWidget {
  const SagaraMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'SAGARA AI Mobile',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: const MainShellScreen(),
    );
  }
}

