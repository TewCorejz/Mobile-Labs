import 'dart:math' as math;

class CalculatorLogic {
  static String evaluateExpression(String input) {
    if (input.trim().isEmpty) {
      return '0';
    }

    try {
      final parser = _ExpressionParser(
        input.replaceAll(' ', '').replaceAll('×', '*').replaceAll('÷', '/'),
      );
      return _formatNumber(parser.parse());
    } on FormatException {
      return 'Error';
    }
  }

  static String _formatNumber(double value) {
    if (!value.isFinite) {
      return 'Error';
    }
    if (value.abs() < 1e-10) {
      return '0';
    }

    final integerPart = value.toInt();
    if ((value - integerPart).abs() < 1e-10) {
      return integerPart.toString();
    }

    return value
        .toStringAsFixed(10)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

class _ExpressionParser {
  _ExpressionParser(this._input);

  final String _input;
  int _position = 0;

  double parse() {
    final result = _parseAddition();
    if (_position != _input.length) {
      throw const FormatException('Unexpected input');
    }
    return result;
  }

  double _parseAddition() {
    var result = _parseMultiplication();
    while (_match('+') || _match('-')) {
      final operator = _input[_position - 1];
      final right = _parseMultiplication();
      result = operator == '+' ? result + right : result - right;
    }
    return result;
  }

  double _parseMultiplication() {
    var result = _parseUnary();
    while (_match('*') || _match('/')) {
      final operator = _input[_position - 1];
      final right = _parseUnary();
      if (operator == '/' && right == 0) {
        throw const FormatException('Division by zero');
      }
      result = operator == '*' ? result * right : result / right;
    }
    return result;
  }

  double _parseUnary() {
    if (_match('-')) {
      return -_parseUnary();
    }
    return _parsePrimary();
  }

  double _parsePrimary() {
    if (_match('(')) {
      final result = _parseAddition();
      if (!_match(')')) {
        throw const FormatException('Missing closing parenthesis');
      }
      return result;
    }

    if (_input.startsWith('ln(', _position)) {
      _position += 3;
      final argument = _parseAddition();
      if (!_match(')') || argument <= 0) {
        throw const FormatException('Invalid natural logarithm argument');
      }
      return math.log(argument);
    }

    final start = _position;
    while (_position < _input.length &&
        (RegExp(r'[0-9]').hasMatch(_input[_position]) ||
            _input[_position] == '.')) {
      _position++;
    }

    if (start == _position) {
      throw const FormatException('Expected a number');
    }

    final number = double.tryParse(_input.substring(start, _position));
    if (number == null || !number.isFinite) {
      throw const FormatException('Invalid number');
    }
    return number;
  }

  bool _match(String expected) {
    if (_position >= _input.length || _input[_position] != expected) {
      return false;
    }
    _position++;
    return true;
  }
}
