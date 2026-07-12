import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  final _slides = [
    _OnboardingSlide(
      icon: Icons.route,
      title: 'Consulta Rutas',
      description: 'Explora todas las rutas de transporte público de Quito. '
          'Conoce paradas, horarios y el recorrido completo de cada línea.',
      color: AppColors.primary,
    ),
    _OnboardingSlide(
      icon: Icons.report_outlined,
      title: 'Reporta Incidencias',
      description: 'Notifica accidentes, fallas mecánicas o retrasos en las rutas. '
          'Ayuda a mantener informada a la comunidad de transporte.',
      color: AppColors.secondary,
    ),
    _OnboardingSlide(
      icon: Icons.dashboard_outlined,
      title: 'Gestión Inteligente',
      description: 'Administradores y conductores pueden gestionar viajes, '
          'incidencias y monitorear el sistema en tiempo real.',
      color: AppColors.tertiary,
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_onboarding', false);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140, height: 140,
                          decoration: BoxDecoration(
                            color: slide.color.withAlpha(15),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Icon(slide.icon, size: 64, color: slide.color),
                        ),
                        const SizedBox(height: 40),
                        Text(slide.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: slide.color,
                        )),
                        const SizedBox(height: 16),
                        Text(slide.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? 28 : 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _currentPage < _slides.length - 1
                          ? () => _pageCtrl.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut)
                          : _finishOnboarding,
                      child: Text(_currentPage < _slides.length - 1 ? 'Siguiente' : 'Comenzar'),
                    ),
                  ),
                  if (_currentPage < _slides.length - 1)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text('Omitir', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
