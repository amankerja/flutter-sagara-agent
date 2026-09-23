import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sagara_mobile/main.dart';
import 'package:sagara_mobile/data/repositories/sagara_repository.dart';
import 'package:sagara_mobile/providers/app_state_provider.dart';
import 'package:sagara_mobile/providers/agent_provider.dart';
import 'package:sagara_mobile/providers/task_provider.dart';
import 'package:sagara_mobile/providers/approval_provider.dart';
import 'package:sagara_mobile/providers/schedule_provider.dart';
import 'package:sagara_mobile/providers/chat_task_provider.dart';
import 'package:sagara_mobile/providers/theme_provider.dart';

void main() {
  testWidgets('Sagara Mobile App smoke test', (WidgetTester tester) async {
    final repository = SagaraRepository();

    await tester.pumpWidget(
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

    // Settle all futures and animations
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('Sagara AI'), findsOneWidget);
    // Verify tab subtitle for active tab (Mission Overview)
    expect(find.text('Mission Overview'), findsOneWidget);
  });
}
