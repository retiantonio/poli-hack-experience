import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/pages/account.dart';

// -------------------- 1. Serviciu Rețea --------------------
class RouteService {
  static Future<List<Map<String, dynamic>>> fetchWaypoints(String city) async {
    final uri = Uri.parse(
      "http://172.20.10.2:8000/get-route/",
    ).replace(queryParameters: {'city': city});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load waypoints: ${response.statusCode}');
    }
  }
}

// -------------------- 2. Ecran Harta --------------------
class MapScreen extends StatefulWidget {
  final String selectedCity;
  const MapScreen({super.key, required this.selectedCity});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> waypoints = [];
  Map<String, bool> visited = {};
  bool loading = true;

  double latTop = 0, latBottom = 0, lonLeft = 0, lonRight = 0;
  final double mapWidth = 2000, mapHeight = 2000;

  late AnimationController _ringController;
  Animation<double>? _ringAnimation;
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();

    _ringController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _ringAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );

    _fetchWaypoints();
  }

  Future<void> _fetchWaypoints() async {
    try {
      final data = await RouteService.fetchWaypoints(widget.selectedCity);
      if (!mounted) return;

      setState(() {
        waypoints = data;
        visited = {for (var wp in waypoints) wp["name"]: false};

        if (waypoints.isNotEmpty) {
          var lats = waypoints.map((wp) => wp["lat"] as double).toList();
          var lons = waypoints.map((wp) => wp["lon"] as double).toList();

          latTop = lats.reduce(max) + 0.002;
          latBottom = lats.reduce(min) - 0.002;
          lonLeft = lons.reduce(min) - 0.002;
          lonRight = lons.reduce(max) + 0.002;
        }

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      username = prefs.getString("username");
    });
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  int get currentWaypointIndex {
    for (int i = 0; i < waypoints.length; i++) {
      if (!visited[waypoints[i]["name"]]!) return i;
    }
    return -1;
  }

  Offset latLonToPixel(double lat, double lon) {
    if (lonRight == lonLeft || latTop == latBottom) return const Offset(0, 0);
    double x = (lon - lonLeft) / (lonRight - lonLeft) * mapWidth;
    double y = (latTop - lat) / (latTop - latBottom) * mapHeight;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 15, 30, 27),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.hiking, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Local Trip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 12, 58, 45),
        actions: [
          if (username != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 61, 105, 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserProfilePage()),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      username!,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 15, 30, 27),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          boundaryMargin: const EdgeInsets.all(100),
          constrained: false,
          child: SizedBox(
            width: mapWidth,
            height: mapHeight,
            child: Stack(
              children: [
                Container(
                  width: mapWidth,
                  height: mapHeight,
                  color: const Color.fromARGB(255, 15, 30, 27),
                ),
                CustomPaint(
                  size: Size(mapWidth, mapHeight),
                  painter: RoutePainter(
                    waypoints: waypoints,
                    latLonToPixel: latLonToPixel,
                  ),
                ),
                if (currentWaypointIndex >= 0 && _ringAnimation != null)
                  AnimatedBuilder(
                    animation: _ringAnimation!,
                    builder: (context, child) {
                      final wp = waypoints[currentWaypointIndex];
                      final offset = latLonToPixel(wp["lat"], wp["lon"]);
                      const double ringSize = 90.0, verticalOffset = 10.0;
                      return Positioned(
                        left: offset.dx - ringSize / 2,
                        top: offset.dy - ringSize / 2 + verticalOffset,
                        child: Transform.scale(
                          scale: _ringAnimation!.value,
                          child: Container(
                            width: ringSize,
                            height: ringSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.amber, width: 4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ...waypoints.map((wp) {
                  final offset = latLonToPixel(wp["lat"], wp["lon"]);
                  final type = wp["type"]?.toString().toLowerCase() ?? "";
                  final description = wp["description"]?.toString() ?? "";
                  final imageUrl = wp["image"]?.toString() ?? "";
                  final rating = (wp["rating"] as num?)?.toInt() ?? 4;
                  return Positioned(
                    left: offset.dx - 35,
                    top: offset.dy - 35,
                    child: MapButton(
                      label: wp["name"],
                      type: type,
                      description: description,
                      imageUrl: imageUrl,
                      rating: rating,
                      visited: visited[wp["name"]] ?? false,
                      onVisited: () =>
                          setState(() => visited[wp["name"]] = true),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- 3. RoutePainter --------------------
class RoutePainter extends CustomPainter {
  final List<Map<String, dynamic>> waypoints;
  final Offset Function(double lat, double lon) latLonToPixel;
  RoutePainter({required this.waypoints, required this.latLonToPixel});

  @override
  void paint(Canvas canvas, Size size) {
    if (waypoints.length < 2) return;
    final paint = Paint()
      ..color = const Color.fromARGB(255, 109, 151, 115)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < waypoints.length - 1; i++) {
      final start = latLonToPixel(waypoints[i]["lat"], waypoints[i]["lon"]);
      final end = latLonToPixel(
        waypoints[i + 1]["lat"],
        waypoints[i + 1]["lon"],
      );

      final midX = (start.dx + end.dx) / 2;
      final midY = (start.dy + end.dy) / 2;
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final length = sqrt(dx * dx + dy * dy);
      if (length == 0) continue;

      final offsetAmount = length * 0.15;
      final control = Offset(
        midX - dy / length * offsetAmount,
        midY + dx / length * offsetAmount,
      );
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(RoutePainter oldDelegate) =>
      waypoints != oldDelegate.waypoints;
}

// -------------------- 4. MapButton --------------------
class MapButton extends StatelessWidget {
  final String label, type, description, imageUrl;
  final bool visited;
  final int rating;
  final VoidCallback onVisited;

  const MapButton({
    super.key,
    required this.label,
    required this.type,
    required this.description,
    required this.imageUrl,
    this.visited = false,
    required this.onVisited,
    this.rating = 4,
  });

  @override
  Widget build(BuildContext context) {
    Color frontColor, backColor;
    Widget content;

    if (type == "vendor") {
      frontColor = const Color.fromARGB(255, 230, 84, 39);
      backColor = const Color.fromARGB(255, 122, 36, 13);
      content = const Icon(Icons.person, color: Colors.white, size: 24);
    } else {
      frontColor = const Color.fromARGB(255, 108, 151, 114);
      backColor = const Color.fromARGB(255, 11, 58, 44);
      content = const Icon(Icons.place, color: Colors.white, size: 24);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, 5),
          child: Container(
            width: 70,
            height: 90,
            decoration: BoxDecoration(color: backColor, shape: BoxShape.circle),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => WaypointDialog(
                name: label,
                type: type,
                description: description,
                imageUrl: imageUrl,
                rating: rating,
                visited: visited,
                onVisited: onVisited,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: frontColor,
            fixedSize: const Size(70, 70),
            padding: EdgeInsets.zero,
            elevation: 0,
          ),
          child: content,
        ),
      ],
    );
  }
}

// -------------------- 5. WaypointDialog --------------------
class WaypointDialog extends StatelessWidget {
  final String name, type, description, imageUrl;
  final bool visited;
  final int rating;
  final VoidCallback onVisited;

  const WaypointDialog({
    super.key,
    required this.name,
    required this.type,
    required this.description,
    required this.imageUrl,
    required this.visited,
    required this.onVisited,
    this.rating = 4,
  });

  // Convertește numele în format valid pentru asset
  String _formatAssetName(String name) {
    return name.toLowerCase().replaceAll(' ', '_');
  }

  List<Widget> _buildRatingStars(int rating) => List.generate(
    5,
    (i) => Icon(
      Icons.star,
      color: i < rating ? Colors.amber : Colors.white38,
      size: 20,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final popupColor = type == "vendor"
        ? const Color.fromARGB(255, 124, 72, 15)
        : const Color.fromARGB(255, 12, 58, 45);
    final gradientColors = [
      const Color.fromARGB(255, 178, 107, 27),
      const Color.fromARGB(255, 252, 184, 1),
    ];

    // Path-ul corect pentru asset
    final assetPath = "assets/${_formatAssetName(name)}.jpg";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: popupColor,
      child: SizedBox(
        width: 380,
        height: 480,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagine din asset
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          assetPath,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("Failed to load image: $assetPath");
                            return Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[800],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                    color: Colors.white54,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Missing: ${_formatAssetName(name)}.jpg',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(children: _buildRatingStars(rating)),
                      const SizedBox(height: 6),
                      Text(
                        description.isNotEmpty
                            ? description
                            : "Some info about $name. Visit to learn more!",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      onVisited();
                      Navigator.pop(context);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        constraints: const BoxConstraints(minWidth: 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              visited ? "Visited" : "Mark as Visited",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
