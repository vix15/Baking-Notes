import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:baking_notes/theme/theme_provider.dart';

class EnhancedTimerWidget extends StatefulWidget {
  const EnhancedTimerWidget({super.key});

  @override
  State<EnhancedTimerWidget> createState() => _EnhancedTimerWidgetState();
}

class _EnhancedTimerWidgetState extends State<EnhancedTimerWidget> {
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  int _selectedMinutes = 5;
  int _remainingSeconds = 0;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  final List<Map<String, dynamic>> _recentTimers = [];
  final List<int> _presetTimes = [1, 5, 10, 15, 30, 60];
  
  @override
  void initState() {
    super.initState();
    _loadRecentTimers();
    _preloadSound();
  }
  
  Future<void> _preloadSound() async {
    try {
      // Precargar el sonido para evitar retrasos
      await _audioPlayer.setSourceAsset('assets/sounds/timer_complete.mp3');
      await _audioPlayer.setVolume(1.0);
    } catch (e) {
      debugPrint('Error al precargar el sonido: $e');
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  void _loadRecentTimers() {
    // Aquí podrías cargar los temporizadores recientes desde una base de datos o preferencias
    _recentTimers.add({
      'name': 'Hornear galletas',
      'minutes': 15,
    });
    _recentTimers.add({
      'name': 'Batir crema',
      'minutes': 5,
    });
    _recentTimers.add({
      'name': 'Enfriar pastel',
      'minutes': 30,
    });
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
          _playAlarmSound();
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
  
  void _incrementTimer() {
    setState(() {
      _selectedMinutes++;
      if (_isTimerRunning) {
        _remainingSeconds += 60;
      }
    });
  }
  
  void _decrementTimer() {
    if (_selectedMinutes > 1) {
      setState(() {
        _selectedMinutes--;
        if (_isTimerRunning && _remainingSeconds > 60) {
          _remainingSeconds -= 60;
        }
      });
    }
  }
  
  Future<void> _playAlarmSound() async {
    try {
      // Reproducir el sonido varias veces para asegurarse de que se escuche
      await _audioPlayer.play(AssetSource('sounds/timer_alarm.mp3'));
      
      // Vibrar el dispositivo si está disponible
      try {
        // Importar el paquete de vibración si lo estás usando
        // import 'package:vibration/vibration.dart';
        // Vibration.vibrate(duration: 1000, amplitude: 128);
      } catch (e) {
        debugPrint('Vibración no disponible: $e');
      }
    } catch (e) {
      debugPrint('Error al reproducir el sonido: $e');
    }
  }
  
  void _showTimerCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temporizador Completado'),
        content: const Text('¡Tu temporizador ha terminado!'),
        actions: [
          TextButton(
            onPressed: () {
              _audioPlayer.stop();
              Navigator.pop(context);
            },
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Configurar Temporizador',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Temporizador principal
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón de disminuir
                  IconButton(
                    onPressed: _isTimerRunning ? _decrementTimer : _decrementTimer,
                    icon: const Icon(Icons.remove_circle),
                    color: Theme.of(context).primaryColor,
                    iconSize: 32,
                  ),
                  
                  // Tiempo seleccionado o restante
                  Text(
                    _isTimerRunning
                        ? _formatTime(_remainingSeconds)
                        : '$_selectedMinutes min',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Botón de aumentar
                  IconButton(
                    onPressed: _isTimerRunning ? _incrementTimer : _incrementTimer,
                    icon: const Icon(Icons.add_circle),
                    color: Theme.of(context).primaryColor,
                    iconSize: 32,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Slider para ajustar el tiempo
            Slider(
              value: _selectedMinutes.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              label: '$_selectedMinutes min',
              activeColor: Theme.of(context).primaryColor,
              onChanged: _isTimerRunning
                  ? null
                  : (value) {
                      setState(() {
                        _selectedMinutes = value.round();
                      });
                    },
            ),
            
            const SizedBox(height: 16),
            
            // Tiempos preestablecidos
            const Text(
              'Tiempos Preestablecidos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              children: _presetTimes.map((minutes) {
                return ActionChip(
                  label: Text('$minutes min'),
                  backgroundColor: _selectedMinutes == minutes
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : null,
                  onPressed: () {
                    setState(() {
                      _selectedMinutes = minutes;
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Historial reciente
            const Text(
              'Historial Reciente',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentTimers.length,
                itemBuilder: (context, index) {
                  final timer = _recentTimers[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMinutes = timer['minutes'];
                        });
                      },
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              timer['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${timer['minutes']} min',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botón de iniciar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isTimerRunning
                    ? (_isTimerPaused ? _resumeTimer : _pauseTimer)
                    : _startTimer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _isTimerRunning
                      ? (_isTimerPaused ? 'Reanudar Temporizador' : 'Pausar Temporizador')
                      : 'Iniciar Temporizador',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            if (_isTimerRunning)
              TextButton(
                onPressed: _cancelTimer,
                child: const Text('Cancelar'),
              ),
          ],
        ),
      ),
    );
  }
}