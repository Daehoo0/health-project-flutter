import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FullScreenDailyGoal(),
    );
  }
}

class FullScreenDailyGoal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Goal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Daily Goal',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '1,200',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Arrows and Today
            Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_left, size: 32, color: Colors.black),
                    onPressed: () {},
                  ),
                ),
                Center(
                  child: Text(
                    'Today',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.arrow_right, size: 32, color: Colors.black),
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Food & Drink Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Food & Drink',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),

            // Full-Width Table
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(4), // First column (Food name and serving)
                    1: FlexColumnWidth(1), // Second column (Calories)
                  },
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chicken & Rice',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '1 serving',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '450',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wine',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '5 oz',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '120',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
