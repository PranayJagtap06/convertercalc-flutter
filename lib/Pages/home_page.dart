import 'dart:convert';
import 'dart:io';
import 'package:convertercalc_flutter/Pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:android_intent/android_intent.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CalcHomePage extends StatefulWidget {
  const CalcHomePage({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  final bool isDark;
  final VoidCallback toggleTheme;

  @override
  State<CalcHomePage> createState() => _CalcHomePageState();
}

class _CalcHomePageState extends State<CalcHomePage> {
  final ScrollController scrollContent = ScrollController();
  final String aboutHeadline = "ℹ About";
  final String aboutBody1 =
      """\n\nBuild 🏗️ with Flutter, ConverterCalc 📱 is a one stop solution to find your dc-dc converter specifications. ConverterCalc takes some input parameters like converter type (buck, boost or buck-boost), input voltage, output voltage, output resistance, frequency, % input ripple current (optional) and % output ripple voltage to calculate the converter specifications like input and output power or current, inductor current and most importantly inductor and capacitor values. Make sure to finalize prerequisite input parameters before calculating converter specifications.""";
  final String aboutBody2 = "\n\nBuild With \u2764 in 🇮🇳";
  final String author = "👨🏽‍💻 About Developer";
  final String authorBody =
      """\nPranay Jagtap is an Electrical Engineer ⚡ turned Python 🐍 enthusiast and Machine Learning 🤖 explorer. He also loves to build apps to simplify work, one such effort is ConverterCalc.""";
  final List<dynamic> _histList = [];
  late String _filePath = '/calc_hist.json';
  late String _statePath = '/state.json';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestWriteExternalStoragePermission();
    });
  }

  Future<void> _requestWriteExternalStoragePermission() async {
    PermissionStatus readstatus = await Permission.storage.status;
    PermissionStatus writestatus =
        await Permission.manageExternalStorage.status;
    if (!readstatus.isGranted && !writestatus.isGranted) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            icon: const Icon(Icons.library_add_check_rounded),
            surfaceTintColor: Theme.of(context).colorScheme.secondary,
            title: const Text(
              'Grant Permissions',
              style: TextStyle(
                fontFamily: 'FiraCodeNerdFontPropo',
              ),
            ),
            content: const Text(
              'You may need to grant some permissions in order for the app to function as desired.',
              style: TextStyle(
                fontFamily: 'FiraCodeNerdFontMono',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showPermissionDeniedDialog();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  PermissionStatus statusWrite =
                      await Permission.storage.request();
                  PermissionStatus statusRead =
                      await Permission.manageExternalStorage.request();
                  if (statusRead.isGranted && statusWrite.isGranted) {
                    _getrootPath().then((rootPath) {
                      _filePath = '$rootPath$_filePath';
                      _loadOrCreateHistJsonFile(_filePath).then((histList) {
                        setState(() {
                          _histList.addAll(histList);
                        });
                      });
                    });
                    _getrootPath().then((rootPath) {
                      _statePath = '$rootPath$_statePath';
                      _loadOrCreateStateJsonFile(_statePath);
                    });
                  } else {
                    _showPermissionDeniedDialog();
                  }
                },
                child: const Text(
                  'OK',
                  style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.warning_rounded),
          surfaceTintColor: Colors.redAccent,
          title: const Text(
            'Permission Denied',
            style: TextStyle(
              fontFamily: 'FiraCodeNerdFontPropo',
            ),
          ),
          content: const Text(
            'The app needs permission to write to external storage to save the history file.',
            style: TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestWriteExternalStoragePermission();
              },
              child: const Text(
                'Request Permission',
                style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String> _getrootPath() async {
    final Directory? directory = await getExternalStorageDirectory();
    final rootPath = '${directory?.path}';
    return rootPath;
  }

  Future<List<dynamic>> _loadOrCreateHistJsonFile(String filePath) async {
    File file = File(filePath);

    if (!file.existsSync()) {
      file.writeAsStringSync("[]");
    }

    String jsonString = await file.readAsString();
    List<dynamic> list = jsonDecode(jsonString);

    return list;
  }

  void _loadOrCreateStateJsonFile(String filePath) {
    File file = File(filePath);

    if (!file.existsSync()) {
      file.writeAsStringSync("{'darkstate' = ${widget.isDark}}");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.error_outline_rounded),
          surfaceTintColor: Colors.redAccent,
          title: const Text(
            'Error!',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        title: const Text(
          'Home',
          style: TextStyle(fontFamily: 'FiraCodeNerdFont'),
        ),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.horizontal(
              left: Radius.circular(50), right: Radius.circular(50)),
        ),
        elevation: 10,
        shadowColor: Theme.of(context).colorScheme.primary,
        primary: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              widget.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        controller: scrollContent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Welcome to ConverterCalc!✨✨✨",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontFamily: 'FiraCodeNerdFont',
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
            const SizedBox(
              height: 5.0,
            ),
            const Text(
              "One stop solution for all your Converter specs calculations!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'FiraCodeNerdFontMono',
                  fontWeight: FontWeight.w200,
                  fontSize: 12,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Card(
              elevation: 15.0,
              surfaceTintColor: Colors.amberAccent,
              shadowColor: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text.rich(
                  textAlign: TextAlign.left,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: aboutHeadline,
                        style: const TextStyle(
                          fontFamily: 'FiraCodeNerdFontPropo',
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: aboutBody1,
                        style: const TextStyle(
                          fontFamily: 'FiraCodeNerdFontMono',
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: aboutBody2,
                        style: const TextStyle(
                          fontFamily: 'FiraCodeNerdFontMono',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 15.0,
                shadowColor: Colors.blue,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CalcMainPage(
                          isDark: widget.isDark,
                        )),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.calculator),
                  SizedBox(width: 8.0),
                  Text(
                    'Go to ConverterCalc',
                    style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 15.0,
                shadowColor: Colors.deepOrange,
                backgroundColor: Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                const url =
                    'https://github.com/PranayJagtap06/convertercalc_flutter';
                try {
                  final intent = AndroidIntent(
                    action: 'action_view',
                    data: Uri.encodeFull(url),
                  );
                  intent.launch();
                } catch (e) {
                  _showErrorDialog(
                      context, 'Failed to reach GitHub. Error: $e');
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon(Icons.code),
                  FaIcon(FontAwesomeIcons.github),
                  SizedBox(width: 8.0),
                  Text(
                    'View on GitHub',
                    style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            Card(
              elevation: 15.0,
              surfaceTintColor: Colors.greenAccent,
              shadowColor: Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: 'FiraCodeNerdFontPropo',
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8.0), // Add some spacing
                    const CircleAvatar(
                      backgroundImage: AssetImage(
                          'assets/images/portrait.jpg'), // Path to your image asset
                      radius: 40.0, // Adjust the radius as needed
                    ),
                    Text(
                      authorBody,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: 'FiraCodeNerdFontMono',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
