import 'dart:convert';
import 'dart:io';
// import 'package:convertercalc_flutter/converter_tf.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HistPage extends StatefulWidget {
  const HistPage({super.key});

  @override
  State<HistPage> createState() => _HistPageState();
}

class _HistPageState extends State<HistPage> {
  final List<dynamic> _histList = [];
  late final String _filePath;
  late final String filePath;
  final ScrollController scrollData = ScrollController();
  final ScrollController scrollHist = ScrollController();
  final ScrollController scrollTF = ScrollController();
  // bool _showHistory = true;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _getrootPath().then((rootPath) {
      _filePath = '$rootPath/calc_hist.json';
      filePath = '$rootPath/history.txt';
      _loadJsonFile(_filePath).then((histList) {
        setState(() {
          _histList.addAll(histList);
        });
      });
    });
    scrollData.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollData.removeListener(_scrollListener);
    scrollData.dispose();
    scrollHist.dispose();
    scrollTF.dispose();
    super.dispose();
  }

  Future<String> _getrootPath() async {
    final Directory? directory = await getExternalStorageDirectory();
    final rootPath = '${directory?.path}';
    return rootPath;
  }

  Future<List<dynamic>> _loadJsonFile(String filePath) async {
    File file = File(filePath);

    String jsonString = await file.readAsString();
    List<dynamic> list = jsonDecode(jsonString);

    return list;
  }

  void _saveListToJsonFile(List<dynamic> list, String filePath) {
    String jsonString = jsonEncode(list);
    File file = File(filePath);
    file.writeAsStringSync(jsonString);
  }

  void _scrollListener() {
    if (scrollData.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      }
    } else if (scrollData.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
    }
  }

  void _handleCardClick(int index) {
    final item = _histList[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          icon: const Icon(Icons.history_rounded),
          surfaceTintColor: Theme.of(context).colorScheme.secondary,
          title: Text(
            'History ${item['no']}',
            style: const TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
          ),
          content: Scrollbar(
            thumbVisibility: true,
            controller: scrollHist,
            child: SingleChildScrollView(
              controller: scrollHist,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(10),
              child: Text(
                item['hist'],
                style: const TextStyle(
                  fontFamily: 'FiraCodeNerdFontMono',
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ),
          //_showHistory
          // ? Scrollbar(
          //     thumbVisibility: true,
          //     controller: scrollHist,
          //     child: SingleChildScrollView(
          //       controller: scrollHist,
          //       scrollDirection: Axis.horizontal,
          //       padding: const EdgeInsets.all(10),
          //       child: Text(
          //         item['hist'],
          //         style: const TextStyle(
          //           fontFamily: 'FiraCodeNerdFontMono',
          //           fontWeight: FontWeight.w200,
          //         ),
          //       ),
          //     ),
          //   )
          // : Scrollbar(
          //     thumbVisibility: true,
          //     controller: scrollTF,
          //     child: SingleChildScrollView(
          //       controller: scrollTF,
          //       scrollDirection: Axis.horizontal,
          //       padding: const EdgeInsets.all(10),
          //       child: Text(
          //         returnTF(
          //           item['mode'],
          //           num.parse(item['vin']),
          //           item['D'],
          //           num.parse(item['ro']),
          //           item['ind'],
          //           item['cap'],
          //         ),
          //         textAlign: TextAlign.center,
          //         style: const TextStyle(
          //           fontFamily: 'FiraCodeNerdFontMono',
          //           fontWeight: FontWeight.w200,
          //         ),
          //       ),
          //     ),
          //   ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              ),
            ),
            TextButton(
              onPressed: () async {
                // if (_showHistory) {
                await Clipboard.setData(ClipboardData(text: item['hist']));
                // } else {
                //   await Clipboard.setData(
                //     ClipboardData(
                //       text: returnTF(
                //         item['mode'],
                //         num.parse(item['vin']),
                //         item['D'],
                //         num.parse(item['ro']),
                //         item['ind'],
                //         item['cap'],
                //       ),
                //     ),
                //   );
                // }
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Content copied to clipboard',
                      style: TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
                    ),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: const Text(
                'Copy',
                style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     setState(() {
            //       _showHistory = !_showHistory;
            //     });
            //     Navigator.of(context).pop();
            //     _handleCardClick(index);
            //   },
            //   child: const Text(
            //     'TF/Hist',
            //     style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
            //   ),
            // ),
          ],
        );
      },
    );
  }

  void _clearHistory() async {
    // Show a confirmation dialog
    bool shouldClear = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.warning_rounded),
          surfaceTintColor: Colors.redAccent,
          title: const Text(
            'Clear History',
            style: TextStyle(fontFamily: 'FiraCodeNerdFont'),
          ),
          content: const Text(
            'Are you sure you want to clear the history?',
            style: TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Clear',
                style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              ),
            ),
          ],
        );
      },
    );
    if (shouldClear) {
      final file = File(filePath);
      await file.writeAsString('');
      setState(() {
        // Clear the _histList
        _histList.clear();
        _saveListToJsonFile(_histList, _filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'History deleted.',
              style: TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  void _shareHistoryFile() async {
    try {
      _writeToTextFile().then((file) async {
        if (await file.exists()) {
          final result = await Share.shareXFiles([XFile(filePath)]);
          if (result.status == ShareResultStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'File shared successfully.',
                  style: TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
                ),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'History file not found.',
                style: TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong.\n$e',
            style: const TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<File> _writeToTextFile() async {
    // try {
    final file = File(filePath);
    final content = _histList.asMap().entries.map((entry) {
      // final index = entry.key + 1;
      final item = entry.value;
      // final tf = returnTF(
      //   item['mode'],
      //   num.parse(item['vin']),
      //   item['D'],
      //   num.parse(item['ro']),
      //   item['ind'],
      //   item['cap'],
      // );
      return 'Sr.No. ${item['no']}:\n${item['hist']}';
    }).join('\n\n\n');

    await file.writeAsString(content);
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       'History saved to history.txt at $filePath',
    //       style: const TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
    //     ),
    //     duration: const Duration(seconds: 3),
    //   ),
    // );

    return file;
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text(
    //         'Failed to save history',
    //         style: TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
    //       ),
    //       duration: Duration(seconds: 2),
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        title: const Text(
          'History',
          style: TextStyle(fontFamily: 'FiraCodeNerdFont'),
        ),
      ),
      body: _histList.isEmpty
          ? const Center(
              child: Text(
              'No history available',
              style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
            ))
          : NotificationListener(
              onNotification: (notification) {
                return true;
              },
              child: Scrollbar(
                thumbVisibility: true,
                controller: scrollData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  controller: scrollData,
                  itemCount: _histList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = _histList[index];
                    return Card(
                      elevation: 5,
                      shadowColor: Theme.of(context).colorScheme.secondary,
                      surfaceTintColor: Theme.of(context).colorScheme.secondary,
                      child: ListTile(
                        title: Text(
                          "${item['no']}.  Mode: ${item['mode']}  Vin: ${item['vin']}V  Vo: ${item['vo']}V  Ro: ${item['ro']}ohm  Freq: ${item['fsw']}Hz",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'FiraCodeNerdFontPropo',
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        onTap: () => _handleCardClick(index),
                        enabled: true,
                      ),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, 1.0), // Start position
            end: Offset.zero, // End position
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic, // Use a smooth curve
            ),
          );
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        child: _isFabVisible
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.tertiary,
                    onPressed: _clearHistory,
                    heroTag: 'delete-button',
                    tooltip: 'delete history',
                    child: const Icon(Icons.delete),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.tertiary,
                    onPressed: _shareHistoryFile,
                    heroTag: 'share-button',
                    tooltip: 'share history',
                    child: const Icon(Icons.share_rounded),
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }
}
