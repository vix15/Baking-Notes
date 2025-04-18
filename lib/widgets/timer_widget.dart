import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  int _selectedMinutes = 5;
  int _remainingSeconds = 0;
  Timer? _timer;
  
  final List<int> _presetTimes = [1, 5, 10, 15, 30, 60];
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _isTimerPaused = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isTimerRunning = false;
          _showTimerCompleteDialog();
        }
      });
    });
  }
  
  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerPaused = true;
    });
  }
  
  void _resumeTimer() {
    _startTimer();
  }
  
  void _cancelTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _isTimerPaused = false;
    });
  }
  
  void _showTimerCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temporizador Completado'),
        content: const Text('¡Tu temporizador ha terminado!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isTimerRunning) {
          _showTimerDialog();
        } else {
          _showRunningTimerDialog();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isTimerRunning ? const Color(0xFFF8BBD0) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer,
              size: 18,
              color: _isTimerRunning ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              _isTimerRunning
                  ? _formatTime(_remainingSeconds)
                  : 'Temporizador',
              style: TextStyle(
                color: _isTimerRunning ? Colors.white : Colors.grey.shade700,
                fontWeight: _isTimerRunning ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar Temporizador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona un tiempo:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetTimes.map((minutes) {
                return ChoiceChip(
                  label: Text('$minutes min'),
                  selected: _selectedMinutes == minutes,
                  selectedColor: const Color(0xFFF8BBD0),
                  onSelected: (selected) {
                    setState(() {
                      _selectedMinutes = minutes;
                    });
                    Navigator.pop(context);
                    _startTimer();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('O establece un tiempo personalizado:'),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutos',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final minutes = int.tryParse(value);
                if (minutes != null && minutes > 0) {
                  setState(() {
                    _selectedMinutes = minutes;
                  });
                  Navigator.pop(context);
                  _startTimer();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
  
  void _showRunningTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temporizador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8BBD0),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isTimerPaused)
                  ElevatedButton(
                    onPressed: () {
                      _resumeTimer();
                      Navigator.pop(context);
                    },
                    child: const Text('Reanudar'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      _pauseTimer();
                      Navigator.pop(context);
                    },
                    child: const Text('Pausar'),
                  ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _cancelTimer();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}