import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get today's date
    final String today = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Hamburger menu + date
              Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Colors.green[400]),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    today,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[200],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Placeholder content
              Expanded(
                child: Center(
                  child: Text(
                    'Welcome to Nutrition Tracker!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
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
            ListTile(
              title: Text('Daily Log', style: TextStyle(color: Colors.grey[200])),
              onTap: () {},
            ),
            ListTile(
              title: Text('History', style: TextStyle(color: Colors.grey[200])),
              onTap: () {},
            ),
            ListTile(
              title: Text('Weekly Overview', style: TextStyle(color: Colors.grey[200])),
              onTap: () {},
            ),
            ListTile(
              title: Text('Settings', style: TextStyle(color: Colors.grey[200])),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
