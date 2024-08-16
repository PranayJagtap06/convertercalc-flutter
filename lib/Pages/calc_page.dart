import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:convertercalc_flutter/converter_package.dart';
// import 'package:convertercalc_flutter/converter_tf.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';

class CalcPage extends StatefulWidget {
  const CalcPage({super.key, required this.isDark});

  final bool isDark;

  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
  final List<dynamic> _histList = [];
  late String _filePath = '/calc_hist.json';
  final ScrollController scrollMain = ScrollController();
  final ScrollController scrollOp = ScrollController();

  String _mode = 'Boost';
  TextEditingController vin = TextEditingController();
  TextEditingController vo = TextEditingController();
  TextEditingController ro = TextEditingController();
  TextEditingController fsw = TextEditingController();
  TextEditingController ipIripl = TextEditingController();
  TextEditingController vrp = TextEditingController();
  String ipString = '';
  String opString = '';
  String mainOp = """Converter Parameters
  Duty Cycle = 0.0
  Power Input = 0.0W
  Power output = 0.0W
  Output Current = 0.0A
  Inductor Current = 0.0A
  Input Current = 0.0A
  Critical Inductance Value(Lcr)= 0.0H
  Ripple Current due to Lcr = 0.0A
  Continuous Conduction Inductor Value (L) = 0.0H
  Ripple Current due to L = 0.0A
  Maximum inductor ripple current = 0.0A
  Minimum inductor ripple current = 0.0A
  Output Capacitor = 0.0F
  Capacitor ESR = 0.0Ohms\n\nTransfer Function\nH(s) =\n\n\n\n\n""";
  String tfString = '';
  late bool iConnection;
  late String fdbk;
  bool _mainOpInitialized = true;

  @override
  void initState() {
    super.initState();
    _getrootPath().then((rootPath) {
      _filePath = '$rootPath$_filePath';
      _loadJsonFile(_filePath).then((histList) {
        setState(() {
          _histList.addAll(histList);
        });
      });
    });

    _checkInternetConnectivity().then((_) {
      // Now you can be sure that _checkInternetConnectivity has finished executing
      // and iConnection and fdbk have been set.
    });

    _focusNodevin.addListener(_handleFocusChange);
    _focusNodevo.addListener(_handleFocusChange);
    _focusNodero.addListener(_handleFocusChange);
    _focusNodefsw.addListener(_handleFocusChange);
    _focusNodeIrp.addListener(_handleFocusChange);
    _focusNodeVrp.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNodevin.removeListener(_handleFocusChange);
    _focusNodevo.removeListener(_handleFocusChange);
    _focusNodero.removeListener(_handleFocusChange);
    _focusNodefsw.removeListener(_handleFocusChange);
    _focusNodeIrp.removeListener(_handleFocusChange);
    _focusNodeVrp.removeListener(_handleFocusChange);
    _focusNodevin.dispose();
    _focusNodevo.dispose();
    _focusNodero.dispose();
    _focusNodefsw.dispose();
    _focusNodeIrp.dispose();
    _focusNodeVrp.dispose();
    scrollMain.dispose();
    scrollOp.dispose();
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

  bool _verifyIp() {
    try {
      // Parse the input values to double
      num.parse(vin.text);
      num.parse(vo.text);
      num.parse(ro.text);
      num.parse(fsw.text);
      num.parse(vrp.text);

      if (_mode.isNotEmpty) {
        // Check if ipIripl is a valid double or an empty string
        if (ipIripl.text.isEmpty || double.tryParse(ipIripl.text) != null) {
          // do nothing
          return true;
        } else {
          _showInvalidInputDialog('Invalid input for Irp');
          return false;
        }
      } else {
        _showInvalidInputDialog('Please select a mode');
        return false;
      }
    } on Exception catch (e) {
      // Handle invalid input
      _showInvalidInputDialog('Please enter a valid numeric value.\nError: $e');
      return false;
    }
  }

  void _showInvalidInputDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_rounded),
        surfaceTintColor: Colors.redAccent,
        title: const Text(
          'Invalid Input',
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
      ),
    );
  }

  Future<Tuple2<bool, String>> checkInternetConnectivity(
      {Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        return const Tuple2(true, '');
      } else {
        return const Tuple2(false, 'Please check your internet connection.');
      }
    } on SocketException {
      return const Tuple2(false, 'Please check your internet connection.');
    } on TimeoutException catch (e) {
      return Tuple2(false, '$e');
    } catch (e) {
      return Tuple2(false, '$e');
    }
  }

  Future<void> _checkInternetConnectivity() async {
    final result = await checkInternetConnectivity();
    setState(() {
      iConnection = result.item1;
      fdbk = result.item2;
    });
  }

  void _noInternetDialog(String txt) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              icon: const Icon(
                  Icons.signal_wifi_statusbar_connected_no_internet_4_rounded),
              surfaceTintColor: Colors.redAccent,
              title: const Text(
                'No Internet Connection!',
                style: TextStyle(fontFamily: 'FiraCodeNerdFont'),
              ),
              content: Text(
                txt,
                style: const TextStyle(fontFamily: 'FiraCodeNerdFontMono'),
              ));
        });
  }

  void _exceptionDialog(String e) {
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

  Future<void> _tfResponse(
      num d, num vin, num ind, num cap, num ro, String mode) async {
    const url = 'http://pypj06.pythonanywhere.com';
    final headers = {'Content-Type': 'application/json'};

    final data = {
      "d": d,
      "vin": vin,
      "inductor": ind,
      "capacitor": cap,
      "resistor": ro,
      "mode": mode,
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body)['transfer_func'];
      setState(() {
        tfString = result.substring(72);
      });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(
                  'Error: ${response.statusCode}\n\n${jsonDecode(response.body)['error']}'),
            );
          });
    }
  }

  void _initializeMainOp() {
    setState(() {
      _mainOpInitialized = false;
    });
  }

  List<dynamic> specs(
      String mode, num vin, num vo, num r, num fsw, String ipIripl, num vrp) {
    switch (mode) {
      case 'Buck':
        var buck = Bucklc();
        num d = buck.dutyCycle(vin, vo);
        num opI = vo / r;
        num ipI = buck.bckIpCurrent(d, opI);
        num indI = opI;
        num ipPower = vin * ipI;
        num opPower = vo * opI;
        num crL = buck.bckLCr(d, r, fsw);
        num crIndRiplI = buck.bckIndRiplI(vo, d, fsw, crL);
        num ind;
        num iRipl;
        if (ipIripl.isEmpty) {
          ind = crL * 1.25;
          iRipl = buck.bckIndRiplI(vo, d, fsw, ind);
        } else {
          iRipl = buck.bckRiplCurrent(indI, num.parse(ipIripl));
          ind = buck.bckLCont(vo, d, fsw, iRipl);
        }
        num maxindI = indI + (iRipl / 2);
        num minindI = indI - (iRipl / 2);
        num cap = buck.bckCap(d, ind, vrp, fsw);
        num esr = buck.bckEsr(vrp, vo, iRipl);
        return [
          d,
          opI,
          indI,
          ipI,
          ipPower,
          opPower,
          crL,
          crIndRiplI,
          ind,
          iRipl,
          maxindI,
          minindI,
          cap,
          esr
        ];
      case 'Boost':
        var boost = Boostlc();
        num d = boost.dutyCycle(vin, vo);
        num opI = vo / r;
        num indI = boost.bstIndCurrent(d, opI);
        num ipI = indI;
        num ipPower = vin * ipI;
        num opPower = vo * opI;
        num crL = boost.bstLCr(d, r, fsw);
        num crIndRiplI = boost.bstIndRiplI(vin, d, fsw, crL);
        num ind;
        num iRipl;
        if (ipIripl.isEmpty) {
          ind = crL * 1.25;
          iRipl = boost.bstIndRiplI(vin, d, fsw, ind);
        } else {
          iRipl = boost.bstRiplCurrent(indI, num.parse(ipIripl));
          ind = boost.bstLCont(vin, d, fsw, iRipl);
        }
        num maxindI = indI + (iRipl / 2);
        num minindI = indI - (iRipl / 2);
        num cap = boost.bstCap(d, r, vrp, fsw);
        num esr = boost.bstEsr(vrp, vo, iRipl);
        return [
          d,
          opI,
          indI,
          ipI,
          ipPower,
          opPower,
          crL,
          crIndRiplI,
          ind,
          iRipl,
          maxindI,
          minindI,
          cap,
          esr
        ];
      case 'BuckBoost':
        var bckbst = BuckBoostlc();
        num d = bckbst.dutyCycle(vin, vo);
        num opI = vo / r;
        num indI = bckbst.bbIndCurrent(d, opI);
        num ipI = indI * d;
        num ipPower = vin * ipI;
        num opPower = vo * opI;
        num crL = bckbst.bbLCr(d, r, fsw);
        num crIndRiplI = bckbst.bbIndRiplI(vin, d, fsw, crL);
        num ind;
        num iRipl;
        if (ipIripl.isEmpty) {
          ind = crL * 1.25;
          iRipl = bckbst.bbIndRiplI(vin, d, fsw, ind);
        } else {
          iRipl = bckbst.bbRiplCurrent(ipI, num.parse(ipIripl));
          ind = bckbst.bbLCont(vin, d, fsw, iRipl);
        }
        num maxindI = indI + (iRipl / 2);
        num minindI = indI - (iRipl / 2);
        num cap = bckbst.bbCap(d, r, vrp, fsw);
        num esr = bckbst.bbEsr(vrp, vo, iRipl);
        return [
          d,
          opI,
          indI,
          ipI,
          ipPower,
          opPower,
          crL,
          crIndRiplI,
          ind,
          iRipl,
          maxindI,
          minindI,
          cap,
          esr
        ];
      default:
        return [0];
    }
  }

  Future<void> _calulateSpecs() async {
    _initializeMainOp();
    bool fieldsVerified = _verifyIp();

    if (fieldsVerified) {
      await _checkInternetConnectivity();

      num d;
      num opI;
      num indI;
      num ipI;
      num ipPower;
      num opPower;
      num crL;
      num crIndRiplI;
      num ind;
      num iRipl;
      num maxindI;
      num minindI;
      num cap;
      num esr;

      if (iConnection) {
        [
          d,
          opI,
          indI,
          ipI,
          ipPower,
          opPower,
          crL,
          crIndRiplI,
          ind,
          iRipl,
          maxindI,
          minindI,
          cap,
          esr
        ] = specs(
            _mode,
            num.parse(vin.text),
            num.parse(vo.text),
            num.parse(ro.text),
            num.parse(fsw.text),
            ipIripl.text,
            num.parse(vrp.text));

        ipString = """Converter Parameters
  Mode = $_mode
  Vin = ${num.parse(vin.text).toStringAsFixed(3)}V
  Vo = ${num.parse(vo.text).toStringAsFixed(3)}V
  R = ${num.parse(ro.text).toStringAsFixed(3)}Ohms
  fsw = ${num.parse(fsw.text).toStringAsFixed(3)}Hz
  Irp = ${ipIripl.text}%
  Vrp = ${num.parse(vrp.text).toStringAsFixed(3)}%""";

        opString = """Converter Parameters
  Duty Cycle = ${d.toStringAsFixed(3)}
  Power Input = ${ipPower.toStringAsFixed(3)}W
  Power output = ${opPower.toStringAsFixed(3)}W
  Output Current = ${opI.toStringAsFixed(3)}A
  Inductor Current = ${indI.toStringAsFixed(3)}A
  Input Current = ${ipI.toStringAsFixed(3)}A
  Critical Inductance Value(Lcr)= ${crL.toStringAsExponential(3)}H
  Ripple Current due to Lcr = ${crIndRiplI.toStringAsFixed(3)}A
  Continuous Conduction Inductor Value (L) = ${ind.toStringAsExponential(3)}H
  Ripple Current due to L = ${iRipl.toStringAsFixed(3)}A
  Maximum inductor ripple current = ${maxindI.toStringAsFixed(3)}A
  Minimum inductor ripple current = ${minindI.toStringAsFixed(3)}A
  Output Capacitor = ${cap.toStringAsExponential(3)}F
  Capacitor ESR = ${esr.toStringAsFixed(5)}Ohms""";

        // tfString =
        //     returnTF(_mode, num.parse(vin.text), d, num.parse(ro.text), ind, cap);
        await _tfResponse(
            d, num.parse(vin.text), ind, cap, num.parse(ro.text), _mode);

        setState(() {
          mainOp = "$opString\n\nTransferFunction\nH(s) =\n$tfString\n";
          String history = '$ipString\n\n$mainOp';
          int srNo = _histList.length + 1;
          var histMap = {
            'no': srNo,
            'mode': _mode,
            'D': d,
            'vin': vin.text,
            'vo': vo.text,
            'ro': ro.text,
            'fsw': fsw.text,
            'ind': ind,
            'cap': cap,
            'hist': history
          };
          _histList.add(histMap);
          try {
            _saveListToJsonFile(_histList, _filePath);
          } on Exception catch (e) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  icon: const Icon(Icons.error_outline_rounded),
                  surfaceTintColor: Colors.redAccent,
                  title: const Text(
                    'Error!',
                    style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
                  ),
                  content: Text(
                    'Error occured while saving history.\nError: $e.',
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
          vin.text = '';
          vo.text = '';
          ro.text = '';
          fsw.text = '';
          ipIripl.text = '';
          vrp.text = '';
        });
      } else {
        if (fdbk == 'Please check your internet connection.') {
          _noInternetDialog(fdbk);
        } else {
          _exceptionDialog(fdbk);
        }
      }
    }
  }

  void _initiateCalculateSpecs() {
    _calulateSpecs().then((_) {
      setState(() {
        _mainOpInitialized = true;
      });
    });
  }

  void _clear() {
    setState(() {
      mainOp = """Converter Parameters
  Duty Cycle = 0.0
  Power Input = 0.0W
  Power output = 0.0W
  Output Current = 0.0A
  Inductor Current = 0.0A
  Input Current = 0.0A
  Critical Inductance Value(Lcr)= 0.0H
  Ripple Current due to Lcr = 0.0A
  Continuous Conduction Inductor Value (L) = 0.0H
  Ripple Current due to L = 0.0A
  Maximum inductor ripple current = 0.0A
  Minimum inductor ripple current = 0.0A
  Output Capacitor = 0.0F
  Capacitor ESR = 0.0Ohms\n\nTransfer Function\nH(s) =\n\n\n\n\n""";
    });
  }

  final FocusNode _focusNodevin = FocusNode();
  final FocusNode _focusNodevo = FocusNode();
  final FocusNode _focusNodero = FocusNode();
  final FocusNode _focusNodefsw = FocusNode();
  final FocusNode _focusNodeIrp = FocusNode();
  final FocusNode _focusNodeVrp = FocusNode();

  void _handleFocusChange() {
    setState(() {
      // Force a rebuild to update the fill color based on the focus state
    });
  }

  Color _getFillColor(bool hasFocus) {
    // if (widget.isDark) {
    //   return hasFocus ? Colors.amber[600]! : Colors.transparent;
    // } else {
    //   return hasFocus ? Colors.blue[600]! : Colors.transparent;
    // }
    return hasFocus
        ? Theme.of(context).colorScheme.secondary
        : Colors.transparent;
  }

  TextStyle _getHintStyle(bool hasFocus) {
    if (widget.isDark) {
      return TextStyle(
        fontFamily: 'FiraCodeNerdFontPropo',
        fontSize: 12,
        color: hasFocus ? Colors.black : Colors.grey,
      );
    } else {
      return TextStyle(
        fontFamily: 'FiraCodeNerdFontPropo',
        fontSize: 12,
        color: hasFocus ? Colors.white : Colors.grey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        title: const Text(
          'ConverterCalc',
          style: TextStyle(fontFamily: 'FiraCodeNerdFont'),
        ),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.horizontal(
              left: Radius.circular(50), right: Radius.circular(50)),
        ),
        elevation: 10,
        shadowColor: Theme.of(context).colorScheme.primary,
        primary: true,
      ),
      body: SingleChildScrollView(
        controller: scrollMain,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // DropdownButton<String>(
            //   elevation: 10,
            //   borderRadius: const BorderRadius.all(Radius.circular(30)),
            //   dropdownColor:
            //       Theme.of(context).colorScheme.secondary, //Colors.grey[400],
            //   value: _mode,
            //   onChanged: (String? newValue) {
            //     setState(() {
            //       if (newValue != null) {
            //         _mode = newValue;
            //       }
            //     });
            //   },
            //   items: ["Boost", "Buck", "BuckBoost"]
            //       .map<DropdownMenuItem<String>>((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Text(
            //         value,
            //         style: const TextStyle(
            //             fontFamily: 'FiraCodeNerdFontPropo', fontSize: 16),
            //       ),
            //     );
            //   }).toList(),
            // ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 1,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              onPressed: () {},
              child: DropdownButton<String>(
                underline: Container(), // Remove the default underline
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                dropdownColor: Theme.of(context).colorScheme.secondary,
                value: _mode,
                style: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontPropo', color: Colors.white),
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue != null) {
                      _mode = newValue;
                    }
                  });
                },
                items: ["Boost", "Buck", "BuckBoost"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                          fontFamily: 'FiraCodeNerdFontPropo', fontSize: 16),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: vin,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .primary, // Change this to your desired color
                    width: 2.0, // Adjust the border width as needed
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                filled: true,
                fillColor: _getFillColor(_focusNodevin.hasFocus),
                hintText: 'Input Voltage (Vin)',
                hintStyle: _getHintStyle(_focusNodevin.hasFocus),
                helperText: 'Enter the desired input voltage of converter.',
                helperMaxLines: 2,
                helperStyle: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontMono', fontSize: 10),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
              ],
              style: const TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              onEditingComplete: () {
                FocusScope.of(context).nextFocus();
              },
              focusNode: _focusNodevin,
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: vo,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .primary, // Change this to your desired color
                    width: 2.0, // Adjust the border width as needed
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                filled: true,
                fillColor: _getFillColor(_focusNodevo.hasFocus),
                hintText: 'Output Voltage (Vo)',
                hintStyle: _getHintStyle(_focusNodevo.hasFocus),
                helperText: 'Enter the desired output voltage of converter.',
                helperMaxLines: 2,
                helperStyle: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontMono', fontSize: 10),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
              ],
              style: const TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              onEditingComplete: () {
                FocusScope.of(context).nextFocus();
              },
              focusNode: _focusNodevo,
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: ro,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .primary, // Change this to your desired color
                    width: 2.0, // Adjust the border width as needed
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                filled: true,
                fillColor: _getFillColor(_focusNodero.hasFocus),
                hintText: 'Output Resistance (Ro)',
                hintStyle: _getHintStyle(_focusNodero.hasFocus),
                helperText: 'Enter the desired output resistance of converter.',
                helperMaxLines: 2,
                helperStyle: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontMono', fontSize: 10),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
              ],
              style: const TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              onEditingComplete: () {
                FocusScope.of(context).nextFocus();
              },
              focusNode: _focusNodero,
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: fsw,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .primary, // Change this to your desired color
                    width: 2.0, // Adjust the border width as needed
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                filled: true,
                fillColor: _getFillColor(_focusNodefsw.hasFocus),
                hintText: 'Operating Frequncy (fsw)',
                hintStyle: _getHintStyle(_focusNodefsw.hasFocus),
                helperText:
                    'Enter the desired operating frequeny of converter.',
                helperMaxLines: 2,
                helperStyle: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontMono', fontSize: 10),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
              ],
              style: const TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              onEditingComplete: () {
                FocusScope.of(context).nextFocus();
              },
              focusNode: _focusNodefsw,
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: ipIripl,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .primary, // Change this to your desired color
                    width: 2.0, // Adjust the border width as needed
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                filled: true,
                fillColor: _getFillColor(_focusNodeIrp.hasFocus),
                hintText: 'Percentage i/p Ripple Current (Irp) (optional)',
                hintMaxLines: 2,
                hintStyle: _getHintStyle(_focusNodeIrp.hasFocus),
                helperText:
                    'Enter the desired input ripple current percentage of converter. Eg.: 40',
                helperMaxLines: 2,
                helperStyle: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontMono', fontSize: 10),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
              ],
              style: const TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              onEditingComplete: () {
                FocusScope.of(context).nextFocus();
              },
              focusNode: _focusNodeIrp,
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: vrp,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .primary, // Change this to your desired color
                    width: 2.0, // Adjust the border width as needed
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                filled: true,
                fillColor: _getFillColor(_focusNodeVrp.hasFocus),
                hintText: 'Percentage o/p Ripple Voltage (Vrp)',
                hintStyle: _getHintStyle(_focusNodeVrp.hasFocus),
                helperText:
                    'Enter the desired output ripple voltage percentage of converter. Eg.: 0.5',
                helperMaxLines: 2,
                helperStyle: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontMono', fontSize: 10),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
              ],
              style: const TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
              onEditingComplete: () {
                FocusScope.of(context).nextFocus();
              },
              focusNode: _focusNodeVrp,
            ),
            const SizedBox(
              height: 16.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 1.0,
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _initiateCalculateSpecs,
                    child: const Text(
                      'Calculate',
                      style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
                    )),
                const SizedBox(
                  width: 16.0,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 1.0,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _clear,
                    child: const Text(
                      'Clear',
                      style: TextStyle(fontFamily: 'FiraCodeNerdFontPropo'),
                    ))
              ],
            ),
            const SizedBox(
              height: 16.0,
            ),
            // Text(mainOp),
            Card(
              elevation: 15,
              shadowColor: Theme.of(context).colorScheme.secondary,
              surfaceTintColor: Theme.of(context).colorScheme.secondary,
              child: Scrollbar(
                thumbVisibility: true,
                controller: scrollOp,
                child: SizedBox(
                  width: 500,
                  height: 510,
                  // padding: const EdgeInsets.all(12),
                  child: Center(
                    child: SingleChildScrollView(
                      controller: scrollOp,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(12),
                      child: _mainOpInitialized
                          ? Text(
                              mainOp,
                              style: const TextStyle(
                                  fontFamily: 'FiraCodeNerdFontMono',
                                  fontWeight: FontWeight.w200),
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
