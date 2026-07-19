import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: const Interval(0, 0.5, curve: Curves.easeOut)),
    );
    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _animCtrl, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );
    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeInOut)),
    );
    _animCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initApp());
  }

  Future<void> _initApp() async {
    final auth = context.read<AuthProvider>();
    await auth.checkSession();
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = prefs.getBool('show_onboarding') ?? true;
    if (!mounted) return;
    if (showOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.headerGradientStart, AppColors.headerGradientEnd, Color(0xFF002171)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -size.width * 0.3,
              right: -size.width * 0.2,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(8),
                ),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.15,
              left: -size.width * 0.25,
              child: Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(5),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _fadeIn,
                builder: (context, child) => Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: child,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset('assets/images/logo.jpeg', width: 100, height: 100, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('MoviCore', style: TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white,
                      letterSpacing: 1.2,
                    )),
                    const SizedBox(height: 8),
                    Text('Transporte Público Inteligente',
                        style: TextStyle(fontSize: 16, color: Colors.white.withAlpha(200))),
                    const SizedBox(height: 4),
                    Text('Quito', style: TextStyle(fontSize: 14, color: AppColors.secondaryLight.withAlpha(200))),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 40,
              right: 40,
              bottom: 80,
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress.value,
                        backgroundColor: Colors.white.withAlpha(30),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Cargando...', style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(150))),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: Text('v1.0.0', style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(100))),
            ),
          ],
        ),
      ),
    );
  }
}
