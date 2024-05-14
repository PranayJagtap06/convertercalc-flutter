import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:convertercalc_flutter/Pages/home_page.dart';
import 'package:convertercalc_flutter/Pages/main_page.dart';
import 'package:convertercalc_flutter/Pages/plot_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const CalcApp());
}

class CalcApp extends StatefulWidget {
  const CalcApp({
    super.key,
  });

  @override
  State<CalcApp> createState() => _CalcAppState();
}

class _CalcAppState extends State<CalcApp> {
  late bool _isDarkTheme;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadThemeState().then((_) {
      setState(() {
        _isInitialized = true;
      });
    });
  }

  Future<void> _loadThemeState() async {
    final rootPath = await _getrootPath();
    String filePath = '/state.json';
    final file = File("$rootPath$filePath");
    if (file.existsSync()) {
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);
      setState(() {
        _isDarkTheme = jsonData['darkstate'];
      });
    } else {
      setState(() {
        _isDarkTheme = false;
        _saveThemeState();
      });
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
    _saveThemeState();
  }

  Future<void> _saveThemeState() async {
    final rootPath = await _getrootPath();
    String filePath = '/state.json';
    final file = File("$rootPath$filePath");
    final jsonData = {'darkstate': _isDarkTheme};
    await file.writeAsString(jsonEncode(jsonData));
  }

  Future<String> _getrootPath() async {
    final Directory? directory = await getExternalStorageDirectory();
    final rootPath = '${directory?.path}';
    return rootPath;
  }

  @override
  Widget build(BuildContext context) {
    final plotdata = {};

    final lightTheme = ThemeData(
      colorScheme: const ColorScheme.light().copyWith(
        primary: Colors.black,
        secondary: Colors.amber,
        tertiary: Colors.white,
      ),
    );

    final darkTheme = ThemeData(
      colorScheme: const ColorScheme.dark().copyWith(
        primary: Colors.white,
        secondary: Colors.amber,
        tertiary: Colors.black,
      ),
    );

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Converter Calc',
      theme: _isDarkTheme ? darkTheme : lightTheme,
      home: CalcHomePage(
        toggleTheme: _toggleTheme,
        isDark: _isDarkTheme,
      ),
      routes: {
        '/mainpage': (context) => CalcMainPage(
              isDark: _isDarkTheme,
            ),
        '/plotpage': (context) => PlotPage(
              plotdata: plotdata,
            ),
      },
    );
  }
}
