import 'package:flutter/material.dart';
import 'package:frontend/pages/map_choice.dart';

class ScrollableBoxesPage extends StatefulWidget {
  const ScrollableBoxesPage({super.key});

  @override
  State<ScrollableBoxesPage> createState() => _ScrollableBoxesPageState();
}

class _ScrollableBoxesPageState extends State<ScrollableBoxesPage> {
  final List<Map<String, dynamic>> items = [
    {
      "name": "Marius Haru",
      "visited": false,
      "description":
          "Experience the tranquility of traditional fishing at Marius Haru's beautiful fish pond. Enjoy a full day of fishing for only 30 lei, surrounded by nature's peaceful embrace. Boat rides are also available for those seeking a serene journey across the calm waters.",
      "rating": 5,
      "color": const Color(0xFF1a4d3d),
      "gradientColors": [const Color(0xFFf59e0b), const Color(0xFFd97706)],
      "imagePath": "assets/balta.jpg",
    },
    {
      "name": "Angel Falls (Salto Ángel)",
      "visited": false,
      "description":
          "Angel Falls is a breathtaking natural wonder located deep within the Canaima National Park in Venezuela.",
      "rating": 4,
      "color": const Color(0xFF1a4d3d),
      "gradientColors": [const Color(0xFFf59e0b), const Color(0xFFd97706)],
      "imagePath": "assets/download.jpg",
    },
    {
      "name": "Luis \"El Seco\" Martinez",
      "visited": true,
      "description":
          "The Man: Luis is a fixture of the landscape, much like the rocks at the base of the falls.",
      "rating": 4,
      "color": const Color(0xFF6b3410),
      "gradientColors": [const Color(0xFFf59e0b), const Color(0xFFd97706)],
      "imagePath": "assets/ie.jpg",
    },
    {
      "name": "Local Producers Fair",
      "visited": false,
      "description":
          "Discover the best of local craftsmanship and fresh produce at the Local Producers Fair. Support small farmers, artisans, and makers while enjoying a vibrant market experience full of unique products and flavors.",
      "rating": 4,
      "color": const Color(0xFF1a4d3d),
      "gradientColors": [const Color(0xFFf59e0b), const Color(0xFFd97706)],
      "imagePath": "assets/img.jpg",
    },
    {
      "name": "Mountain View Cabin",
      "visited": false,
      "description":
          "Escape to the Mountain View Cabin, nestled in the heart of serene mountains. Enjoy hiking trails, fresh air, and cozy evenings by the fireplace.",
      "rating": 5,
      "color": const Color(0xFF6b3410),
      "gradientColors": [const Color(0xFFf59e0b), const Color(0xFFd97706)],
      "imagePath": "assets/mountain_cabin.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2d2d2d),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Row(
          children: [
            Icon(Icons.hiking, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Local Trip',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person, size: 16),
              label: const Text('paultiuc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a4d3d),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Buton "Generate Trail"
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapChoicePage(),
                          ),
                        );
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFf59e0b), Color(0xFFd97706)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.route, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Generate Trail',
                                style: TextStyle(
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
          // Grid cu locații
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio:
                      1, // Modificat de la 0.75 la 0.65 pentru carduri mai înalte
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: item['color'],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagine cu aspect ratio pătratic
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 2,
                              child: Image.asset(
                                item['imagePath'] ?? "",
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: Colors.black26,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 80,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Zonă expandabilă pentru conținut text
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < item['rating']
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: const Color(0xFFf59e0b),
                                        size: 18,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item['description'],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                    maxLines: 6, // Permitem mai multe linii
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Read more',
                                      style: TextStyle(
                                        color: Color(0xFFf59e0b),
                                        decoration: TextDecoration.underline,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Buton la final
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(() {
                                  items[index]['visited'] =
                                      !items[index]['visited'];
                                });
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: item['gradientColors'],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        item['visited']
                                            ? Icons.check_circle
                                            : Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item['visited']
                                            ? "Completed"
                                            : "Mark as complete",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
