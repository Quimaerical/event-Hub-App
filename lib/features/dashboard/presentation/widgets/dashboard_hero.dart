import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardHero extends StatelessWidget {
  const DashboardHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Colors.white, AppTheme.brandViolet],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          child: const Text(
            'Descubre Eventos del Hub',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Explora conferencias de tecnología, conciertos en vivo, talleres y asambleas organizadas por la comunidad.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
