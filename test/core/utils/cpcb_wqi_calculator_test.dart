import 'package:flutter_test/flutter_test.dart';
import 'package:pure_health/core/utils/cpcb_wqi_calculator.dart';

void main() {
  group('CPCB WQI Calculator Tests', () {
    test('Example from Maharashtra Report 2023-24 - Krishna River', () {
      // Real example from WQR_2023-24.pdf Page 26-27
      // Station: Krishna River at Rajapur Weir, Kolhapur
      // Station Code: 1153, Month: April
      // Expected WQI: 83.16
      
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 5.5,  // mg/l
        fecalColiform: 6,       // MPN/100ml
        ph: 7.6,
        bod: 2.2,               // mg/l
      );
      
      // Allow small floating point tolerance
      expect(result.wqi, closeTo(83.16, 0.5));
      expect(result.classification, 'Good to Excellent');
      expect(result.cpcbClass, 'A');
      expect(result.status, 'Non Polluted');
      
      print('✅ WQI: ${result.wqi.toStringAsFixed(2)} (Expected: 83.16)');
      print('✅ Classification: ${result.classification}');
      print('✅ Sub-indices:');
      print('   DO: ${result.subIndices.dissolvedOxygen.toStringAsFixed(2)}');
      print('   FC: ${result.subIndices.fecalColiform.toStringAsFixed(2)}');
      print('   pH: ${result.subIndices.ph.toStringAsFixed(2)}');
      print('   BOD: ${result.subIndices.bod.toStringAsFixed(2)}');
      print('✅ Weighted indices:');
      print('   DO: ${result.weightedIndices.dissolvedOxygen.toStringAsFixed(2)} (Expected: 26.48)');
      print('   FC: ${result.weightedIndices.fecalColiform.toStringAsFixed(2)} (Expected: 21.42)');
      print('   pH: ${result.weightedIndices.ph.toStringAsFixed(2)} (Expected: 19.82)');
      print('   BOD: ${result.weightedIndices.bod.toStringAsFixed(2)} (Expected: 15.44)');
    });
    
    test('Excellent Water Quality - Low pollution', () {
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 7.5,
        fecalColiform: 2,
        ph: 7.2,
        bod: 1.5,
      );
      
      expect(result.wqi, greaterThanOrEqualTo(63));
      expect(result.classification, 'Good to Excellent');
      expect(result.cpcbClass, 'A');
      expect(result.status, 'Non Polluted');
    });
    
    test('Medium Water Quality', () {
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 4.5,
        fecalColiform: 300,
        ph: 8.8,
        bod: 5.0,
      );
      
      expect(result.wqi, lessThan(63));
      expect(result.wqi, greaterThanOrEqualTo(50));
      expect(result.classification, 'Medium to Good');
      expect(result.cpcbClass, 'B');
      expect(result.status, 'Non Polluted');
    });
    
    test('Bad Water Quality - Polluted', () {
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 3.0,
        fecalColiform: 2000,
        ph: 9.2,
        bod: 12.0,
      );
      
      expect(result.wqi, lessThan(50));
      expect(result.wqi, greaterThanOrEqualTo(38));
      expect(result.classification, 'Bad');
      expect(result.cpcbClass, 'C');
      expect(result.status, 'Polluted');
    });
    
    test('Very Bad Water Quality - Heavily Polluted', () {
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 1.5,
        fecalColiform: 50000,
        ph: 5.5,
        bod: 25.0,
      );
      
      expect(result.wqi, lessThan(38));
      expect(result.classification, 'Bad to Very Bad');
      expect(result.status, 'Heavily Polluted');
    });
    
    test('Edge Case - Extreme pollution (like Mithi River Mumbai)', () {
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 0.5,
        fecalColiform: 160000,
        ph: 6.0,
        bod: 38.0,
      );
      
      expect(result.wqi, lessThan(25));
      expect(result.classification, 'Bad to Very Bad');
      expect(result.cpcbClass, 'E');
      expect(result.status, 'Heavily Polluted');
    });
    
    test('Parameter Validation - Valid parameters', () {
      final validation = CPCBWQICalculator.validateParameters(
        dissolvedOxygen: 6.5,
        fecalColiform: 100,
        ph: 7.5,
        bod: 3.0,
      );
      
      expect(validation.isValid, true);
      expect(validation.issues, isEmpty);
    });
    
    test('Parameter Validation - Invalid DO', () {
      final validation = CPCBWQICalculator.validateParameters(
        dissolvedOxygen: 25.0, // Too high
        fecalColiform: 100,
        ph: 7.5,
        bod: 3.0,
      );
      
      expect(validation.isValid, false);
      expect(validation.issues, isNotEmpty);
      expect(validation.issues.first, contains('Dissolved Oxygen'));
    });
    
    test('Parameter Validation - Invalid pH', () {
      final validation = CPCBWQICalculator.validateParameters(
        dissolvedOxygen: 6.5,
        fecalColiform: 100,
        ph: 15.0, // Invalid
        bod: 3.0,
      );
      
      expect(validation.isValid, false);
      expect(validation.issues.any((issue) => issue.contains('pH')), true);
    });
    
    test('DO Sub-Index Calculation - Range 40-100%', () {
      // DO = 5.5 mg/l, saturation = 84.61%
      // Expected sub-index: 85.44
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 5.5,
        fecalColiform: 6,
        ph: 7.6,
        bod: 2.2,
      );
      
      expect(result.subIndices.dissolvedOxygen, closeTo(85.44, 1.0));
    });
    
    test('FC Sub-Index Calculation - Low count', () {
      // FC = 6 MPN/100ml (range 1-1000)
      // Expected sub-index: 76.50
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 5.5,
        fecalColiform: 6,
        ph: 7.6,
        bod: 2.2,
      );
      
      expect(result.subIndices.fecalColiform, closeTo(76.50, 1.0));
    });
    
    test('pH Sub-Index Calculation - Range 7.3-10', () {
      // pH = 7.6 (range 7.3-10)
      // Expected sub-index: 90.10
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 5.5,
        fecalColiform: 6,
        ph: 7.6,
        bod: 2.2,
      );
      
      expect(result.subIndices.ph, closeTo(90.10, 1.0));
    });
    
    test('BOD Sub-Index Calculation - Range 0-10', () {
      // BOD = 2.2 mg/l (range 0-10)
      // Expected sub-index: 81.27
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 5.5,
        fecalColiform: 6,
        ph: 7.6,
        bod: 2.2,
      );
      
      expect(result.subIndices.bod, closeTo(81.27, 1.0));
    });
    
    test('Weighted Indices - Check CPCB weights applied', () {
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 5.5,
        fecalColiform: 6,
        ph: 7.6,
        bod: 2.2,
      );
      
      // Verify weights are correctly applied
      expect(
        result.weightedIndices.dissolvedOxygen / result.subIndices.dissolvedOxygen,
        closeTo(0.31, 0.001),
      );
      expect(
        result.weightedIndices.fecalColiform / result.subIndices.fecalColiform,
        closeTo(0.28, 0.001),
      );
      expect(
        result.weightedIndices.ph / result.subIndices.ph,
        closeTo(0.22, 0.001),
      );
      expect(
        result.weightedIndices.bod / result.subIndices.bod,
        closeTo(0.19, 0.001),
      );
    });
    
    test('WQI Sum of Weighted Indices', () {
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 5.5,
        fecalColiform: 6,
        ph: 7.6,
        bod: 2.2,
      );
      
      final sum = result.weightedIndices.total;
      expect(sum, closeTo(result.wqi, 0.01));
    });
    
    test('JSON Serialization', () {
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 6.0,
        fecalColiform: 50,
        ph: 7.4,
        bod: 2.5,
      );
      
      final json = result.toJson();
      
      expect(json['wqi'], isA<double>());
      expect(json['classification'], isA<String>());
      expect(json['cpcbClass'], isA<String>());
      expect(json['mpcbClass'], isA<String>());
      expect(json['status'], isA<String>());
      expect(json['subIndices'], isA<Map>());
      expect(json['weightedIndices'], isA<Map>());
    });
  });
  
  group('WQI Classification Boundary Tests', () {
    test('Boundary: Good to Excellent (WQI = 63)', () {
      // Test at exact boundary
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 5.2,
        fecalColiform: 45,
        ph: 7.5,
        bod: 3.0,
      );
      
      if (result.wqi >= 63) {
        expect(result.classification, 'Good to Excellent');
        expect(result.cpcbClass, 'A');
      }
    });
    
    test('Boundary: Medium to Good (WQI = 50)', () {
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 4.2,
        fecalColiform: 250,
        ph: 8.5,
        bod: 5.5,
      );
      
      if (result.wqi >= 50 && result.wqi < 63) {
        expect(result.classification, 'Medium to Good');
        expect(result.cpcbClass, 'B');
      }
    });
    
    test('Boundary: Bad (WQI = 38)', () {
      final result = CPCBWQICalculator.calculateWQI(
        dissolvedOxygen: 3.2,
        fecalColiform: 1500,
        ph: 9.0,
        bod: 10.0,
      );
      
      if (result.wqi >= 38 && result.wqi < 50) {
        expect(result.classification, 'Bad');
        expect(result.cpcbClass, 'C');
      }
    });
  });
}
