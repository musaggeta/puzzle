import 'package:flutter/material.dart';
import 'puzzle.dart';
import 'puzzleChessScreen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  double turns = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade100,
      appBar: AppBar(title: const Text('Menú de Juegos')),
      body: Center(
        child: AnimatedRotation(
          turns: turns,
          duration: const Duration(seconds: 1),
          child: AnimatedContainer(
            duration: const Duration(seconds: 1),
            width: 300,
            height: 300,
            child: Stack(
              children: [
                _menuButton(-1, 0, 'Puzzle', Colors.white, Colors.teal, () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 800),
                      pageBuilder: (context, animation, secondaryAnimation) => const PuzzleScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return ClipRect(
                          child: Align(
                            alignment: Alignment.topCenter,
                            heightFactor: animation.value,
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                }),
                _menuButton(1, 0, 'Ajedrez', Colors.white, Colors.teal, () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 800),
                      pageBuilder: (context, animation, secondaryAnimation) => const PuzzleChessScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return ClipRect(
                          child: Align(
                            alignment: Alignment.topCenter,
                            heightFactor: animation.value,
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                }),
                _menuButton(0, -1, 'Config', Colors.grey.shade200, Colors.grey.shade800, () {}),
                _menuButton(0, 1, 'Salir', Colors.grey.shade200, Colors.grey.shade800, () {}),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            turns = (turns + 1) % 2;
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _menuButton(double x, double y, String label, Color c1, Color c2, VoidCallback onTap) {
    return Align(
      alignment: Alignment(x, y),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: [c1, c2]),
            borderRadius: BorderRadius.circular(150),
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
