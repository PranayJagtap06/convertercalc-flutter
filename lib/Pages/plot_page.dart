import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:share_plus/share_plus.dart';

class PlotPage extends StatefulWidget {
  const PlotPage({super.key, required this.plotdata});

  final Map plotdata;

  @override
  State<PlotPage> createState() => _PlotPageState();
}

class _PlotPageState extends State<PlotPage> {
  late Uint8List bytes = Uint8List(0);
  late Image img = Image.memory(bytes, fit: BoxFit.fitWidth,);
  bool _isInitialized = false;
  late bool connection;
  late bool _isImg;
  late String filePath;

  @override
  void initState() {
    super.initState();
    _imgPath();
    _initializePlot();
  }

  Future<void> _initializePlot() async {
    try {
      final connection = await checkInertnetConnectivity();
      if (connection) {
        await _plotResponse();
        setState(() {
          _isInitialized = true;
          _isImg = true;
        });
      } else {
        setState(() {
          _isInitialized = true;
          _isImg = false;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                  icon: Icon(Icons
                      .signal_wifi_statusbar_connected_no_internet_4_rounded),
                  surfaceTintColor: Colors.redAccent,
                  title: Text(
                    'No Internet Connection!',
                    style: TextStyle(fontFamily: 'FiraCodeNerdFont'),
                  ),
                  content: Text(
                    'Please check your internet connection.',
                    style: TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
                  ));
            });
      }
    } on Exception catch (e) {
      setState(() {
        _isInitialized = true;
        _isImg = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                icon: const Icon(Icons.error_outline_rounded),
                surfaceTintColor: Colors.redAccent,
                title: const Text(
                  'Error!',
                  style: TextStyle(fontFamily: 'FiraCodeNerdFont'),
                ),
                content: Text(
                  'Error occured.\nError: $e',
                  style: const TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
                ));
          });
    }
  }

  Future<bool> checkInertnetConnectivity(
      {Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        return connection = true;
      } else {
        return connection = false;
      }
    } on TimeoutException {
      return connection = false;
    } catch (_) {
      return connection = false;
    }
  }

  Future<void> _plotResponse() async {
    const url = 'http://pypj06.pythonanywhere.com';
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(widget.plotdata));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body)['img'];
      setState(() {
        bytes = base64.decode(result);
        img = Image.memory(
          bytes,
          fit: BoxFit.fitWidth,
        );
      });
    } else {
      setState(() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(
                    'Error: ${response.statusCode}\n\n${jsonDecode(response.body)['error']}'),
              );
            });
      });
    }
  }

  Future<void> _imgPath() async {
    final Directory? appDir = await getExternalStorageDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    filePath = '${appDir?.path}/$fileName';
  }

  Future<void> _shareImgFile() async {
    final box = context.findRenderObject() as RenderBox?;
    _saveImgFile().then((file) async {
      try {
        if (box != null) {
          final result = await Share.shareXFiles(
            [XFile(filePath)],
            subject: 'TF Response',
            text: 'Here is the generated image.',
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
          );
          if (result.status == ShareResultStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully shared Image in $filePath.',
                  style: const TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } on Exception catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Something went wrong.\nError: $e',
              style: const TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  Future<File> _saveImgFile() async {
    final file = await File(filePath).writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return _isImg
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.tertiary,
              title: const Text(
                'TF Response',
                style: TextStyle(fontFamily: 'FiraCodeNerdFont'),
              ),
            ),
            body: Center(child: img),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.tertiary,
              onPressed: _shareImgFile,
              heroTag: 'share-button',
              tooltip: 'share image',
              child: const Icon(Icons.share_rounded),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.tertiary,
              title: const Text(
                'TF Response',
                style: TextStyle(fontFamily: 'FiraCodeNerdFont'),
              ),
            ),
            body: const Center(
              child: Text(
                'No Plot.',
                style: TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
              ),
            ),
          );
  }
}
