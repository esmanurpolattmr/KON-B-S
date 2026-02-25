import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../merchant/screens/merchant_home_screen.dart';
import '../../courier/screens/courier_home_screen.dart';
import '../../buyer/screens/buyer_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedRole = -1; // 0=esnaf, 1=kurye, 2=alıcı

  void _proceed() {
    if (_selectedRole == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MerchantHomeScreen()),
      );
    } else if (_selectedRole == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CourierHomeScreen()),
      );
    } else if (_selectedRole == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BuyerHomeScreen()),
      );
    }
  }

  String get _buttonLabel {
    switch (_selectedRole) {
      case 0:
        return 'Esnaf olarak devam et';
      case 1:
        return 'Kurye olarak devam et';
      case 2:
        return 'Alıcı olarak devam et';
      default:
        return 'Rol seç';
    }
  }

  Color get _buttonColor {
    switch (_selectedRole) {
      case 0:
        return AppTheme.accentOrange;
      case 1:
        return AppTheme.primaryGreen;
      case 2:
        return AppTheme.accentBlue;
      default:
        return AppTheme.cardDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.directions_bike,
                      color: AppTheme.primaryGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'konbis',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
              const SizedBox(height: 48),
              Text(
                'Hoş geldin! 👋',
                style: Theme.of(context).textTheme.displayMedium,
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Rolünü seç ve başla.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 32),

              // Esnaf kartı
              _RoleCard(
                index: 0,
                selected: _selectedRole == 0,
                icon: Icons.store_rounded,
                title: 'Esnaf',
                subtitle: 'İlan aç, paketi kur, müşterine ulaştır',
                color: AppTheme.accentOrange,
                onTap: () => setState(() => _selectedRole = 0),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.15),
              const SizedBox(height: 12),

              // Alıcı kartı
              _RoleCard(
                index: 2,
                selected: _selectedRole == 2,
                icon: Icons.shopping_bag_rounded,
                title: 'Alıcı',
                subtitle: 'QR tarayarak teslimatını güvenle onayla',
                color: AppTheme.accentBlue,
                onTap: () => setState(() => _selectedRole = 2),
              )
                  .animate(delay: 280.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.15),
              const SizedBox(height: 12),

              // Kurye kartı
              _RoleCard(
                index: 1,
                selected: _selectedRole == 1,
                icon: Icons.directions_bike_rounded,
                title: 'Gönüllü Kurye',
                subtitle: 'Bisikletinle taşı, puan & CO₂ tasarrufu kazan',
                color: AppTheme.primaryGreen,
                onTap: () => setState(() => _selectedRole = 1),
              )
                  .animate(delay: 360.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.15),

              const Spacer(),
              AnimatedOpacity(
                opacity: _selectedRole >= 0 ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color:
                          _selectedRole >= 0 ? _buttonColor : AppTheme.cardDark,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _selectedRole >= 0 ? _proceed : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _buttonLabel,
                              style: const TextStyle(
                                color: AppTheme.darkNavy,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            if (_selectedRole >= 0) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                                color: AppTheme.darkNavy,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate(delay: 450.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final int index;
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.index,
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.12) : AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? color : Colors.transparent,
          width: 2,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? color : Colors.transparent,
                    border: Border.all(
                      color: selected ? color : AppTheme.textSecondary,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
