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
    // Center the road-and-car artwork in the square canvas.
    canvas.translate(0, -18);
    void face(List<Offset> points, Color color) {
      final path = Path()..addPolygon(points, true);
      canvas.drawPath(path, Paint()..color = color);
    }

    void outline(List<Offset> points, Color color, {double width = 1}) {
      final path = Path()..addPolygon(points, true);
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeJoin = StrokeJoin.round,
      );
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

    // Car is drawn directly in the road's isometric coordinate system.
    // Its longitudinal edges follow the lane from upper-left to lower-right.
    const frontFar = Offset(41, 52);
    const frontNear = Offset(29, 59);
    const rearNear = Offset(59, 76);
    const rearFar = Offset(71, 69);
    const bodyDrop = Offset(0, 8);

    face(const [
      Offset(27, 62),
      Offset(59, 80),
      Offset(74, 71),
      Offset(41, 50),
    ], const Color(0x3327382E));

    // The four faces make the body sit on the road instead of floating above it.
    face([
      frontNear,
      rearNear,
      rearNear + bodyDrop,
      frontNear + bodyDrop,
    ], const Color(0xFF39764B));
    face([
      frontFar,
      rearFar,
      rearFar + bodyDrop,
      frontFar + bodyDrop,
    ], const Color(0xFF4B8253));
    face([
      frontNear,
      frontFar,
      frontFar + bodyDrop,
      frontNear + bodyDrop,
    ], const Color(0xFF548A55));
    face([
      rearNear,
      rearFar,
      rearFar + bodyDrop,
      rearNear + bodyDrop,
    ], const Color(0xFF315F42));

    // Side windows and four tyres remain visible beneath the roof line.
    face(const [
      Offset(40, 65),
      Offset(48, 69.5),
      Offset(48, 72.5),
      Offset(40, 68),
    ], const Color(0xFF294B45));
    face(const [
      Offset(51, 58),
      Offset(60, 63),
      Offset(60, 66),
      Offset(51, 61),
    ], const Color(0xFF365D54));
    for (final wheel in const [
      [Offset(34, 61.5), Offset(38, 63.8), Offset(38, 69), Offset(34, 66.7)],
      [Offset(49, 70), Offset(53, 72.3), Offset(53, 77.5), Offset(49, 75.2)],
      [Offset(46, 54), Offset(50, 56.3), Offset(50, 61.5), Offset(46, 59.2)],
      [Offset(62, 63), Offset(66, 65.3), Offset(66, 70.5), Offset(62, 68.2)],
    ]) {
      face(wheel, DriveColors.ink);
      outline(wheel, const Color(0xFF17251D), width: .7);
    }

    // Hood and trunk give the top plane a clear front-to-rear direction.
    face(const [
      frontFar,
      rearFar,
      rearNear,
      frontNear,
    ], const Color(0xFFA4D98A));
    face(const [
      Offset(41, 52),
      Offset(48, 56),
      Offset(42, 61),
      Offset(31, 55),
    ], const Color(0xFFB7E79B));
    face(const [
      Offset(56, 61),
      Offset(70, 69),
      Offset(59, 75),
      Offset(52, 71),
    ], const Color(0xFF8BCF78));
    outline(
      const [frontFar, rearFar, rearNear, frontNear],
      const Color(0xFF263D30),
      width: 1.4,
    );

    // Clearly framed cabin glass, aligned with the same isometric axes.
    face(const [
      Offset(39.5, 62.6),
      Offset(47.3, 58),
      Offset(60.5, 65.4),
      Offset(52.7, 70),
    ], const Color(0xFF294B45));
    face(const [
      Offset(41, 62.1),
      Offset(47.5, 58.4),
      Offset(53.7, 61.9),
      Offset(47.1, 65.6),
    ], const Color(0xFFB6D1C5));
    face(const [
      Offset(48.1, 66.2),
      Offset(54.6, 62.5),
      Offset(59, 65),
      Offset(52.4, 68.8),
    ], const Color(0xFF789C91));
    outline(
      const [
        Offset(39.5, 62.6),
        Offset(47.3, 58),
        Offset(60.5, 65.4),
        Offset(52.7, 70),
      ],
      const Color(0xFF263D30),
      width: 1.1,
    );

    // Paired headlights at the front and red tail lamps at the rear.
    face(const [
      Offset(30.3, 58.1),
      Offset(32.6, 56.8),
      Offset(34.4, 57.8),
      Offset(32.1, 59.2),
    ], const Color(0xFFFFEAB1));
    face(const [
      Offset(36.2, 54.7),
      Offset(38.5, 53.4),
      Offset(40.3, 54.4),
      Offset(38, 55.8),
    ], const Color(0xFFFFEAB1));
    face(const [
      Offset(58.2, 74.8),
      Offset(60.5, 73.5),
      Offset(62.1, 74.5),
      Offset(59.8, 75.9),
    ], DriveColors.red);
    face(const [
      Offset(67.8, 69.3),
      Offset(70.1, 68),
      Offset(71.7, 69),
      Offset(69.4, 70.4),
    ], DriveColors.red);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
