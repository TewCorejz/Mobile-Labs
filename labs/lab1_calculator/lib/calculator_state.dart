import 'package:flutter/foundation.dart';

import 'calculator_logic.dart';

class CalculatorState extends ChangeNotifier {
  String _expression = '';
  String _result = '0';
  String _lastValidResult = '0';
  bool _hasEvaluated = false;

  String get expression => _expression;
  String get result => _result;

  void appendDigit(String digit) {
    if (_hasEvaluated) {
      clear();
      _hasEvaluated = false;
    }

    if (_expression == 'Error') {
      clear();
    }

    if (_expression == '0') {
      _expression = digit;
    } else {
      _expression += digit;
    }

    _result = _previewExpression();
    notifyListeners();
  }

  void appendDecimalPoint() {
    if (_hasEvaluated) {
      clear();
      _hasEvaluated = false;
    }

    if (_expression == 'Error') {
      clear();
    }

    final lastPart = _expression.split(RegExp(r'[+\-×÷]')).last;
    if (lastPart.contains('.')) {
      return;
    }

    if (_expression.isEmpty ||
        _isOperator(_expression[_expression.length - 1])) {
      _expression += '0.';
    } else {
      _expression += '.';
    }

    _result = _previewExpression();
    notifyListeners();
  }

  void appendOperator(String operator) {
    if (_hasEvaluated) {
      _expression = _result == 'Error' ? '' : _result;
      _hasEvaluated = false;
    }

    if (_expression.isEmpty) {
      if (operator == '-') {
        _expression = '-';
      }
      _result = _previewExpression();
      notifyListeners();
      return;
    }

    final lastCharacter = _expression[_expression.length - 1];
    if (_isOperator(lastCharacter)) {
      if (operator == '-' && lastCharacter != '-') {
        _expression += '-';
      } else {
        _expression =
            _expression.substring(0, _expression.length - 1) + operator;
      }
    } else {
      _expression += operator;
    }

    _result = _previewExpression();
    notifyListeners();
  }

  void applyNaturalLog() {
    if (_expression.isEmpty) {
      return;
    }

    if (_hasEvaluated) {
      _expression = _result;
      _hasEvaluated = false;
    }

    _expression = 'ln($_expression)';
    _result = CalculatorLogic.evaluateExpression(_expression);
    _hasEvaluated = _result != 'Error';
    if (_hasEvaluated) {
      _lastValidResult = _result;
    }
    notifyListeners();
  }

  void clear() {
    _expression = '';
    _result = '0';
    _lastValidResult = '0';
    _hasEvaluated = false;
    notifyListeners();
  }

  void backspace() {
    if (_expression.isEmpty) {
      return;
    }

    _expression = _expression.substring(0, _expression.length - 1);
    _result = _expression.isEmpty ? '0' : _previewExpression();
    notifyListeners();
  }

  void evaluate() {
    if (_expression.isEmpty) {
      return;
    }

    final evaluated = CalculatorLogic.evaluateExpression(_expression);
    _result = evaluated;

    if (evaluated == 'Error') {
      _hasEvaluated = false;
      notifyListeners();
      return;
    }

    _lastValidResult = evaluated;
    _hasEvaluated = true;
    notifyListeners();
  }

  String _previewExpression() {
    if (_expression.isEmpty) {
      return '0';
    }

    if (_isOperator(_expression[_expression.length - 1]) ||
        _expression.endsWith('.')) {
      return _lastValidResult;
    }

    final candidate = CalculatorLogic.evaluateExpression(_expression);
    if (candidate == 'Error') {
      return _lastValidResult;
    }

    _lastValidResult = candidate;
    return candidate;
  }

  bool _isOperator(String value) =>
      value == '+' || value == '-' || value == '×' || value == '÷';
}
