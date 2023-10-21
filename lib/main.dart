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
  double lineWidth = double.infinity;
  double textWidth = double.infinity;

  static const double rowHeight = 25;
  final GlobalKey _key = GlobalKey();
  @override
  void initState() {
    selected = widget.selected;
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Text cell

        Flexible(
            flex: lineWidth > 10 ? 0 : 1,
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
                key: _key,
                overflow: TextOverflow.ellipsis,
              ),
            )),

        /// Dash cell
        Builder(builder: (context) {
          if (lineWidth > 10) {
            return Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (lineWidth != constraints.maxWidth) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        lineWidth = constraints.maxWidth;
                      });
                    });
                  }
                  return Container(
                    height: rowHeight,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: CustomPaint(
                      painter: DashPainter(),
                      size: Size(lineWidth, 1),
                    ),
                  );
                },
              ),
            );
          } else {
            return Container(
              width: 10,
              height: rowHeight,
              decoration: const BoxDecoration(
                  border: Border.symmetric(horizontal: BorderSide())),
            );
          }
        }),

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

  /// Used to make dash line appear again because as soon [lineWidth] goes
  /// smaller than 10, [setState] is not being called anymore so we need
  /// to do it on screen change
  @override
  void didChangeMetrics() {
    RenderBox? renderBox;
    if (_key.currentContext?.findRenderObject() != null) {
      renderBox = _key.currentContext!.findRenderObject() as RenderBox;
      final currentTextWidth = renderBox.size.width;
      if (currentTextWidth > textWidth && lineWidth < 10) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            lineWidth = 11;
          });
        });
      }
      textWidth = currentTextWidth;
    }
  }
}

class DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1;

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
