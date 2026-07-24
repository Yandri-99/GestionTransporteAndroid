import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/notification_provider.dart';
import '../../../theme/app_colors.dart';
import '../../navigation/app_transitions.dart';
import '../public/routes_screen.dart';
import '../public/welcome_screen.dart';
import '../public/about_screen.dart';
import '../admin/incidents_screen.dart';
import '../admin/admin_home_screen.dart';
import '../auth/login_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/auth_guard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) {
        context.read<OrderProvider>().loadIncidents();
        context.read<NotificationProvider>().loadNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final notifProv = context.watch<NotificationProvider>();
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isSmall ? 200 : 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, isSmall ? 40 : 60, 24, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('MoviCore',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    themeProv.isDark ? Icons.light_mode : Icons.dark_mode,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => themeProv.toggleTheme(),
                                ),
                                if (auth.isLoggedIn)
                                  Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                                        onPressed: () => Navigator.push(context, AppTransitions.fadeSlide(const NotificationsScreen())),
                                      ),
                                      if (notifProv.unreadCount > 0)
                                        Positioned(
                                          right: 6,
                                          top: 6,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: AppColors.error,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${notifProv.unreadCount}',
                                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                if (auth.isLoggedIn)
                                  IconButton(
                                    icon: const Icon(Icons.logout, color: Colors.white),
                                    onPressed: () => _confirmLogout(context),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text('Transporte Público',
                            style: TextStyle(fontSize: isSmall ? 24 : 32, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Inteligente', style: TextStyle(fontSize: isSmall ? 16 : 20, color: Colors.white70)),
                        const SizedBox(height: 8),
                        const _RotatingMessage(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  _FeatureCard(
                    icon: Icons.route,
                    iconColor: AppColors.primary,
                    title: 'Explora las rutas de Quito',
                    subtitle: 'Descubre todas las rutas de transporte público disponibles en la ciudad.',
                    buttonLabel: 'Ver Rutas Disponibles',
                    buttonType: 'primary',
                    onPressed: () => Navigator.push(context, AppTransitions.fadeSlide(const RoutesScreen())),
                  ),
                  const SizedBox(height: 16),
                  if (auth.isLoggedIn)
                    _FeatureCard(
                      icon: Icons.map_outlined,
                      iconColor: AppColors.secondary,
                      title: 'Estado de las Rutas',
                      subtitle: 'Conoce las incidencias activas y el estado operativo del transporte en tiempo real.',
                      buttonLabel: 'Ver Incidencias',
                      buttonType: 'outlined',
                      onPressed: () => Navigator.push(context, AppTransitions.fadeSlide(const IncidentsScreen())),
                    ),
                  if (!auth.isLoggedIn)
                    _LoginPrompt(onPressed: () => Navigator.push(context, AppTransitions.fadeSlide(const LoginScreen()))),
                  if (auth.isAdmin) ...[
                    const SizedBox(height: 16),
                    _FeatureCard(
                      icon: Icons.dashboard_outlined,
                      iconColor: AppColors.tertiary,
                      title: 'Panel de Administración',
                      subtitle: 'Gestiona usuarios, incidencias y monitorea el sistema.',
                      buttonLabel: 'Ir al Panel Admin',
                      buttonType: 'tonal',
                      onPressed: () => Navigator.push(context, AppTransitions.fadeSlide(const AuthGuard(requireAdmin: true, child: AdminHomeScreen()))),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const _NewsBanner(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, AppTransitions.fadeSlide(const AboutScreen())),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Acerca de MoviCore'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, cerrar sesión')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final auth = context.read<AuthProvider>();
      await auth.logout();
      if (context.mounted) {
        Navigator.pushReplacement(context, AppTransitions.fadeSlide(const WelcomeScreen()));
      }
    }
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final String buttonType;
  final VoidCallback onPressed;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonType,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [iconColor.withAlpha(15), iconColor.withAlpha(5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: switch (buttonType) {
              'outlined' => OutlinedButton.icon(
                  onPressed: onPressed, icon: const Icon(Icons.flag_outlined), label: Text(buttonLabel)),
              'tonal' => FilledButton.tonalIcon(
                  onPressed: onPressed, icon: const Icon(Icons.shield_outlined), label: Text(buttonLabel)),
              _ => ElevatedButton.icon(
                  onPressed: onPressed, icon: const Icon(Icons.map_outlined), label: Text(buttonLabel)),
            },
          ),
        ],
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  final VoidCallback onPressed;
  const _LoginPrompt({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(Icons.person_outline, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('Inicia sesión para ver el estado de las rutas',
              style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.login),
              label: const Text('Iniciar Sesión'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsBanner extends StatelessWidget {
  const _NewsBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withAlpha(12), AppColors.secondary.withAlpha(8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.newspaper, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Noticias y Anuncios', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          _NewsItem(
            icon: Icons.info_outline,
            title: 'Nuevas rutas disponibles',
            subtitle: 'RT-ECO, RT-TRO, RT-ME1 y RT-SUR ya están operativas',
          ),
          const Divider(height: 20),
          _NewsItem(
            icon: Icons.map,
            title: 'Estado de las Rutas',
            subtitle: 'Consulta incidencias activas y estado operativo en tiempo real',
          ),
          const Divider(height: 20),
          _NewsItem(
            icon: Icons.map,
            title: 'Mapa interactivo',
            subtitle: 'Sigue tus rutas en tiempo real con el nuevo mapa',
          ),
        ],
      ),
    );
  }
}

class _NewsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _NewsItem({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _RotatingMessage extends StatefulWidget {
  const _RotatingMessage();

  @override
  State<_RotatingMessage> createState() => _RotatingMessageState();
}

class _RotatingMessageState extends State<_RotatingMessage>
    with SingleTickerProviderStateMixin {
  final List<String> _messages = [
    'Rutas actualizadas al instante',
    'Movilidad inteligente para Quito',
    'Tu transporte, tu ciudad',
    'Conectando Quito',
  ];
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _animCtrl.reverse().then((_) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % _messages.length);
        _animCtrl.forward();
      });
      _startTimer();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: Text(
        _messages[_index],
        style: const TextStyle(fontSize: 13, color: Colors.white70),
      ),
    );
  }
}
