import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
          body: Center(
              child: ResizeableRow(
                  text: 'Какой-то достаточно длинный текст', selected: false))),
    );
  }
}

class ResizeableRow extends StatefulWidget {
  const ResizeableRow({super.key, required this.text, required this.selected});
  final String text;
  final bool selected;

  @override
  State<ResizeableRow> createState() => _ResizeableRowState();
}

class _ResizeableRowState extends State<ResizeableRow>
    with WidgetsBindingObserver {
  late bool selected;
  late double textMaxWidth;
  double lineWidth = 1000;
  int textFlex = 0;
  int lineFlex = 1;
  final GlobalKey _textKey = GlobalKey();
  static const double rowHeight = 25;

  @override
  void initState() {
    selected = widget.selected;
    textMaxWidth = calculateTextMaxWidth();
    WidgetsBinding.instance.addObserver(this);

    /// In case initial text is larger than needed
    WidgetsBinding.instance.addPostFrameCallback((_) => didChangeMetrics());

    super.initState();
  }

  @override
  void didChangeMetrics() {
    RenderBox? renderBox;
    if (_textKey.currentContext?.findRenderObject() != null) {
      renderBox = _textKey.currentContext!.findRenderObject() as RenderBox;
      final textRenderWidth = renderBox.size.width;
      if (textRenderWidth >= textMaxWidth && textFlex == 1) {
        /// on expand
        setState(() {
          textFlex = 0;
          lineFlex = 1;
        });
      } else if ((lineWidth < 10) && textFlex == 0) {
        /// on shrink
        setState(() {
          textFlex = 1;
          lineFlex = 0;
        });
      }
    }
  }

  /// In case of text change
  @override
  void didUpdateWidget(covariant ResizeableRow oldWidget) {
    textMaxWidth = calculateTextMaxWidth();
    WidgetsBinding.instance.addPostFrameCallback((_) => didChangeMetrics());
    super.didUpdateWidget(oldWidget);
  }

  double calculateTextMaxWidth() {
    TextSpan textSpan = TextSpan(text: widget.text);
    TextPainter textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(maxWidth: double.infinity);

    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Text cell

        Flexible(
            flex: textFlex,
            child: Container(
              height: rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(),
                      bottom: BorderSide(),
                      left: BorderSide())),
              child: Text(
                widget.text,
                key: _textKey,
                overflow: TextOverflow.ellipsis,
              ),
            )),

        /// Dash cell
        Expanded(
          flex: lineFlex,
          child: Container(
            constraints: const BoxConstraints(minWidth: 10),
            height: rowHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              lineWidth = constraints.maxWidth;
              return CustomPaint(
                painter: DashPainter(),
                size: Size(lineWidth == double.infinity ? 10 : lineWidth, 1),
              );
            }),
          ),
        ),

        /// Checkbox cell
        Container(
          height: rowHeight,
          decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(),
                  bottom: BorderSide(),
                  right: BorderSide())),
          child: Checkbox(
            value: selected,
            onChanged: (newValue) {
              setState(() {
                selected = newValue!;
              });
            },
          ),
        )
      ],
    );
  }
}

class DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1;
    if (size.width <= 10) paint.color = Colors.transparent;
    const dashWidth = 4;
    const dashSpace = 4;
    double drawPoint = 0;

    while (drawPoint < size.width) {
      canvas.drawLine(
          Offset(drawPoint, 0), Offset(drawPoint + dashWidth, 0), paint);
      drawPoint += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
