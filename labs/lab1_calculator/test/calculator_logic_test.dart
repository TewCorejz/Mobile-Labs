import 'package:flutter_test/flutter_test.dart';

import 'package:lab1_calculator/calculator_logic.dart';

void main() {
  group('CalculatorLogic', () {
    test('evaluates arithmetic expressions with precedence', () {
      expect(CalculatorLogic.evaluateExpression('7 + 3 * 2'), '13');
      expect(CalculatorLogic.evaluateExpression('9 ÷ 3'), '3');
      expect(CalculatorLogic.evaluateExpression('12 + 8'), '20');
    });

    test('handles division by zero', () {
      expect(CalculatorLogic.evaluateExpression('8 ÷ 0'), 'Error');
      expect(CalculatorLogic.evaluateExpression('10 / 0'), 'Error');
    });

    test('evaluates natural logarithms for positive values', () {
      expect(CalculatorLogic.evaluateExpression('ln(1)'), '0');
      expect(CalculatorLogic.evaluateExpression('ln(2.718281828459045)'), '1');
      expect(CalculatorLogic.evaluateExpression('ln(1 + 2)'), '1.0986122887');
    });

    test('rejects natural logarithms of zero or negative values', () {
      expect(CalculatorLogic.evaluateExpression('ln(0)'), 'Error');
      expect(CalculatorLogic.evaluateExpression('ln(-2)'), 'Error');
    });

    test('rejects invalid expressions', () {
      expect(CalculatorLogic.evaluateExpression('2 +'), 'Error');
      expect(CalculatorLogic.evaluateExpression('++2'), 'Error');
    });
  });
}
