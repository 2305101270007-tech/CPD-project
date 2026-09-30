import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool _dark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: CalculatorScreen(
        isDark: _dark,
        onToggleTheme: () => setState(() => _dark = !_dark),
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  const CalculatorScreen(
      {super.key, required this.isDark, required this.onToggleTheme});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';
  final List<String> _history = [];

  static const List<List<String>> _keys = [
    ['C', '⌫', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['±', '0', '.', '='],
  ];

  bool _isOperator(String s) => ['+', '-', '×', '÷', '%'].contains(s);

  void _onKey(String key) {
    setState(() {
      switch (key) {
        case 'C':
          _expression = '';
          _result = '0';
          break;
        case '⌫':
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
          }
          _liveResult();
          break;
        case '=':
          _equals();
          break;
        case '±':
          _toggleSign();
          break;
        default:
          _append(key);
      }
    });
  }

  void _append(String key) {
    if (_isOperator(key)) {
      if (_expression.isEmpty) {
        if (key == '-') _expression = '-';
        return;
      }
      if (_isOperator(_expression[_expression.length - 1])) {
        _expression = _expression.substring(0, _expression.length - 1) + key;
      } else {
        _expression += key;
      }
    } else if (key == '.') {
      // allow only one dot per number
      final parts = _expression.split(RegExp(r'[+\-×÷%]'));
      if (parts.isNotEmpty && parts.last.contains('.')) return;
      _expression += (parts.isNotEmpty && parts.last.isEmpty) ? '0.' : '.';
    } else {
      _expression += key;
    }
    _liveResult();
  }

  void _toggleSign() {
    if (_expression.isEmpty) return;
    final m = RegExp(r'(-?\d*\.?\d+)$').firstMatch(_expression);
    if (m == null) return;
    final num = m.group(1)!;
    final flipped = num.startsWith('-') ? num.substring(1) : '-$num';
    _expression = _expression.substring(0, m.start) + flipped;
    _liveResult();
  }

  void _liveResult() {
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }
    final v = _evaluate(_expression);
    if (v != null) _result = _format(v);
  }

  void _equals() {
    if (_expression.isEmpty) return;
    final v = _evaluate(_expression);
    if (v == null) {
      _result = 'Error';
      return;
    }
    final out = _format(v);
    _history.insert(0, '$_expression = $out');
    if (_history.length > 20) _history.removeLast();
    _expression = out;
    _result = out;
  }

  String _format(double v) {
    if (v.isNaN || v.isInfinite) return 'Error';
    if (v == v.roundToDouble() && v.abs() < 1e15) return v.toInt().toString();
    return double.parse(v.toStringAsFixed(8)).toString();
  }

  /// Evaluates an expression with correct operator precedence (× ÷ % before + -).
  double? _evaluate(String expr) {
    try {
      final tokens = <String>[];
      var num = '';
      for (var i = 0; i < expr.length; i++) {
        final c = expr[i];
        final unaryMinus =
            c == '-' && (i == 0 || _isOperator(expr[i - 1]));
        if (_isOperator(c) && !unaryMinus) {
          if (num.isEmpty) return null;
          tokens.add(num);
          tokens.add(c);
          num = '';
        } else {
          num += c;
        }
      }
      if (num.isEmpty || num == '-') {
        // trailing operator: ignore it for live result
        if (tokens.isEmpty) return null;
        tokens.removeLast();
      } else {
        tokens.add(num);
      }
      if (tokens.isEmpty) return null;

      // Pass 1: × ÷ %
      final pass = <String>[tokens[0]];
      for (var i = 1; i < tokens.length; i += 2) {
        final op = tokens[i];
        final b = double.parse(tokens[i + 1]);
        if (op == '×' || op == '÷' || op == '%') {
          final a = double.parse(pass.removeLast());
          double r;
          if (op == '×') {
            r = a * b;
          } else if (op == '÷') {
            if (b == 0) return null;
            r = a / b;
          } else {
            if (b == 0) return null;
            r = a % b;
          }
          pass.add(r.toString());
        } else {
          pass.add(op);
          pass.add(tokens[i + 1]);
        }
      }
      // Pass 2: + -
      var total = double.parse(pass[0]);
      for (var i = 1; i < pass.length; i += 2) {
        final b = double.parse(pass[i + 1]);
        total = pass[i] == '+' ? total + b : total - b;
      }
      return total;
    } catch (_) {
      return null;
    }
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('History',
                      style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () {
                      setState(() => _history.clear());
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              if (_history.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No calculations yet')),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: _history
                        .map((h) => ListTile(
                              title: Text(h, textAlign: TextAlign.right),
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Calculator'),
        actions: [
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
          ),
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _expression.isEmpty ? ' ' : _expression,
                        style: TextStyle(
                            fontSize: 28, color: cs.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _result,
                        style: const TextStyle(
                            fontSize: 56, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: _keys
                      .map((row) => Expanded(
                            child: Row(
                              children: row
                                  .map((k) => Expanded(child: _button(k, cs)))
                                  .toList(),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(String label, ColorScheme cs) {
    Color bg;
    Color fg;
    if (label == '=') {
      bg = cs.primary;
      fg = cs.onPrimary;
    } else if (_isOperator(label) && label != '%') {
      bg = cs.secondaryContainer;
      fg = cs.onSecondaryContainer;
    } else if (label == 'C' || label == '⌫' || label == '%' || label == '±') {
      bg = cs.tertiaryContainer;
      fg = cs.onTertiaryContainer;
    } else {
      bg = cs.surfaceContainerHighest;
      fg = cs.onSurface;
    }
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _onKey(label),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w500, color: fg)),
          ),
        ),
      ),
    );
  }
}
