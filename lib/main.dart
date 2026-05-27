import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart';
import 'database/app_database.dart';
import 'repositories/lancamento_repository.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  final builder = kIsWeb 
      ? $FloorAppDatabase.inMemoryDatabaseBuilder()
      : $FloorAppDatabase.databaseBuilder('app_database.db');

  final database = await builder
      .addCallback(Callback(
        onConfigure: (database) async {

          await database.execute('PRAGMA foreign_keys = ON');
        },
      ))
      .build();

  final repository = LancamentoRepository(database);
  

  await repository.seedCategoriesIfEmpty();

  runApp(FinancialApp(repository: repository));
}

class FinancialApp extends StatefulWidget {
  final LancamentoRepository repository;

  const FinancialApp({super.key, required this.repository});

  @override
  State<FinancialApp> createState() => _FinancialAppState();
}

class _FinancialAppState extends State<FinancialApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle Financeiro Pessoal',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0073E6),
          brightness: Brightness.light,
          primary: const Color(0xFF0073E6),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0073E6),
          brightness: Brightness.dark,
          primary: const Color(0xFF00BFFF),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(
        repository: widget.repository,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
