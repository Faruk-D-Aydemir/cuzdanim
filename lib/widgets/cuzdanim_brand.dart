import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class CuzdanimBrand extends StatelessWidget {
  const CuzdanimBrand({
    super.key,
    this.compact = false,
    this.showTagline = true,
  });

  final bool compact;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;
    final size = compact ? 52.0 : 72.0;
    final iconSize = compact ? 26.0 : 36.0;
    final titleSize = compact ? 20.0 : 26.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient(context),
            borderRadius: BorderRadius.circular(compact ? 18 : 24),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.22),
                blurRadius: compact ? 16 : 24,
                offset: Offset(0, compact ? 8 : 12),
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: iconSize,
            color: Colors.white,
          ),
        ),
        SizedBox(height: compact ? 6 : 10),
        Text(
          l10n.appName,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: compact ? primary : null,
          ),
        ),
        if (showTagline && !compact) ...[
          const SizedBox(height: 6),
          Text(
            l10n.authTagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}

class SoftHeroCard extends StatelessWidget {
  const SoftHeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -40,
          child: _blob(primary.withValues(alpha: isDark ? 0.12 : 0.08), 180),
        ),
        Positioned(
          top: 120,
          left: -60,
          child: _blob(
            Theme.of(context).colorScheme.secondary.withValues(alpha: isDark ? 0.1 : 0.06),
            140,
          ),
        ),
        child,
      ],
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
