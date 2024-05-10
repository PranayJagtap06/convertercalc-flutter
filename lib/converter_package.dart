import 'dart:math';

/// Specifications of Buck Converter.
/// ---
///
/// Returning duty cycle, input current/ inductor current, critical inductance, inductor
/// rating, inductor ripple current, capcitor rating & capacitor ripple voltage
/// for Buck Converter.
class Bucklc {
  /// This function calculates duty cycle of a buck converter.
  ///
  /// Parameters
  /// ---
  /// vin: The input voltage of buck converter.
  ///
  /// vo: The output voltage of buck converter.
  ///
  /// Returns
  /// ---
  /// Value of duty cycle.
  num dutyCycle(num vin, num vo) {
    num d = vo / vin;
    return d;
  }

  /// This function calculates Input Current in Buck Mode.
  ///
  /// Parameters
  /// ---
  /// D : Duty cycle of converter.
  ///
  /// iO: Output current of converter.
  ///
  /// Returns
  /// ---
  /// Value of average input curent in converter.
  num bckIpCurrent(num D, num iO) {
    num iIP = D * iO;
    return iIP;
  }

  /// For Ripple Current in Buck Mode.
  ///
  /// Parameters
  /// ---
  /// iL: Current through inductor in buck mode.
  ///
  /// iRp: Given percentage of ripple current.
  ///
  /// Returns
  /// ---
  /// Value of ripple current for given value of precentage ripple current.
  num bckRiplCurrent(num iL, num iRp) {
    num iRipl = iL * (iRp / 100);
    return iRipl;
  }

  /// Inductor Ripple Current.
  ///
  /// Parameters
  /// ---
  /// vo: Output voltage.
  ///
  /// D: Duty cycle.
  ///
  /// fsw: Operating Frequency.
  ///
  /// ind: Inductor Value.
  ///
  /// Returns
  /// ---
  /// Inductor ripple current value.
  num bckIndRiplI(num vo, num D, num fsw, num ind) {
    num indI = (vo * (1 - D)) / (ind * fsw);
    return indI;
  }

  /// Critical Inductance in Buck Mode.
  ///
  /// Parameters
  /// ---
  /// D : Duty cycle of converter.
  ///
  /// R : Value of output resistance.
  ///
  /// fsw: Operating Frequency.
  ///
  /// Return
  /// ---
  /// Value of critical indcuatance or minimum value of inductance required for
  /// continuous current through the inductor.
  num bckLCr(num D, num R, num fsw) {
    num lCr = ((1 - D) * R) / (2 * fsw);
    return lCr;
  }

  /// Inductor Value in Buck Mode.
  ///
  /// Parameters
  /// ---
  /// vo: Output voltage.
  ///
  /// D = Duty cycle.
  ///
  /// fsw: Operating frequency.
  ///
  /// iripl: Ripple current.
  ///
  /// Returns
  /// -------
  /// Required inductor value for maintaining continuous conduction mode of converter.
  num bckLCont(num vo, num D, num fsw, num iripl) {
    num lCont = (vo * (1 - D)) / (fsw * iripl);
    return lCont;
  }

  /// Capacitor Value in Buck Mode.
  ///
  /// Parameters
  /// ---
  /// D: Duty cycle.
  ///
  /// ind: Inductor value.
  ///
  /// vrp: Output voltage ripple.
  ///
  /// fsw: Operating frequency.
  ///
  /// Returns
  /// ---
  /// Capacitor value.
  num bckCap(num D, num ind, num vrp, num fsw) {
    num cap = (1 - D) / (8 * ind * pow(fsw, 2) * (vrp / 100));
    return cap;
  }

  /// Effective Series Resistance of the filte capacitor.
  ///
  /// Parameters
  /// ----------
  /// vrp : % Ripple Voltage.
  ///
  /// vo : Output Voltage.
  ///
  /// indRiplI : Inductor ripple current.
  ///
  /// Returns
  /// -------
  /// Value of ESR.
  num bckEsr(num vrp, num vo, num indRiplI) {
    num esr = ((vrp / 100) * vo) / indRiplI;
    return esr;
  }
}

/// Specifications of Boost Converter.
/// ---
///
/// Returning duty cycle, input current/ inductor current, critical inductance, inductor
/// rating, inductor ripple current, capcitor rating & capacitor ripple voltage
/// for Boost Converter.
class Boostlc {
  /// This function calculates duty cycle of a boost converter.
  ///
  /// Parameters
  /// ---
  /// vin: The input voltage of buck converter.
  ///
  /// vo: The output voltage of buck converter.
  ///
  /// Returns
  /// ---
  /// Value of duty cycle.
  num dutyCycle(num vin, num vo) {
    num d = (vo - vin) / vo;
    return d;
  }

  /// This function calculates Inductor Current in Boost Mode.
  ///
  /// Parameters
  /// ---
  /// D : Duty cycle of converter.
  ///
  /// iO: Output current of converter.
  ///
  /// Returns
  /// ---
  /// Value of average inductor curent in converter.
  num bstIndCurrent(num D, num iO) {
    num indI = iO / (1 - D);
    return indI;
  }

  /// For Ripple Current in Boost Mode.
  ///
  /// Parameters
  /// ---
  /// iL: Current through inductor in boost mode.
  ///
  /// iRp: Given percentage of ripple current.
  ///
  /// Returns
  /// ---
  /// Value of ripple current for given value of precentage ripple current.
  num bstRiplCurrent(num iL, num iRp) {
    num iRipl = iL * (iRp / 100);
    return iRipl;
  }

  /// Inductor Ripple Current.
  ///
  /// Parameters
  /// ---
  /// vin: Input voltage.
  ///
  /// D: Duty cycle.
  ///
  /// fsw: Operating Frequency.
  ///
  /// ind: Inductor Value.
  ///
  /// Returns
  /// ---
  /// Inductor ripple current value.
  num bstIndRiplI(num vin, num D, num fsw, num ind) {
    num indI = (vin * D) / (ind * fsw);
    return indI;
  }

  /// Critical Inductance in Boost Mode.
  ///
  /// Parameters
  /// ---
  /// D : Duty cycle of converter.
  ///
  /// R : Value of output resistance.
  ///
  /// fsw: Operating Frequency.
  ///
  /// Return
  /// ---
  /// Value of critical indcuatance or minimum value of inductance required for
  /// continuous current through the inductor.
  num bstLCr(num D, num R, num fsw) {
    num lCr = (D * pow((1 - D), 2) * R) / (2 * fsw);
    return lCr;
  }

  /// Inductor Value in Boost Mode.
  ///
  /// Parameters
  /// ---
  /// vin: Input voltage.
  ///
  /// D = Duty cycle.
  ///
  /// fsw: Operating frequency.
  ///
  /// iripl: Ripple current.
  ///
  /// Returns
  /// -------
  /// Required inductor value for maintaining continuous conduction mode of converter.
  num bstLCont(num vin, num D, num fsw, num iripl) {
    num lCont = (vin * D) / (fsw * iripl);
    return lCont;
  }

  /// Capacitor Value in Boost Mode.
  ///
  /// Parameters
  /// ---
  /// D: Duty cycle.
  ///
  /// ind: Inductor value.
  ///
  /// vrp: Output voltage ripple.
  ///
  /// fsw: Operating frequency.
  ///
  /// Returns
  /// ---
  /// Capacitor value.
  num bstCap(num D, num R, num vrp, num fsw) {
    num cap = D / (R * fsw * (vrp / 100));
    return cap;
  }

  /// Effective Series Resistance of the filte capacitor.
  ///
  /// Parameters
  /// ----------
  /// vrp : % Ripple Voltage.
  ///
  /// vo : Output Voltage.
  ///
  /// indRiplI : Inductor ripple current.
  ///
  /// Returns
  /// -------
  /// Value of ESR.
  num bstEsr(num vrp, num vo, num indRiplI) {
    num esr = ((vrp / 100) * vo) / indRiplI;
    return esr;
  }
}

/// Specifications of BuckBoost Converter.
/// ---
///
/// Returning duty cycle, input current/ inductor current, critical inductance, inductor
/// rating, inductor ripple current, capcitor rating & capacitor ripple voltage
/// for BuckBoost Converter.
class BuckBoostlc {
  /// This function calculates duty cycle of a buckboost converter.
  ///
  /// Parameters
  /// ---
  /// vin: The input voltage of buck converter.
  ///
  /// vo: The output voltage of buck converter.
  ///
  /// Returns
  /// ---
  /// Value of duty cycle.
  num dutyCycle(num vin, num vo) {
    num d = vo / (vo + vin);
    return d;
  }

  /// This function calculates Inductor Current in BuckBoost Mode.
  ///
  /// Parameters
  /// ---
  /// D : Duty cycle of converter.
  ///
  /// iO: Output current of converter.
  ///
  /// Returns
  /// ---
  /// Value of average inductor curent in converter.
  num bbIndCurrent(num D, num iO) {
    num indI = iO / (1 - D);
    return indI;
  }

  /// For Ripple Current in BuckBoost Mode.
  ///
  /// Parameters
  /// ---
  /// iL: Current through inductor in buckboost mode.
  ///
  /// iRp: Given percentage of ripple current.
  ///
  /// Returns
  /// ---
  /// Value of ripple current for given value of precentage ripple current.
  num bbRiplCurrent(num iL, num iRp) {
    num iRipl = iL * (iRp / 100);
    return iRipl;
  }

  /// Inductor Ripple Current.
  ///
  /// Parameters
  /// ---
  /// vin: Input voltage.
  ///
  /// D: Duty cycle.
  ///
  /// fsw: Operating Frequency.
  ///
  /// ind: Inductor Value.
  ///
  /// Returns
  /// ---
  /// Inductor ripple current value.
  num bbIndRiplI(num vin, num D, num fsw, num ind) {
    num indI = (vin * D) / (ind * fsw);
    return indI;
  }

  /// Critical Inductance in BuckBoost Mode.
  ///
  /// Parameters
  /// ---
  /// D : Duty cycle of converter.
  ///
  /// R : Value of output resistance.
  ///
  /// fsw: Operating Frequency.
  ///
  /// Return
  /// ---
  /// Value of critical indcuatance or minimum value of inductance required for
  /// continuous current through the inductor.
  num bbLCr(num D, num R, num fsw) {
    num lCr = (pow((1 - D), 2) * R) / (2 * fsw);
    return lCr;
  }

  /// Inductor Value in BuckBoost Mode.
  ///
  /// Parameters
  /// ---
  /// vin: Input voltage.
  ///
  /// D = Duty cycle.
  ///
  /// fsw: Operating frequency.
  ///
  /// iripl: Ripple current.
  ///
  /// Returns
  /// -------
  /// Required inductor value for maintaining continuous conduction mode of converter.
  num bbLCont(num vin, num D, num fsw, num iripl) {
    num lCont = (vin * D) / (fsw * iripl);
    return lCont;
  }

  /// Capacitor Value in BuckBoost Mode.
  ///
  /// Parameters
  /// ---
  /// D: Duty cycle.
  ///
  /// ind: Inductor value.
  ///
  /// vrp: Output voltage ripple.
  ///
  /// fsw: Operating frequency.
  ///
  /// Returns
  /// ---
  /// Capacitor value.
  num bbCap(num D, num R, num vrp, num fsw) {
    num cap = D / (R * fsw * (vrp / 100));
    return cap;
  }

  /// Effective Series Resistance of the filte capacitor.
  ///
  /// Parameters
  /// ----------
  /// vrp : % Ripple Voltage.
  ///
  /// vo : Output Voltage.
  ///
  /// indRiplI : Inductor ripple current.
  ///
  /// Returns
  /// -------
  /// Value of ESR.
  num bbEsr(num vrp, num vo, num indRiplI) {
    num esr = ((vrp / 100) * vo) / indRiplI;
    return esr;
  }
}
