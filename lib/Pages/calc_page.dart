import 'dart:convert';
import 'dart:io';
import 'package:convertercalc_flutter/converter_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

class CalcPage extends StatefulWidget {
  const CalcPage({super.key});

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
      \tDuty Cycle = 0.0
      \tPower Input = 0.0W
      \tPower output = 0.0W
      \tOutput Current = 0.0A
      \tInductor Current = 0.0A
      \tInput Current = 0.0A
      \tCritical Inductance Value(Lcr)= 0.0H
      \tRipple Current due to Lcr = 0.0A
      \tContinuous Conduction Inductor Value (L) = 0.0H
      \tRipple Current due to L = 0.0A
      \tMaximum inductor ripple current = 0.0A
      \tMinimum inductor ripple current = 0.0A
      \tOutput Capacitor = 0.0F
      \tCapacitor ESR = 0.0Ohms""";

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
  }

  @override
  void dispose() {
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

  void _verifyIp() {
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
        } else {
          _showInvalidInputDialog('Invalid input for Irp');
        }
      } else {
        _showInvalidInputDialog('Please select a mode');
      }
    } catch (e) {
      // Handle invalid input
      _showInvalidInputDialog('Please enter a valid numeric value.');
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

  void _calulateSpecs() {
    setState(() {
      _verifyIp();

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
      \tMode = $_mode
      \tVin = ${num.parse(vin.text).toStringAsFixed(3)}V
      \tVo = ${num.parse(vo.text).toStringAsFixed(3)}V
      \tR = ${num.parse(ro.text).toStringAsFixed(3)}Ohms
      \tFrequency, fsw = ${num.parse(fsw.text).toStringAsFixed(3)}Hz
      \tIrp = ${ipIripl.text}A
      \tVrp = ${num.parse(vrp.text).toStringAsFixed(3)}""";

      opString = """Converter Parameters
       \tDuty Cycle = ${d.toStringAsFixed(3)}
       \tPower Input = ${ipPower.toStringAsFixed(3)}W
       \tPower output = ${opPower.toStringAsFixed(3)}W
       \tOutput Current = ${opI.toStringAsFixed(3)}A
       \tInductor Current = ${indI.toStringAsFixed(3)}A
       \tInput Current = ${ipI.toStringAsFixed(3)}A
       \tCritical Inductance Value(Lcr)= ${crL.toStringAsExponential(3)}H
       \tRipple Current due to Lcr = ${crIndRiplI.toStringAsFixed(3)}A
       \tContinuous Conduction Inductor Value (L) = ${ind.toStringAsExponential(3)}H
       \tRipple Current due to L = ${iRipl.toStringAsFixed(3)}A
       \tMaximum inductor ripple current = ${maxindI.toStringAsFixed(3)}A
       \tMinimum inductor ripple current = ${minindI.toStringAsFixed(3)}A
       \tOutput Capacitor = ${cap.toStringAsExponential(3)}F
       \tCapacitor ESR = ${esr.toStringAsFixed(5)}Ohms""";

      mainOp = opString;

      String history = '$ipString\n$opString';
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
                'Error occured while saving file.\nError: $e.',
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
  }

  void _clear() {
    setState(() {
      mainOp = """Converter Parameters
      \tDuty Cycle = 0.0
      \tPower Input = 0.0W
      \tPower output = 0.0W
      \tOutput Current = 0.0A
      \tInductor Current = 0.0A
      \tInput Current = 0.0A
      \tCritical Inductance Value(Lcr)= 0.0H
      \tRipple Current due to Lcr = 0.0A
      \tContinuous Conduction Inductor Value (L) = 0.0H
      \tRipple Current due to L = 0.0A
      \tMaximum inductor ripple current = 0.0A
      \tMinimum inductor ripple current = 0.0A
      \tOutput Capacitor = 0.0F
      \tCapacitor ESR = 0.0Ohms""";
    });
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
      ),
      body: SingleChildScrollView(
        controller: scrollMain,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              elevation: 10,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              dropdownColor: Theme.of(context).colorScheme.secondary,//Colors.grey[400],
              value: _mode,
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
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: vin,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                focusColor: Colors.blue[100],
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue, // Change this to your desired color
                    width: 2.0, // Adjust the border width as needed
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                filled: true,
                hintText: 'Input Voltage (Vin)',
                hintStyle: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontPropo', fontSize: 13),
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
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: vo,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                focusColor: Colors.blue[100],
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue, // Change this to your desired color
                    width: 2.0, // Adjust the border width as needed
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                filled: true,
                hintText: 'Output Voltage (Vo)',
                hintStyle: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontPropo', fontSize: 13),
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
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: ro,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                focusColor: Colors.blue[100],
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue, // Change this to your desired color
                    width: 2.0, // Adjust the border width as needed
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                filled: true,
                hintText: 'Output Resistance (Ro)',
                hintStyle: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontPropo', fontSize: 13),
                helperText:
                    'Enter the desired output resistance of converter.',
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
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: fsw,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                focusColor: Colors.blue[100],
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue, // Change this to your desired color
                    width: 2.0, // Adjust the border width as needed
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                filled: true,
                hintText: 'Operating Frequncy (fsw)',
                hintStyle: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontPropo', fontSize: 13),
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
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: ipIripl,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                focusColor: Colors.blue[100],
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue, // Change this to your desired color
                    width: 2.0, // Adjust the border width as needed
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                filled: true,
                hintText: 'Percentage i/p Ripple Current (Irp)',
                hintStyle: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontPropo', fontSize: 13),
                helperText:
                    'Enter the desired input ripple current percentage of converter.',
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
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: vrp,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                focusColor: Colors.blue[100],
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue, // Change this to your desired color
                    width: 2.0, // Adjust the border width as needed
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                filled: true,
                hintText: 'Percentage o/p Ripple Voltage (Vrp)',
                hintStyle: const TextStyle(
                    fontFamily: 'FiraCodeNerdFontPropo', fontSize: 13),
                helperText:
                    'Enter the desired output ripple voltage percentage of converter.',
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
                    onPressed: _calulateSpecs,
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
                child: SingleChildScrollView(
                  controller: scrollOp,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    mainOp,
                    style: const TextStyle(
                        fontFamily: 'FiraCodeNerdFontMono',
                        fontWeight: FontWeight.w200),
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
