import 'package:flutter/material.dart';

// Pop-up-ul original din TrackPanel
class WaypointDialog extends StatelessWidget {
  final String name;
  final bool isProducer;
  final bool visited;
  final VoidCallback onVisited;

  const WaypointDialog({
    super.key,
    required this.name,
    required this.isProducer,
    required this.visited,
    required this.onVisited,
  });

  @override
  Widget build(BuildContext context) {
    final popupColor = isProducer ? Colors.orange[700] : Colors.green[400];
    final gradientColors = [Colors.amber, Colors.yellow];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: popupColor,
      child: SizedBox(
        width: 380,
        height: 480,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          "assets/${name.toLowerCase()}.jpg",
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported, size: 100),
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
                      const SizedBox(height: 6),
                      Text(
                        "Some info about $name. Visit to learn more!",
                        style: const TextStyle(color: Colors.white),
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

// Butonul 3D pentru hartă
class MapButton extends StatelessWidget {
  final String label;
  final bool isProducer;
  final bool visited;
  final VoidCallback onVisited;

  const MapButton({
    super.key,
    required this.label,
    this.isProducer = false,
    this.visited = false,
    required this.onVisited,
  });

  @override
  Widget build(BuildContext context) {
    final frontColor = isProducer ? Colors.deepOrange : Colors.green;
    final backColor = isProducer ? Colors.orange[800] : Colors.green[800];

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
                isProducer: isProducer,
                visited: visited,
                onVisited: onVisited,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: frontColor,
            padding: const EdgeInsets.all(28),
            elevation: 0,
          ),
          child: Text(
            label[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
