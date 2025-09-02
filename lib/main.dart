import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track selected screen
  String _currentScreen = 'Daily Log';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          BackgroundTriangles(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top app bar with hamburger
                  Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: Icon(Icons.menu, color: Colors.green[400]),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _currentScreen,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[400],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Placeholder content
                  Expanded(
                    child: Center(
                      child: Text(
                        '$_currentScreen content goes here',
                        style: TextStyle(color: Colors.grey[200], fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[600]),
              child: Text(
                'Navigation',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _drawerItem('Daily Log'),
            _drawerItem('History'),
            _drawerItem('Weekly Overview'),
            _drawerItem('Settings'),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(String title) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.grey[200]),
      ),
      onTap: () {
        setState(() => _currentScreen = title);
        Navigator.pop(context); // close drawer
      },
    );
  }
}

class BackgroundTriangles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: TriangleGradientPainter(),
    );
  }
}

class TriangleGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Triangle 1
    var path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(size.width * 0.5, 0);
    path1.lineTo(0, size.height * 0.5);
    path1.close();
    paint.shader = LinearGradient(
      colors: [Colors.grey[900]!, Colors.grey[700]!],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path1, paint);

    // Triangle 2 (example)
    var path2 = Path();
    path2.moveTo(size.width, size.height);
    path2.lineTo(size.width * 0.5, size.height);
    path2.lineTo(size.width, size.height * 0.5);
    path2.close();
    paint.shader = LinearGradient(
      colors: [Colors.grey[700]!, Colors.grey[500]!],
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
