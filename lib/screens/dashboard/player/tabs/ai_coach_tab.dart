import 'package:flutter/material.dart';

class AICoachTab extends StatelessWidget {
  const AICoachTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.computer, size: 100, color: Colors.blue),
          SizedBox(height: 20),
          Text(
            'AI Coach',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Get personalized feedback and coaching from our AI.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}