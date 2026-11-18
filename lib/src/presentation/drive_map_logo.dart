import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Small vector illustration: a blocky car on an isometric road tile.
class DriveMapLogo extends StatelessWidget {
  const DriveMapLogo({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: const _LogoPainter()),
    ),
  );
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    void face(List<Offset> points, Color color) {
      final path = Path()..addPolygon(points, true);
      canvas.drawPath(path, Paint()..color = color);
    }

    face(const [
      Offset(8, 63),
      Offset(50, 86),
      Offset(50, 95),
      Offset(8, 72),
    ], DriveColors.accent);
    face(const [
      Offset(50, 86),
      Offset(92, 63),
      Offset(92, 72),
      Offset(50, 95),
    ], const Color(0xFF5B9B56));
    face(const [
      Offset(8, 63),
      Offset(50, 40),
      Offset(92, 63),
      Offset(50, 86),
    ], DriveColors.grass);
    face(const [
      Offset(20, 56),
      Offset(34, 48),
      Offset(79, 73),
      Offset(65, 81),
    ], const Color(0xFF718179));
    face(const [
      Offset(34, 56.5),
      Offset(36, 55.4),
      Offset(44, 59.9),
      Offset(42, 61),
    ], const Color(0xFFE8EDE5));
    face(const [
      Offset(54, 68.2),
      Offset(56, 67.1),
      Offset(64, 71.6),
      Offset(62, 72.7),
    ], const Color(0xFFE8EDE5));

    // Align the car with the road and place its center on the lane centerline.
    canvas.save();
    canvas.translate(50, 64.5);
    canvas.rotate(0.5071);
    canvas.scale(.82, .45);
    canvas.translate(-50, -48.5);

    // Wheels sit behind the body, on both visible faces.
    for (final point in const [
      Offset(31, 56),
      Offset(49, 67),
      Offset(70, 59),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: point, width: 9, height: 13),
          const Radius.circular(2),
        ),
        Paint()..color = DriveColors.ink,
      );
    }
    face(const [
      Offset(22, 43),
      Offset(50, 59),
      Offset(50, 69),
      Offset(22, 53),
    ], const Color(0xFF4B925B));
    face(const [
      Offset(50, 59),
      Offset(78, 43),
      Offset(78, 54),
      Offset(50, 69),
    ], DriveColors.accent);
    face(const [
      Offset(22, 43),
      Offset(50, 28),
      Offset(78, 43),
      Offset(50, 59),
    ], const Color(0xFFA4D98A));
    face(const [
      Offset(33, 31),
      Offset(49, 22),
      Offset(64, 31),
      Offset(48, 40),
    ], const Color(0xFFD8EFC5));
    face(const [
      Offset(33, 31),
      Offset(48, 40),
      Offset(48, 51),
      Offset(33, 42),
    ], const Color(0xFF41675B));
    face(const [
      Offset(48, 40),
      Offset(64, 31),
      Offset(64, 42),
      Offset(48, 51),
    ], const Color(0xFF88B8AB));
    face(const [
      Offset(68.5, 49.8),
      Offset(71, 48.4),
      Offset(72.6, 49.3),
      Offset(70.1, 50.7),
    ], const Color(0xFFFFEAB1));
    face(const [
      Offset(72.5, 47.6),
      Offset(75, 46.2),
      Offset(76.6, 47.1),
      Offset(74.1, 48.5),
    ], const Color(0xFFFFEAB1));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
