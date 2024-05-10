import 'dart:io';
import 'converter_package.dart';
import 'dart:convert';
import 'dart:async';

Future<void> main() async {
  String filePath = 'calc_hist.json';
  List<dynamic> histList = await loadOrCreateJsonFile(filePath);
  var prompt = true;
  String mode;
  num vin;
  num vo;
  num r;
  num fsw;
  num vrp;
  String ipIripl = '';
  while (prompt) {
    while (true) {
      stdout.write("Select converter mode (boost, buck, buckboost): ");
      mode = stdin.readLineSync()!;
      if ((mode == 'boost') || (mode == 'buck') || (mode == 'buckboost')) {
        break;
      } else {
        stdout.write('Invalid mode! Please select a valid mode. Try again.\n');
      }
    }
    // stdout.write("Enter vin: ");
    // final num vin = num.parse(stdin.readLineSync()!);
    // stdout.write("Enter vo: ");
    // final num vo = num.parse(stdin.readLineSync()!);
    // stdout.write("Enter R: ");
    // final num r = num.parse(stdin.readLineSync()!);
    // stdout.write("Enter fsw: ");
    // final num fsw = num.parse(stdin.readLineSync()!);
    // stdout.write("Enter i/p ripple I (optional): ");
    // final String ipIripl = stdin.readLineSync()!;
    // stdout.write("Enter o/p ripple voltage: ");
    // final num vrp = num.parse(stdin.readLineSync()!);

    
    while (true) {
      stdout.write("Enter vin: ");
      final input = stdin.readLineSync()!;
      try {
        vin = num.parse(input);
        break;
      } catch (e) {
        stdout.write('Invalid input. Please enter a valid number for vin.\n');
      }
    }

    
    while (true) {
      stdout.write("Enter vo: ");
      final input = stdin.readLineSync()!;
      try {
        vo = num.parse(input);
        break;
      } catch (e) {
        stdout.write('Invalid input. Please enter a valid number for vo.\n');
      }
    }

    
    while (true) {
      stdout.write("Enter R: ");
      final input = stdin.readLineSync()!;
      try {
        r = num.parse(input);
        break;
      } catch (e) {
        stdout.write('Invalid input. Please enter a valid number for R.\n');
      }
    }

    
    while (true) {
      stdout.write("Enter fsw: ");
      final input = stdin.readLineSync()!;
      try {
        fsw = num.parse(input);
        break;
      } catch (e) {
        stdout.write('Invalid input. Please enter a valid number for fsw.\n');
      }
    }

    
    while (true) {
      stdout.write("Enter o/p ripple voltage: ");
      final input = stdin.readLineSync()!;
      try {
        vrp = num.parse(input);
        break;
      } catch (e) {
        stdout.write('Invalid input. Please enter a valid number for vrp.\n');
      }
    }

    
    while (true) {
      stdout.write("Enter i/p ripple I (optional): ");
      final input = stdin.readLineSync()!;
      if (input.isEmpty) {
        ipIripl = '';
        break;
      } else {
        try {
          final ipIriplNum = num.parse(input);
          ipIripl = ipIriplNum.toString();
          break;
        } catch (e) {
          stdout.write('Invalid input. Please enter a valid number for i/p ripple I.\n');
        }
      }
    }

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
    ] = specs(mode, vin, vo, r, fsw, ipIripl, vrp);

    String ipString = """Converter Parameters
      \tMode = $mode
      \tVin = ${vin.toStringAsFixed(3)}V
      \tVo = ${vo.toStringAsFixed(3)}V
      \tR = ${r.toStringAsFixed(3)}Ohms
      \tFrequency, fsw = ${fsw.toStringAsFixed(3)}Hz
      \tIrp = ${ipIripl}A
      \tVrp = ${vrp.toStringAsFixed(3)}""";

    String opString =
        // """\nConverter Parameters\n\tDuty Cycle = ${d.toStringAsFixed(3)}\n\tPower Input = ${ipPower.toStringAsFixed(3)}W\n\tPower output = ${opPower.toStringAsFixed(3)}W\n\tOutput Current = ${opI.toStringAsFixed(3)}A\n\tInductor Current = ${indI.toStringAsFixed(3)}A\n\tInput Current = ${ipI.toStringAsFixed(3)}A\n\tCritical Inductance Value(Lcr)= ${crL.toStringAsExponential(3)}H\n\tRipple Current due to Lcr = ${crIndRiplI.toStringAsFixed(3)}A\n\tContinuous Conduction Inductor Value (L) = ${ind.toStringAsExponential(3)}H\n\tRipple Current due to L = ${iRipl.toStringAsFixed(3)}A\n\tMaximum inductor ripple current = ${maxindI.toStringAsFixed(3)}A\n\tMinimum inductor ripple current = ${minindI.toStringAsFixed(3)}A\n\tOutput Capacitor = ${cap.toStringAsExponential(3)}F\n\tCapacitor ESR = ${esr.toStringAsFixed(5)}Ohms""";
        """\nConverter Parameters
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
       \tCapacitor ESR = ${esr.toStringAsFixed(5)}Ohms\n\n""";

    stdout.write(opString);

    String history = '$ipString$opString';

    int srNo = histList.length + 1;
    var histMap = {'no': srNo, 'hist': history};
    histList.add(histMap);
    saveListToJsonFile(histList, filePath);

    while (true) {
      stdout.write(
          "Press entre to continue, 'h' for history, 'd' for deleting history or 'q' to quit: ");
      String cmd = stdin.readLineSync()!;
      if (cmd == 'q') {
        prompt = false;
        break;
      }
      else if (cmd == 'h') {
        stdout.write('Converter History\n-----------------\n');
        for (var item in histList) {
          stdout.write("Sr.No.: ${item['no']}\n${item['hist']}\n\n");
        }
        // continue;
      }
      else if (cmd == 'd') {
        if (histList.isNotEmpty) {
          histList.removeRange(0, histList.length);
          saveListToJsonFile(histList, filePath);
          histList = await loadOrCreateJsonFile(filePath);
          stdout.write('History deleted!\n\n');
        } else {
          stdout.write('History is empty! Can not delete more.\n\n');
        }
      } else {
        break;
      }
    }
  }
}

void saveListToJsonFile(List<dynamic> list, String filePath) {
  // Encode the List to a JSON string
  String jsonString = jsonEncode(list);

  // Write the JSON string to a file
  File file = File(filePath);
  file.writeAsStringSync(jsonString);
}

Future<List<dynamic>> loadOrCreateJsonFile(String filePath) async {
  File file = File(filePath);

  // Check if the file exists
  if (!file.existsSync()) {
    // Create the file with an empty list
    file.writeAsStringSync('[]');
  }

  // Read the JSON file
  String jsonString = await file.readAsString();

  // Decode the JSON string to a List
  List<dynamic> list = jsonDecode(jsonString);

  return list;
}

List<dynamic> specs(
    String mode, num vin, num vo, num r, num fsw, String ipIripl, num vrp) {
  switch (mode) {
    case 'buck':
      var buck = Bucklc();
      num d = buck.dutyCycle(vin, vo);
      // stdout.write('\n\nDuty Cycle: ${d.toStringAsFixed(2)}\n');
      num opI = vo / r;
      // stdout.write('Output Current: ${opI.toStringAsFixed(2)}A\n');
      num ipI = buck.bckIpCurrent(d, opI);
      // stdout.write('Input Current: ${ipI.toStringAsFixed(2)}A\n');
      num indI = opI;
      // stdout.write('Inductor Current: ${indI.toStringAsFixed(2)}A\n');
      num ipPower = vin * ipI;
      // stdout.write('Input Power: ${ipPower.toStringAsFixed(2)}W\n');
      num opPower = vo * opI;
      // stdout.write('Output Power: ${opPower.toStringAsFixed(2)}W\n');
      num crL = buck.bckLCr(d, r, fsw);
      // stdout.write('Critical Inductance: ${crL.toStringAsExponential(2)}H\n');
      num crIndRiplI = buck.bckIndRiplI(vo, d, fsw, crL);
      // stdout.write(
      // 'Ripple Current due to Lcr: ${crIndRiplI.toStringAsFixed(2)}A\n');
      num ind;
      num iRipl;
      if (ipIripl.isEmpty) {
        ind = crL * 1.25;
        // stdout.write('Inductor value: ${ind.toStringAsExponential(2)}H\n');
        iRipl = buck.bckIndRiplI(vo, d, fsw, ind);
        // stdout.write('Ripple Current: ${iRipl.toStringAsFixed(2)}A\n');
      } else {
        iRipl = buck.bckRiplCurrent(indI, num.parse(ipIripl));
        // stdout.write('Ripple Current: ${iRipl.toStringAsFixed(2)}A\n');
        ind = buck.bckLCont(vo, d, fsw, iRipl);
        // stdout.write('Inductor Value: ${ind.toStringAsExponential(2)}H\n');
      }
      num maxindI = indI + (iRipl / 2);
      // stdout.write('Max Inductor Current: ${maxindI.toStringAsFixed(2)}A\n');
      num minindI = indI - (iRipl / 2);
      // stdout.write('Min Inductor Current: ${minindI.toStringAsFixed(2)}A\n');
      num cap = buck.bckCap(d, ind, vrp, fsw);
      // stdout.write('Capacitor value: ${cap.toStringAsExponential(2)}F\n');
      num esr = buck.bckEsr(vrp, vo, iRipl);
      // stdout.write('ESR: ${esr.toStringAsFixed(6)}ohm\n');
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
    case 'boost':
      var boost = Boostlc();
      num d = boost.dutyCycle(vin, vo);
      // stdout.write('\n\nDuty Cycle: ${d.toStringAsFixed(2)}\n');
      num opI = vo / r;
      // stdout.write('Output Current: ${opI.toStringAsFixed(2)}A\n');
      num indI = boost.bstIndCurrent(d, opI);
      // stdout.write('Inductor Current: ${indI.toStringAsFixed(2)}A\n');
      num ipI = indI;
      // stdout.write('Input Current: ${ipI.toStringAsFixed(2)}A\n');
      num ipPower = vin * ipI;
      // stdout.write('Input Power: ${ipPower.toStringAsFixed(2)}W\n');
      num opPower = vo * opI;
      // stdout.write('Output Power: ${opPower.toStringAsFixed(2)}W\n');
      num crL = boost.bstLCr(d, r, fsw);
      // stdout.write('Critical Inductance: ${crL.toStringAsExponential(2)}H\n');
      num crIndRiplI = boost.bstIndRiplI(vin, d, fsw, crL);
      // stdout.write(
      // 'Ripple Current due to Lcr: ${crIndRiplI.toStringAsFixed(2)}A\n');
      num ind;
      num iRipl;
      if (ipIripl.isEmpty) {
        ind = crL * 1.25;
        // stdout.write('Inductor value: ${ind.toStringAsExponential(2)}H\n');
        iRipl = boost.bstIndRiplI(vin, d, fsw, ind);
        // stdout.write('Ripple Current: ${iRipl.toStringAsFixed(2)}A\n');
      } else {
        iRipl = boost.bstRiplCurrent(indI, num.parse(ipIripl));
        // stdout.write('Ripple Current: ${iRipl.toStringAsFixed(2)}A\n');
        ind = boost.bstLCont(vin, d, fsw, iRipl);
        // stdout.write('Inductor Value: ${ind.toStringAsExponential(2)}H\n');
      }
      num maxindI = indI + (iRipl / 2);
      // stdout.write('Max Inductor Current: ${maxindI.toStringAsFixed(2)}A\n');
      num minindI = indI - (iRipl / 2);
      // stdout.write('Min Inductor Current: ${minindI.toStringAsFixed(2)}A\n');
      num cap = boost.bstCap(d, r, vrp, fsw);
      // stdout.write('Capacitor value: ${cap.toStringAsExponential(2)}F\n');
      num esr = boost.bstEsr(vrp, vo, iRipl);
      // stdout.write('ESR: ${esr.toStringAsFixed(6)}ohm\n');
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
    case 'buckboost':
      var bckbst = BuckBoostlc();
      num d = bckbst.dutyCycle(vin, vo);
      // stdout.write('\n\nDuty Cycle: ${d.toStringAsFixed(2)}\n');
      num opI = vo / r;
      // stdout.write('Output Current: ${opI.toStringAsFixed(2)}A\n');
      num indI = bckbst.bbIndCurrent(d, opI);
      // stdout.write('Inductor Current: ${indI.toStringAsFixed(2)}A\n');
      num ipI = indI * d;
      // stdout.write('Input Current: ${ipI.toStringAsFixed(2)}A\n');
      num ipPower = vin * ipI;
      // stdout.write('Input Power: ${ipPower.toStringAsFixed(2)}W\n');
      num opPower = vo * opI;
      // stdout.write('Output Power: ${opPower.toStringAsFixed(2)}W\n');
      num crL = bckbst.bbLCr(d, r, fsw);
      // stdout.write('Critical Inductance: ${crL.toStringAsExponential(2)}H\n');
      num crIndRiplI = bckbst.bbIndRiplI(vin, d, fsw, crL);
      // stdout.write(
      // 'Ripple Current due to Lcr: ${crIndRiplI.toStringAsFixed(2)}A\n');
      num ind;
      num iRipl;
      if (ipIripl.isEmpty) {
        ind = crL * 1.25;
        // stdout.write('Inductor value: ${ind.toStringAsExponential(2)}H\n');
        iRipl = bckbst.bbIndRiplI(vin, d, fsw, ind);
        // stdout.write('Ripple Current: ${iRipl.toStringAsFixed(2)}A\n');
      } else {
        iRipl = bckbst.bbRiplCurrent(ipI, num.parse(ipIripl));
        // stdout.write('Ripple Current: ${iRipl.toStringAsFixed(2)}A\n');
        ind = bckbst.bbLCont(vin, d, fsw, iRipl);
        // stdout.write('Inductor Value: ${ind.toStringAsExponential(2)}H\n');
      }
      num maxindI = indI + (iRipl / 2);
      // stdout.write('Max Inductor Current: ${maxindI.toStringAsFixed(2)}A\n');
      num minindI = indI - (iRipl / 2);
      // stdout.write('Min Inductor Current: ${minindI.toStringAsFixed(2)}A\n');
      num cap = bckbst.bbCap(d, r, vrp, fsw);
      // stdout.write('Capacitor value: ${cap.toStringAsExponential(2)}F\n');
      num esr = bckbst.bbEsr(vrp, vo, iRipl);
      // stdout.write('ESR: ${esr.toStringAsFixed(6)}ohm\n');
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
