import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/widgets/map.dart';
import 'package:frontend/services/route_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> waypoints = [];
  Map<String, bool> visited = {};
  bool loading = true;

  double latTop = 0;
  double latBottom = 0;
  double lonLeft = 0;
  double lonRight = 0;

  // Dimensiunea virtuală a hărții (mare pentru detalii)
  final double mapWidth = 2000;
  final double mapHeight = 2000;

  // Animație pentru ring
  late AnimationController _ringController;
  Animation<double>? _ringAnimation;

  @override
  void initState() {
    super.initState();

    // Inițializează animația pentru ring
    _ringController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _ringAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );

    RouteService.fetchWaypoints()
        .then((data) {
          setState(() {
            waypoints = data;
            visited = {for (var wp in waypoints) wp["name"]: false};

            if (waypoints.isNotEmpty) {
              var lats = waypoints.map((wp) => wp["lat"] as double).toList();
              var lons = waypoints.map((wp) => wp["lon"] as double).toList();

              latTop = lats.reduce((a, b) => a > b ? a : b) + 0.002;
              latBottom = lats.reduce((a, b) => a < b ? a : b) - 0.002;
              lonLeft = lons.reduce((a, b) => a < b ? a : b) - 0.002;
              lonRight = lons.reduce((a, b) => a > b ? a : b) + 0.002;

              print("Bounds: lat=$latBottom-$latTop, lon=$lonLeft-$lonRight");
            }

            loading = false;
          });
        })
        .catchError((e) {
          setState(() => loading = false);
          print("Error loading waypoints: $e");
        });
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  // Găsește indexul primei locații nevizitate
  int get currentWaypointIndex {
    for (int i = 0; i < waypoints.length; i++) {
      if (!visited[waypoints[i]["name"]]!) {
        return i;
      }
    }
    return -1; // Toate vizitate
  }

  Offset latLonToPixel(double lat, double lon) {
    double x = (lon - lonLeft) / (lonRight - lonLeft) * mapWidth;
    double y = (latTop - lat) / (latTop - latBottom) * mapHeight;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Map Zoom & Pan")),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        boundaryMargin: const EdgeInsets.all(100),
        constrained: false,
        child: SizedBox(
          width: mapWidth,
          height: mapHeight,
          child: Stack(
            children: [
              // Harta
              Image.asset(
                "assets/map.jpg",
                width: mapWidth,
                height: mapHeight,
                fit: BoxFit.fill,
              ),

              // Linii care conectează waypoint-urile
              CustomPaint(
                size: Size(mapWidth, mapHeight),
                painter: RoutePainter(
                  waypoints: waypoints,
                  latLonToPixel: latLonToPixel,
                ),
              ),

              // Ring animat pentru locația curentă
              if (currentWaypointIndex >= 0 && _ringAnimation != null)
                AnimatedBuilder(
                  animation: _ringAnimation!,
                  builder: (context, child) {
                    final currentWp = waypoints[currentWaypointIndex];
                    final offset = latLonToPixel(
                      currentWp["lat"],
                      currentWp["lon"],
                    );

                    return Stack(
                      children: [
                        // Ring din spate (umbră 3D)
                        Positioned(
                          left: offset.dx - 55,
                          top: offset.dy - 45, // 5px mai jos
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.orange[800]!,
                                width: 6 * _ringAnimation!.value,
                              ),
                            ),
                          ),
                        ),
                        // Ring din față
                        Positioned(
                          left: offset.dx - 55,
                          top: offset.dy - 50,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.amber,
                                width: 6 * _ringAnimation!.value,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

              // Butoanele waypoint
              ...waypoints.map((wp) {
                final offset = latLonToPixel(wp["lat"], wp["lon"]);
                bool isProducer = wp["type"] == "vendor";

                return Positioned(
                  left: offset.dx - 35,
                  top: offset.dy - 35,
                  child: MapButton(
                    label: wp["name"],
                    isProducer: isProducer,
                    visited: visited[wp["name"]]!,
                    onVisited: () {
                      setState(() => visited[wp["name"]] = true);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

// Painter pentru a desena liniile rutei
class RoutePainter extends CustomPainter {
  final List<Map<String, dynamic>> waypoints;
  final Offset Function(double lat, double lon) latLonToPixel;

  RoutePainter({required this.waypoints, required this.latLonToPixel});

  @override
  void paint(Canvas canvas, Size size) {
    if (waypoints.length < 2) return;

    final paint = Paint()
      ..color = Colors.green.withOpacity(0.7)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Desenează curbe între fiecare pereche consecutivă
    for (int i = 0; i < waypoints.length - 1; i++) {
      final start = latLonToPixel(waypoints[i]["lat"], waypoints[i]["lon"]);
      final end = latLonToPixel(
        waypoints[i + 1]["lat"],
        waypoints[i + 1]["lon"],
      );

      // Calculează punctul de control pentru curbă
      final midX = (start.dx + end.dx) / 2;
      final midY = (start.dy + end.dy) / 2;

      // Vector perpendicular pentru offset-ul curbei
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final length = sqrt(dx * dx + dy * dy);

      // Offset perpendicular (20% din distanță)
      final offsetAmount = length * 0.15;
      final perpX = -dy / length * offsetAmount;
      final perpY = dx / length * offsetAmount;

      final controlPoint = Offset(midX + perpX, midY + perpY);

      // Desenează curba quadratică
      final path = Path();
      path.moveTo(start.dx, start.dy);
      path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(RoutePainter oldDelegate) {
    return waypoints != oldDelegate.waypoints;
  }
}
