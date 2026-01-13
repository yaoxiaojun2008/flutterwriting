import 'package:flutter/material.dart';
import 'writing_coach.dart'; // Import the writing coach screen

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
      title: 'Flutter Two Page App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirstPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16), // Reduced padding for smaller screens
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.login_rounded,
              size: 80, // Smaller icon for mobile
              color: Colors.blue,
            ),
            const SizedBox(height: 20), // Reduced spacing
            const Text(
              'Welcome!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28, // Smaller font for mobile
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), // Reduced spacing
            const Text(
              'Please login or register to continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, // Smaller font for mobile
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40), // Reduced spacing
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // More touch-friendly
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'START',
                style: TextStyle(
                  fontSize: 18, // Slightly smaller
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    double screenWidth = MediaQuery.of(context).size.width;
    
    // Adjust font sizes based on screen width
    double titleFontSize = screenWidth > 600 ? 24.0 : 20.0;
    double buttonFontSize = screenWidth > 600 ? 20.0 : 16.0;
    double buttonVerticalPadding = screenWidth > 600 ? 20.0 : 16.0;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16), // Reduced padding for smaller screens
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose an activity:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40), // Consistent spacing
            ElevatedButton(
              onPressed: () {
                // Navigate to the writing coach screen instead of showing an alert
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WritingCoachScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding, horizontal: 16),
                backgroundColor: Colors.green,
              ),
              child: Text(
                'Writing',
                style: TextStyle(
                  fontSize: buttonFontSize,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16), // Reduced spacing
            ElevatedButton(
              onPressed: () {
                // Reading functionality
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Reading'),
                      content: const Text('Reading functionality would go here'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding, horizontal: 16),
                backgroundColor: Colors.orange,
              ),
              child: Text(
                'Reading',
                style: TextStyle(
                  fontSize: buttonFontSize,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16), // Reduced spacing
            ElevatedButton(
              onPressed: () {
                // Evaluation functionality
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Evaluation'),
                      content: const Text('Evaluation functionality would go here'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding, horizontal: 16),
                backgroundColor: Colors.purple,
              ),
              child: Text(
                'Evaluation',
                style: TextStyle(
                  fontSize: buttonFontSize,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}