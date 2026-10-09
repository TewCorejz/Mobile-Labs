import 'package:flutter/material.dart';

import 'calculator_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        useMaterial3: true,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: _isDarkMode
            ? const Color(0xFF111111)
            : const Color(0xFFF3F4F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A7BD5),
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      home: CalculatorScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: () => setState(() => _isDarkMode = !_isDarkMode),
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorState _state = CalculatorState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? const Color(0xFF202124)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CALCULATOR',
                                style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                  color: widget.isDarkMode
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                              ),
                              IconButton(
                                onPressed: widget.onToggleTheme,
                                tooltip: widget.isDarkMode
                                    ? 'Включить светлую тему'
                                    : 'Включить тёмную тему',
                                icon: Icon(
                                  widget.isDarkMode
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                ),
                                color: widget.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ],
                          ),
                          Flexible(
                            child: Text(
                              _state.expression.isEmpty
                                  ? '0'
                                  : _state.expression,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 30,
                                color: widget.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _state.result,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w600,
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _buildKeyRow([
                          _ButtonSpec(
                            'C',
                            const Color(0xFF3A7BD5),
                            _state.clear,
                          ),
                          _ButtonSpec(
                            '÷',
                            const Color(0xFFF2994A),
                            () => _state.appendOperator('÷'),
                          ),
                          _ButtonSpec(
                            '×',
                            const Color(0xFFF2994A),
                            () => _state.appendOperator('×'),
                          ),
                          _ButtonSpec(
                            'ln',
                            const Color(0xFF5C5D5F),
                            _state.applyNaturalLog,
                          ),
                        ]),
                        _buildKeyRow([
                          _ButtonSpec(
                            '7',
                            _digitButtonColor,
                            () => _state.appendDigit('7'),
                          ),
                          _ButtonSpec(
                            '8',
                            _digitButtonColor,
                            () => _state.appendDigit('8'),
                          ),
                          _ButtonSpec(
                            '9',
                            _digitButtonColor,
                            () => _state.appendDigit('9'),
                          ),
                          _ButtonSpec(
                            '-',
                            const Color(0xFFF2994A),
                            () => _state.appendOperator('-'),
                          ),
                        ]),
                        _buildKeyRow([
                          _ButtonSpec(
                            '4',
                            _digitButtonColor,
                            () => _state.appendDigit('4'),
                          ),
                          _ButtonSpec(
                            '5',
                            _digitButtonColor,
                            () => _state.appendDigit('5'),
                          ),
                          _ButtonSpec(
                            '6',
                            _digitButtonColor,
                            () => _state.appendDigit('6'),
                          ),
                          _ButtonSpec(
                            '+',
                            const Color(0xFFF2994A),
                            () => _state.appendOperator('+'),
                          ),
                        ]),
                        _buildKeyRow([
                          _ButtonSpec(
                            '1',
                            _digitButtonColor,
                            () => _state.appendDigit('1'),
                          ),
                          _ButtonSpec(
                            '2',
                            _digitButtonColor,
                            () => _state.appendDigit('2'),
                          ),
                          _ButtonSpec(
                            '3',
                            _digitButtonColor,
                            () => _state.appendDigit('3'),
                          ),
                          _ButtonSpec(
                            '=',
                            const Color(0xFF27AE60),
                            _state.evaluate,
                          ),
                        ]),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: _CalculatorButton(
                                    label: '0',
                                    color: _digitButtonColor,
                                    onPressed: () => _state.appendDigit('0'),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: _CalculatorButton(
                                    label: '.',
                                    color: _digitButtonColor,
                                    onPressed: _state.appendDecimalPoint,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: _CalculatorButton(
                                    label: '⌫',
                                    color: const Color(0xFF5C5D5F),
                                    onPressed: _state.backspace,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color get _digitButtonColor =>
      widget.isDarkMode ? const Color(0xFF2A2C2F) : const Color(0xFFE1E4E8);

  Widget _buildKeyRow(List<_ButtonSpec> buttons) {
    return Expanded(
      child: Row(
        children: buttons
            .map(
              (button) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: _CalculatorButton(
                    label: button.label,
                    color: button.color,
                    onPressed: button.onPressed,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ButtonSpec {
  const _ButtonSpec(this.label, this.color, this.onPressed);

  final String label;
  final Color color;
  final VoidCallback onPressed;
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: label == 'ln' || label == '⌫'
              ? Colors.white
              : color.computeLuminance() > 0.5
              ? Colors.black87
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
          minimumSize: Size.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
