import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn && mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.headerGradientStart, AppColors.headerGradientEnd, AppColors.secondaryDark, AppColors.secondary],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.directions_bus, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('MoviCore', style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,
                letterSpacing: 1.2,
              )),
              const SizedBox(height: 8),
              Text('Transporte Público Inteligente',
                  style: TextStyle(fontSize: 15, color: Colors.white.withAlpha(200))),
              const SizedBox(height: 4),
              Text('Quito - Ecuador', style: TextStyle(fontSize: 13, color: AppColors.secondaryLight.withAlpha(180))),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _WelcomeButton(
                      icon: Icons.login,
                      label: 'Iniciar Sesión',
                      color: AppColors.primary,
                      bgColor: Colors.white,
                      textColor: AppColors.primary,
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    ),
                    const SizedBox(height: 14),
                    _WelcomeButton(
                      icon: Icons.person_add_outlined,
                      label: 'Registrarse',
                      color: AppColors.secondary,
                      bgColor: Colors.white,
                      textColor: AppColors.secondary,
                      onTap: () => Navigator.pushNamed(context, '/register'),
                    ),
                    const SizedBox(height: 14),
                    _WelcomeButton(
                      icon: Icons.map_outlined,
                      label: 'Explorar como invitado',
                      color: AppColors.tertiary,
                      bgColor: Colors.white.withAlpha(20),
                      textColor: Colors.white,
                      subtitle: 'Ver rutas sin necesidad de registro',
                      onTap: () => Navigator.pushNamed(context, '/routes'),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final Color textColor;
  final String? subtitle;
  final VoidCallback onTap;

  const _WelcomeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.textColor,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: bgColor == Colors.white
                  ? null
                  : Border.all(color: Colors.white.withAlpha(50)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: color.withAlpha(bgColor == Colors.white ? 20 : 40),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: textColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: textColor,
                      )),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: TextStyle(
                          fontSize: 12, color: textColor.withAlpha(180),
                        )),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: textColor.withAlpha(150)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
