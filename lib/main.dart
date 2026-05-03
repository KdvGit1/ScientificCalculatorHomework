import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hesap Makinesi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '0';
  bool _hasError = false;

  void _onButton(String val) {
    setState(() {
      if (val == 'C') {
        _expression = '';
        _result = '0';
        _hasError = false;
      } else if (_hasError) {
        _expression = '';
        _result = '0';
        _hasError = false;
        if (val != 'C' && val != '=' && val != 'DEL') {
          _expression = val;
        }
      } else if (val == 'DEL') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (val == '=') {
        _hesapla();
      } else {
        _expression += val;
      }
    });
  }

  void _hesapla() {
    if (_expression.isEmpty) return;
    try {
      _pos = 0;
      _src = _expression.replaceAll(' ', '');
      double res = _parseAddSub();
      if (_pos != _src.length) throw Exception('Gecersiz ifade');
      if (res.isNaN || res.isInfinite) throw Exception('Tanimsiz sonuc');
      if (res == res.truncateToDouble()) {
        _result = res.toInt().toString();
      } else {
        _result = double.parse(res.toStringAsFixed(8)).toString();
      }
      _expression = _result;
      _hasError = false;
    } catch (e) {
      _result = 'Hata';
      _expression = '';
      _hasError = true;
    }
  }

  int _pos = 0;
  String _src = '';

  double _parseAddSub() {
    double left = _parseMulDiv();
    while (_pos < _src.length && (_src[_pos] == '+' || _src[_pos] == '-')) {
      String op = _src[_pos++];
      double right = _parseMulDiv();
      left = op == '+' ? left + right : left - right;
    }
    return left;
  }

  double _parseMulDiv() {
    double left = _parsePow();
    while (_pos < _src.length && (_src[_pos] == '*' || _src[_pos] == '/')) {
      String op = _src[_pos++];
      double right = _parsePow();
      if (op == '/' && right == 0) throw Exception('Sifira bolme');
      left = op == '*' ? left * right : left / right;
    }
    return left;
  }

  double _parsePow() {
    double base = _parseUnary();
    if (_pos < _src.length && _src[_pos] == '^') {
      _pos++;
      double exp = _parsePow();
      return math.pow(base, exp).toDouble();
    }
    return base;
  }

  double _parseUnary() {
    if (_pos < _src.length && _src[_pos] == '-') {
      _pos++;
      return -_parsePrimary();
    }
    if (_pos < _src.length && _src[_pos] == '+') _pos++;
    return _parsePrimary();
  }

  double _parsePrimary() {
    if (_pos >= _src.length) throw Exception('Beklenmedik son');

    if (_src[_pos] == '(') {
      _pos++;
      double val = _parseAddSub();
      if (_pos < _src.length && _src[_pos] == ')') {
        _pos++;
      } else {
        throw Exception('Kapatilmamis parantez');
      }
      return val;
    }

    for (String fn in ['sin', 'cos', 'tan', 'log', 'sqrt']) {
      if (_src.startsWith('$fn(', _pos)) {
        _pos += fn.length + 1;
        double arg = _parseAddSub();
        if (_pos < _src.length && _src[_pos] == ')') _pos++;
        switch (fn) {
          case 'sin': return math.sin(arg * math.pi / 180);
          case 'cos': return math.cos(arg * math.pi / 180);
          case 'tan': return math.tan(arg * math.pi / 180);
          case 'log':
            if (arg <= 0) throw Exception('Negatif log');
            return math.log(arg) / math.ln10;
          case 'sqrt':
            if (arg < 0) throw Exception('Negatif karekok');
            return math.sqrt(arg);
        }
      }
    }

    int start = _pos;
    while (_pos < _src.length) {
      int c = _src.codeUnitAt(_pos);
      if (!((c >= 48 && c <= 57) || c == 46)) break;
      _pos++;
    }
    if (_pos == start) throw Exception('Sayi bekleniyordu');
    return double.parse(_src.substring(start, _pos));
  }

  Widget _btn(String label, {Color? bg, Color? fg, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: TextButton(
          onPressed: () => _onButton(label),
          style: TextButton.styleFrom(
            backgroundColor: bg ?? const Color(0xFF1E1E2E),
            foregroundColor: fg ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: label.length > 3 ? 15 : 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11111B),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.calculate_outlined, color: Color(0xFF89B4FA), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Bilimsel Hesap Makinesi',
                        style: TextStyle(
                          color: Color(0xFF89B4FA),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Kadir Doğan Vural\n1030521402',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF6C7086),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _expression,
                        style: const TextStyle(color: Color(0xFF6C7086), fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result,
                        style: TextStyle(
                          color: _hasError ? Colors.redAccent : Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: Column(
                children: [
                  Row(children: [
                    _btn('sin(', bg: const Color(0xFF313244)),
                    _btn('cos(', bg: const Color(0xFF313244)),
                    _btn('tan(', bg: const Color(0xFF313244)),
                    _btn('log(', bg: const Color(0xFF313244)),
                  ]),
                  Row(children: [
                    _btn('sqrt(', bg: const Color(0xFF313244)),
                    _btn('^', bg: const Color(0xFF313244)),
                    _btn('(', bg: const Color(0xFF313244)),
                    _btn(')', bg: const Color(0xFF313244)),
                  ]),
                  Row(children: [
                    _btn('7'), _btn('8'), _btn('9'),
                    _btn('/', bg: const Color(0xFFE8A44A), fg: Colors.black),
                  ]),
                  Row(children: [
                    _btn('4'), _btn('5'), _btn('6'),
                    _btn('*', bg: const Color(0xFFE8A44A), fg: Colors.black),
                  ]),
                  Row(children: [
                    _btn('1'), _btn('2'), _btn('3'),
                    _btn('-', bg: const Color(0xFFE8A44A), fg: Colors.black),
                  ]),
                  Row(children: [
                    _btn('0'), _btn('.'),
                    _btn('DEL', bg: const Color(0xFFE55F5F)),
                    _btn('+', bg: const Color(0xFFE8A44A), fg: Colors.black),
                  ]),
                  Row(children: [
                    _btn('C', bg: const Color(0xFFE55F5F), flex: 2),
                    _btn('=', bg: const Color(0xFF40A870), flex: 2),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}