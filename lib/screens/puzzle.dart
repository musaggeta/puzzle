import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/modelo.dart';
import 'dart:async';
import 'dart:async';
import 'package:collection/collection.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  List<Modelo> vNodo = [];
  int posicionPivote = 8;
  final Duration dur = const Duration(milliseconds: 500);
  final List<String> meta = ['MAYA','PAYA','KIMSA','PUSI','PHESKA','SOJTA','QALTA','KONTSA','X'];
  late Stopwatch _stopwatch;
  int _movimientos = 0;
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _crearPuzzle();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = _stopwatch.elapsed;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _crearPuzzle() {
    List<String> valores = [...meta];
    valores.shuffle();

    List<Offset> posiciones = [
      const Offset(-1, -1), const Offset(0, -1), const Offset(1, -1),
      const Offset(-1, 0), const Offset(0, 0), const Offset(1, 0),
      const Offset(-1, 1), const Offset(0, 1), const Offset(1, 1),
    ];

    vNodo = List.generate(9, (i) => Modelo(
      posiciones[i].dx,
      posiciones[i].dy,
      valores[i],
      valores[i] == 'X' ? Colors.white : Colors.primaries[i % Colors.primaries.length],
    ));

    posicionPivote = vNodo.indexWhere((e) => e.mensaje == 'X');
  }

  void _moverFicha(int index) {
    final nodo = vNodo[index];
    final pivote = vNodo[posicionPivote];

    final dx = nodo.x - pivote.x;
    final dy = nodo.y - pivote.y;

    if ((dx.abs() == 1 && dy == 0) || (dx == 0 && dy.abs() == 1)) {
      setState(() {
        final tempColor = nodo.color;
        final tempMensaje = nodo.mensaje;
        nodo.color = pivote.color;
        nodo.mensaje = pivote.mensaje;
        pivote.color = tempColor;
        pivote.mensaje = tempMensaje;
        posicionPivote = index;
        _movimientos++;
        _verificarGanador();
      });
    }
  }

  void _verificarGanador() {
    final actual = vNodo.map((n) => n.mensaje).toList();
    if (listEquals(actual, meta)) {
      _stopwatch.stop();
      final duracion = _stopwatch.elapsed;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Ganaste!'),
          content: Text('Tiempo: ${duracion.inSeconds} segundos\nMovimientos: $_movimientos'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _crearPuzzle();
                  _stopwatch.reset();
                  _stopwatch.start();
                  _movimientos = 0;
                });
              },
              child: const Text('Jugar de nuevo'),
            ),
          ],
        ),
      );
    }
  }

void _resolverAutomatico() async {
    // Implementación real del algoritmo A*
    final start = vNodo.map((e) => e.mensaje).toList();
    final goal = List.from(meta);

    List<List<String>> vecinos(List<String> estado) {
      int idx = estado.indexOf("X");
      int row = idx ~/ 3;
      int col = idx % 3;

      List<List<String>> res = [];
      List<List<int>> dirs = [[0,1],[1,0],[0,-1],[-1,0]];

      for (var dir in dirs) {
        int newRow = row + dir[0];
        int newCol = col + dir[1];
        if (newRow >= 0 && newRow < 3 && newCol >= 0 && newCol < 3) {
          int newIdx = newRow * 3 + newCol;
          List<String> copia = List.from(estado);
          copia[idx] = copia[newIdx];
          copia[newIdx] = "X";
          res.add(copia);
        }
      }
      return res;
    }

    int heuristica(List<String> estado) {
      int total = 0;
      for (int i = 0; i < estado.length; i++) {
        int idxGoal = goal.indexOf(estado[i]);
        total += (i % 3 - idxGoal % 3).abs() + (i ~/ 3 - idxGoal ~/ 3).abs();
      }
      return total;
    }

    final open = PriorityQueue<List<String>>((a, b) =>
      (heuristica(a)).compareTo(heuristica(b)));
    final cameFrom = <String, String>{};
    final visited = <String>{};

    open.add(start);
    cameFrom[start.join(",")] = "";

    while (open.isNotEmpty) {
      final current = open.removeFirst();
      final currentKey = current.join(",");
      if (visited.contains(currentKey)) continue;
      visited.add(currentKey);
      if (listEquals(current, goal)) break;
      for (final vecino in vecinos(current)) {
        final key = vecino.join(",");
        if (!visited.contains(key)) {
          open.add(vecino);
          cameFrom[key] = currentKey;
        }
      }
    }

    // reconstruir ruta
    List<List<String>> path = [];
    String? key = goal.join(",");
    while (key != null && key.isNotEmpty) {
      path.add(key.split(","));
      key = cameFrom[key];
    }
    path = path.reversed.toList();

    for (final estado in path) {
      await Future.delayed(dur);
      setState(() {
        for (int i = 0; i < 9; i++) {
          vNodo[i].mensaje = estado[i];
          vNodo[i].color = estado[i] == "X"
              ? Colors.white
              : Colors.primaries[i % Colors.primaries.length];
        }
        posicionPivote = vNodo.indexWhere((e) => e.mensaje == "X");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rompecabezas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Patrón Objetivo'),
                  content: SizedBox(
                    width: 180,
                    height: 180,
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      children: meta.map((m) => Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.grey.shade200,
                        ),
                        child: Text(m, style: const TextStyle(fontSize: 14)),
                      )).toList(),
                    ),
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _crearPuzzle();
                _stopwatch.reset();
                _stopwatch.start();
                _movimientos = 0;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Resolver automáticamente',
            onPressed: _resolverAutomatico,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text('Movimientos: $_movimientos | Tiempo: ${_elapsed.inSeconds}s'),
            ),
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  children: vNodo.asMap().entries.map((entry) {
                    final index = entry.key;
                    final nodo = entry.value;
                    return AnimatedAlign(
                      alignment: Alignment(nodo.x, nodo.y),
                      duration: dur,
                      curve: _curvaDeMovimiento(nodo),
                      child: GestureDetector(
                        onTap: () => _moverFicha(index),
                        child: AnimatedContainer(
                          duration: dur,
                          curve: Curves.easeInOut,
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: nodo.color,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              nodo.mensaje,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Curve _curvaDeMovimiento(Modelo nodo) {
    final pivote = vNodo[posicionPivote];
    final dx = nodo.x - pivote.x;
    final dy = nodo.y - pivote.y;
    if (dx != 0 && dy == 0) return Curves.elasticOut; // rebote horizontal
    if (dy != 0 && dx == 0) return Curves.bounceOut; // rebote vertical
    return Curves.easeInOut;
  }
}
