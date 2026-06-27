import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/hive_service.dart';
import 'viewmodels/tournament_viewmodel.dart';
import 'views/home_screen.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TournamentViewModel()..loadTournaments()),
      ],
      child: const EsportsResultMakerApp(),
    ),
  );
}

class EsportsResultMakerApp extends StatelessWidget {
  const EsportsResultMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esports Result Maker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
