import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';

class JarvisLogo extends StatelessWidget {
  final double size;
  final double fontSize;

  const JarvisLogo({super.key, this.size = 60, this.fontSize = 36});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryBlue,
                AppTheme.primaryBlue.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: size * 0.85,
                  height: size * 0.85,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Center(
                child: CustomPaint(
                  size: Size(size * 0.5, size * 0.5),
                  painter: TrianglePainter(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        Text(
          'ByteQueens',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppTheme.whiteText,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.45);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.close();

    path.moveTo(size.width * 0.35, size.height * 0.55);
    path.lineTo(size.width * 0.5, size.height * 0.8);
    path.lineTo(size.width * 0.65, size.height * 0.55);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
