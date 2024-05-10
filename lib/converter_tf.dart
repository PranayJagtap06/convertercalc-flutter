String returnTF(
  String mode,
  num vin,
  num D,
  num ro,
  num ind,
  num cap,
) {
  String tf = '';
  switch (mode) {
    case 'Boost':
      tf = boostResponse(D, vin, ind, cap, ro);
    case 'Buck':
      tf = buckResponse(D, vin, ind, cap, ro);
    case 'BuckBoost':
      tf = buckBoostResponse(D, vin, ind, cap, ro);
  }

  return tf;
}

String buckResponse(num d, num vin, num inductor, num capacitor, num resistor) {
  List<num> numVg = [(d * vin) / (inductor * capacitor)];
  List<num> denVg = [1, 1 / (resistor * capacitor), 1 / (inductor * capacitor)];

  String sys = transferFunction(numVg, denVg);
  return sys;
}

String boostResponse(
    num d, num vin, num inductor, num capacitor, num resistor) {
  List<num> numVg = [((1 - d) * vin) / (inductor * capacitor)];
  List<num> denVg = [
    1,
    1 / (resistor * capacitor),
    ((1 - d) * (1 - d)) / (inductor * capacitor)
  ];

  String sys = transferFunction(numVg, denVg);
  return sys;
}

String buckBoostResponse(
    num d, num vin, num inductor, num capacitor, num resistor) {
  List<num> numVg = [-(((1 - d) * d) * vin) / (inductor * capacitor)];
  List<num> denVg = [
    1,
    1 / (resistor * capacitor),
    ((1 - d) * (1 - d)) / (inductor * capacitor)
  ];

  String sys = transferFunction(numVg, denVg);
  return sys;
}

String transferFunction(List<num> numerator, List<num> denominator) {
  String numStr = '';
  if (numerator.length == 1) {
    numStr = '$numStr${numerator[0].toStringAsExponential(2)}';
  } else {
    for (int i = 0; i < numerator.length; i++) {
      if (i == 0) {
        numStr =
            '$numStr${numerator[i].toStringAsExponential(2)} s^${numerator.length - i - 1}';
      } else {
        if (numerator.length - i - 1 == 1) {
          numStr = '$numStr + ${numerator[i].toStringAsExponential(2)} s';
        } else if (numerator.length - i - 1 == 0) {
          numStr = '$numStr + ${numerator[i].toStringAsExponential(2)}';
        } else {
          numStr =
              '$numStr + ${numerator[i].toStringAsExponential(2)} s^${numerator.length - i - 1}';
        }
      }
    }
  }

  String denStr = '';
  if (denominator.length == 1) {
    denStr = '$denStr${denominator[0].toStringAsExponential(2)}';
  } else {
    for (int i = 0; i < denominator.length; i++) {
      if (i == 0) {
        denStr =
            '$denStr${denominator[i].toStringAsExponential(2)} s^${denominator.length - i - 1}';
      } else {
        if (denominator.length - i - 1 == 1) {
          denStr = '$denStr + ${denominator[i].toStringAsExponential(2)} s';
        } else if (denominator.length - i - 1 == 0) {
          denStr = '$denStr + ${denominator[i].toStringAsExponential(2)}';
        } else {
          denStr =
              '$denStr + ${denominator[i].toStringAsExponential(2)} s^${denominator.length - i - 1}';
        }
      }
    }
  }
  return 'H(s) = \n\t$numStr\n-----------------------------------\n\t$denStr';
}
