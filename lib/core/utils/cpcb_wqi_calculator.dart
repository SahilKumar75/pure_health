import 'dart:math' as math;

/// CPCB-Compliant Water Quality Index Calculator
/// Based on National Sanitation Foundation (NSF) WQI with modifications by
/// Central Pollution Control Board (CPCB) for Indian water quality standards.
/// 
/// Reference: Maharashtra Water Quality Status Report 2023-24, MPCB
/// 
/// Parameters used:
/// - Dissolved Oxygen (DO) - mg/l
/// - Fecal Coliform (FC) - MPN/100ml
/// - pH
/// - Biochemical Oxygen Demand (BOD) - mg/l
class CPCBWQICalculator {
  /// Modified weights as per CPCB (Central Pollution Control Board)
  static const double _weightDO = 0.31;  // Dissolved Oxygen
  static const double _weightFC = 0.28;  // Fecal Coliform
  static const double _weightPH = 0.22;  // pH
  static const double _weightBOD = 0.19; // BOD
  
  /// DO saturation constant (standard value as per CPCB)
  static const double _doSaturationConstant = 6.5;
  
  /// Calculate Water Quality Index
  /// Returns WQI value (0-100) and classification
  static WQIResult calculateWQI({
    required double dissolvedOxygen, // mg/l
    required double fecalColiform,   // MPN/100ml
    required double ph,
    required double bod,             // mg/l
    double? temperature,             // Optional for DO saturation adjustment
  }) {
    // Calculate sub-indices
    final doSubIndex = _calculateDOSubIndex(dissolvedOxygen, temperature);
    final fcSubIndex = _calculateFCSubIndex(fecalColiform);
    final phSubIndex = _calculatePHSubIndex(ph);
    final bodSubIndex = _calculateBODSubIndex(bod);
    
    // Calculate weighted indices
    final doIndex = doSubIndex * _weightDO;
    final fcIndex = fcSubIndex * _weightFC;
    final phIndex = phSubIndex * _weightPH;
    final bodIndex = bodSubIndex * _weightBOD;
    
    // Calculate final WQI
    final wqi = doIndex + fcIndex + phIndex + bodIndex;
    
    // Clamp to 0-100 range
    final finalWQI = wqi.clamp(0.0, 100.0);
    
    // Get classification
    final classification = _getClassification(finalWQI);
    final cpcbClass = _getCPCBClass(finalWQI);
    final mpcbClass = _getMPCBClass(finalWQI);
    final status = _getStatus(finalWQI);
    
    return WQIResult(
      wqi: finalWQI,
      classification: classification,
      cpcbClass: cpcbClass,
      mpcbClass: mpcbClass,
      status: status,
      subIndices: WQISubIndices(
        dissolvedOxygen: doSubIndex,
        fecalColiform: fcSubIndex,
        ph: phSubIndex,
        bod: bodSubIndex,
      ),
      weightedIndices: WQIWeightedIndices(
        dissolvedOxygen: doIndex,
        fecalColiform: fcIndex,
        ph: phIndex,
        bod: bodIndex,
      ),
    );
  }
  
  /// Calculate Dissolved Oxygen Sub-Index
  /// Formula varies based on % saturation range
  static double _calculateDOSubIndex(double doValue, double? temperature) {
    // Convert DO to % saturation
    // DO saturation constant adjusted by temperature if provided
    double saturationConstant = _doSaturationConstant;
    if (temperature != null) {
      // Temperature correction (simplified)
      // Higher temp = lower DO saturation capacity
      saturationConstant = _doSaturationConstant * (1 - ((temperature - 20) * 0.015));
      saturationConstant = saturationConstant.clamp(4.0, 9.0);
    }
    
    final doSaturationPercent = (doValue / saturationConstant) * 100;
    
    double subIndex;
    
    if (doSaturationPercent >= 0 && doSaturationPercent <= 40) {
      // Range: 0-40%
      subIndex = 0.18 + (0.66 * doSaturationPercent);
    } else if (doSaturationPercent > 40 && doSaturationPercent <= 100) {
      // Range: 40-100%
      subIndex = -13.55 + (1.17 * doSaturationPercent);
    } else if (doSaturationPercent > 100 && doSaturationPercent <= 140) {
      // Range: 100-140%
      subIndex = 163.34 - (0.62 * doSaturationPercent);
    } else {
      // Outside range
      subIndex = doSaturationPercent > 140 ? 50.0 : 2.0;
    }
    
    return subIndex.clamp(0.0, 100.0);
  }
  
  /// Calculate Fecal Coliform Sub-Index
  /// Formula varies based on count range
  static double _calculateFCSubIndex(double fcValue) {
    // Handle zero or very low values
    if (fcValue < 1) {
      return 97.0; // Excellent quality
    }
    
    double subIndex;
    
    if (fcValue >= 1 && fcValue <= 1000) {
      // Range: 1 - 10³
      final logFC = math.log(fcValue) / math.ln10; // log base 10
      subIndex = 97.2 - (26.6 * logFC);
    } else if (fcValue > 1000 && fcValue <= 100000) {
      // Range: 10³ - 10⁵
      final logFC = math.log(fcValue) / math.ln10;
      subIndex = 42.33 - (7.75 * logFC);
    } else {
      // Range: > 10⁵
      subIndex = 2.0;
    }
    
    return subIndex.clamp(0.0, 100.0);
  }
  
  /// Calculate pH Sub-Index
  /// Formula varies based on pH range
  static double _calculatePHSubIndex(double phValue) {
    double subIndex;
    
    if (phValue >= 2 && phValue < 5) {
      // Range: 2-5
      subIndex = 16.1 + (7.35 * phValue);
    } else if (phValue >= 5 && phValue < 7.3) {
      // Range: 5-7.3
      subIndex = -142.67 + (33.5 * phValue);
    } else if (phValue >= 7.3 && phValue <= 10) {
      // Range: 7.3-10
      subIndex = 316.96 - (29.85 * phValue);
    } else if (phValue > 10 && phValue <= 12) {
      // Range: 10-12
      subIndex = 96.17 - (8.0 * phValue);
    } else {
      // Range: < 2 or > 12
      subIndex = 0.0;
    }
    
    return subIndex.clamp(0.0, 100.0);
  }
  
  /// Calculate BOD Sub-Index
  /// Formula varies based on BOD range
  static double _calculateBODSubIndex(double bodValue) {
    double subIndex;
    
    if (bodValue >= 0 && bodValue <= 10) {
      // Range: 0-10 mg/l
      subIndex = 96.67 - (7.0 * bodValue);
    } else if (bodValue > 10 && bodValue <= 30) {
      // Range: 10-30 mg/l
      subIndex = 38.9 - (1.23 * bodValue);
    } else {
      // Range: > 30 mg/l
      subIndex = 2.0;
    }
    
    return subIndex.clamp(0.0, 100.0);
  }
  
  /// Get water quality classification based on WQI
  static String _getClassification(double wqi) {
    if (wqi >= 63) return 'Good to Excellent';
    if (wqi >= 50) return 'Medium to Good';
    if (wqi >= 38) return 'Bad';
    return 'Bad to Very Bad';
  }
  
  /// Get CPCB class
  static String _getCPCBClass(double wqi) {
    if (wqi >= 63) return 'A';
    if (wqi >= 50) return 'B';
    if (wqi >= 38) return 'C';
    return wqi >= 25 ? 'D' : 'E';
  }
  
  /// Get MPCB class
  static String _getMPCBClass(double wqi) {
    if (wqi >= 63) return 'A-I';
    if (wqi >= 38) return 'A-II';
    return wqi >= 25 ? 'A-III' : 'A-IV';
  }
  
  /// Get pollution status
  static String _getStatus(double wqi) {
    if (wqi >= 50) return 'Non Polluted';
    if (wqi >= 38) return 'Polluted';
    return 'Heavily Polluted';
  }
  
  /// Validate parameters are within realistic ranges
  static ValidationResult validateParameters({
    required double dissolvedOxygen,
    required double fecalColiform,
    required double ph,
    required double bod,
  }) {
    final issues = <String>[];
    
    if (dissolvedOxygen < 0 || dissolvedOxygen > 20) {
      issues.add('Dissolved Oxygen out of realistic range (0-20 mg/l)');
    }
    
    if (fecalColiform < 0 || fecalColiform > 1000000) {
      issues.add('Fecal Coliform out of realistic range (0-1,000,000 MPN/100ml)');
    }
    
    if (ph < 0 || ph > 14) {
      issues.add('pH out of valid range (0-14)');
    }
    
    if (bod < 0 || bod > 100) {
      issues.add('BOD out of realistic range (0-100 mg/l)');
    }
    
    return ValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }
}

/// WQI Calculation Result
class WQIResult {
  final double wqi;
  final String classification;
  final String cpcbClass;
  final String mpcbClass;
  final String status;
  final WQISubIndices subIndices;
  final WQIWeightedIndices weightedIndices;
  
  const WQIResult({
    required this.wqi,
    required this.classification,
    required this.cpcbClass,
    required this.mpcbClass,
    required this.status,
    required this.subIndices,
    required this.weightedIndices,
  });
  
  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'wqi': wqi,
    'classification': classification,
    'cpcbClass': cpcbClass,
    'mpcbClass': mpcbClass,
    'status': status,
    'subIndices': subIndices.toJson(),
    'weightedIndices': weightedIndices.toJson(),
  };
  
  @override
  String toString() => 'WQI: ${wqi.toStringAsFixed(2)} - $classification ($status)';
}

/// Sub-index values (before applying weights)
class WQISubIndices {
  final double dissolvedOxygen;
  final double fecalColiform;
  final double ph;
  final double bod;
  
  const WQISubIndices({
    required this.dissolvedOxygen,
    required this.fecalColiform,
    required this.ph,
    required this.bod,
  });
  
  Map<String, dynamic> toJson() => {
    'dissolvedOxygen': dissolvedOxygen,
    'fecalColiform': fecalColiform,
    'ph': ph,
    'bod': bod,
  };
}

/// Weighted index values (after applying CPCB weights)
class WQIWeightedIndices {
  final double dissolvedOxygen;
  final double fecalColiform;
  final double ph;
  final double bod;
  
  const WQIWeightedIndices({
    required this.dissolvedOxygen,
    required this.fecalColiform,
    required this.ph,
    required this.bod,
  });
  
  Map<String, dynamic> toJson() => {
    'dissolvedOxygen': dissolvedOxygen,
    'fecalColiform': fecalColiform,
    'ph': ph,
    'bod': bod,
  };
  
  double get total => dissolvedOxygen + fecalColiform + ph + bod;
}

/// Parameter validation result
class ValidationResult {
  final bool isValid;
  final List<String> issues;
  
  const ValidationResult({
    required this.isValid,
    required this.issues,
  });
}

/// WQI Classification Thresholds
class WQIThresholds {
  static const double excellentMin = 63.0;
  static const double goodMin = 50.0;
  static const double badMin = 38.0;
  static const double veryBadMax = 38.0;
  
  static const String classA = 'A';    // 63-100: Good to Excellent
  static const String classB = 'B';    // 50-63: Medium to Good
  static const String classC = 'C';    // 38-50: Bad
  static const String classD = 'D';    // 25-38: Bad to Very Bad
  static const String classE = 'E';    // 0-25: Very Bad
}
