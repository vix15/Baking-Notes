import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baking_notes/models/user.dart';
import 'package:baking_notes/models/auth_state.dart';
import 'package:baking_notes/screens/home_screen.dart';
import 'package:baking_notes/screens/register_screen.dart';
import 'package:baking_notes/widgets/theme_switch_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  
  // Variables para debugging de anuncios
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  String _adStatus = 'Inicializando AdMob...';
  String _adUnitId = '';
  bool _isAdMobInitialized = false;
  
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.repeat(reverse: true);
    
    // Inicializar debugging de AdMob
    _initializeAdMobWithDebug();
  }
  
  Future<void> _initializeAdMobWithDebug() async {
    try {
      print('🚀 Iniciando AdMob...');
      setState(() {
        _adStatus = 'Inicializando AdMob...';
      });
      
      // Verificar inicialización de AdMob
      final initializationStatus = await MobileAds.instance.initialize();
      
      print('✅ AdMob inicializado exitosamente');
      print('📊 Estado de adaptadores: ${initializationStatus.adapterStatuses}');
      
      setState(() {
        _isAdMobInitialized = true;
        _adStatus = 'AdMob inicializado. Cargando anuncio...';
      });
      
      // Configurar ID de anuncio
      _adUnitId = _getAdUnitId();
      print('🎯 Usando Ad Unit ID: $_adUnitId');
      
      // Cargar anuncio de prueba primero
      await _loadTestAd();
      
    } catch (e) {
      print('❌ Error inicializando AdMob: $e');
      setState(() {
        _adStatus = 'Error de inicialización: $e';
      });
    }
  }
  
  Future<void> _loadTestAd() async {
    try {
      print('📱 Cargando anuncio de prueba...');
      
      _bannerAd = BannerAd(
        adUnitId: _adUnitId,
        size: AdSize.banner,
        request: const AdRequest(
          keywords: ['cooking', 'baking', 'recipes', 'food'],
          nonPersonalizedAds: false,
        ),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('🎉 ¡ANUNCIO CARGADO EXITOSAMENTE!');
            
            setState(() {
              _isAdLoaded = true;
              _adStatus = '✅ Anuncio cargado correctamente';
            });
          },
          onAdFailedToLoad: (ad, error) {
            print('💥 ERROR AL CARGAR ANUNCIO:');
            print('   - Mensaje: ${error.message}');
            print('   - Código: ${error.code}');
            print('   - Dominio: ${error.domain}');
           
            
            ad.dispose();
            
            setState(() {
              _adStatus = 'Error ${error.code}: ${error.message}';
            });
            
            // Intentar con anuncio de prueba después de 3 segundos
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                _retryWithTestAd();
              }
            });
          },
          onAdOpened: (ad) {
            print('📱 Anuncio abierto');
          },
          onAdClosed: (ad) {
            print('❌ Anuncio cerrado');
          },
          onAdClicked: (ad) {
            print('👆 Anuncio clickeado');
          },
          onAdImpression: (ad) {
            print('👁️ Impresión de anuncio registrada');
          },
        ),
      );
      
      await _bannerAd?.load();
      
    } catch (e) {
      print('💥 Excepción al cargar anuncio: $e');
      setState(() {
        _adStatus = 'Excepción: $e';
      });
    }
  }
  
  void _retryWithTestAd() {
    print('🔄 Reintentando con anuncio de prueba...');
    setState(() {
      _adStatus = 'Reintentando con anuncio de prueba...';
    });
    
    _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;
    
    // Usar ID de prueba garantizado
    _adUnitId = Platform.isAndroid 
        ? 'ca-app-pub-3940256099942544/6300978111'  // Test ID Android
        : 'ca-app-pub-3940256099942544/2934735716'; // Test ID iOS
    
    print('🧪 Usando ID de prueba: $_adUnitId');
    _loadTestAd();
  }
  
  String _getAdUnitId() {
    // IMPORTANTE: Primero usar IDs de prueba para verificar que funciona
    if (Platform.isAndroid) {
      // ID de prueba para Android (SIEMPRE funciona)
      return 'ca-app-pub-7591325260034239/7744006452';
      
      // Una vez que funcione, descomenta tu ID real:
      // return '';
    } else if (Platform.isIOS) {
      // ID de prueba para iOS
      return 'ca-app-pub-7591325260034239/7744006452';
    }
    return '';
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }
  
  Widget _buildDebugAdWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de debug
          Text(
            'DEBUG INFO:',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Estado: $_adStatus',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            'AdMob Init: ${_isAdMobInitialized ? "✅" : "❌"}',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            'Ad Unit ID: $_adUnitId',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            'Plataforma: ${Platform.isAndroid ? "Android" : "iOS"}',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          
          const SizedBox(height: 12),
          
          // Anuncio o placeholder
          Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _isAdLoaded ? Colors.transparent : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _bannerAd != null && _isAdLoaded
                ? AdWidget(ad: _bannerAd!)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isAdLoaded) 
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          _isAdLoaded ? 'Anuncio cargado' : 'Cargando...',
                          style: TextStyle(
                            fontSize: 10,
                            color: _isAdLoaded ? Colors.white : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          
          // Botones de debug
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _bannerAd?.dispose();
                    _bannerAd = null;
                    _isAdLoaded = false;
                    _loadTestAd();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text(
                    'Recargar',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _retryWithTestAd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text(
                    'Test ID',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        final userBox = Hive.box<User>('users');
        final users = userBox.values.toList();
        
        final user = users.firstWhere(
          (user) => 
            user.email.toLowerCase() == _emailController.text.trim().toLowerCase() && 
            user.password == _passwordController.text,
          orElse: () => User(
            id: '',
            username: '',
            password: '',
            email: '',
            favoriteRecipeIds: [],
          ),
        );
        
        if (user.id.isEmpty) {
          setState(() {
            _errorMessage = 'Correo electrónico o contraseña incorrectos';
            _isLoading = false;
          });
          return;
        }
        
        final authBox = Hive.box<AuthState>('auth');
        final authState = AuthState(
          userId: user.id,
          lastLogin: DateTime.now(),
        );
        
        await authBox.put('currentUser', authState);
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(userId: user.id),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error al iniciar sesión: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: ThemeSwitchWidget(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Widget de debug de anuncios
                    _buildDebugAdWidget(),
                    
                    Center(
                      child: SizedBox(
                        height: 200,
                        child: Lottie.asset(
                          'assets/animations/baking.json',
                          controller: _animationController,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Notas de Repostería',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    const Text(
                      'Tu asistente de cocina personal',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 20),
                              
                              if (_errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              
                              if (_errorMessage != null)
                                const SizedBox(height: 20),
                              
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Correo Electrónico',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa tu correo electrónico';
                                  }
                                  if (!value.contains('@') || !value.contains('.')) {
                                    return 'Por favor ingresa un correo electrónico válido';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa tu contraseña';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 24),
                              
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                          'Iniciar Sesión',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '¿No tienes una cuenta?',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text('Regístrate'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}