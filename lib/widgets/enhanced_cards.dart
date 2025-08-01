import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ayurvedic_doctor_crm/utils/enhanced_app_theme.dart';
import 'package:ayurvedic_doctor_crm/utils/responsive_utils.dart';

/// Enhanced stat card with modern styling
class EnhancedStatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? color;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trailing;
  final bool showTrend;
  final double? trendValue;
  
  const EnhancedStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.color,
    this.onTap,
    this.subtitle,
    this.trailing,
    this.showTrend = false,
    this.trendValue,
  });
  
  @override
  State<EnhancedStatCard> createState() => _EnhancedStatCardState();
}

class _EnhancedStatCardState extends State<EnhancedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: EnhancedAppTheme.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: ResponsiveUtils.getResponsiveCardMargin(context),
            decoration: BoxDecoration(
              borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
              boxShadow: _isHovered && isDesktop
                  ? EnhancedAppTheme.getElevationShadow(EnhancedAppTheme.elevationL)
                  : EnhancedAppTheme.getElevationShadow(EnhancedAppTheme.elevationS),
            ),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              child: InkWell(
                onTap: widget.onTap,
                onHover: isDesktop ? (hovering) {
                  setState(() {
                    _isHovered = hovering;
                  });
                  if (hovering) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                } : null,
                borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
                child: Container(
                  padding: ResponsiveUtils.getResponsivePadding(context),
                  decoration: BoxDecoration(
                    borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
                    gradient: _isHovered && isDesktop
                        ? LinearGradient(
                            colors: [
                              color.withValues(alpha: 0.05),
                              color.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                              ResponsiveUtils.getResponsiveValue(
                                context,
                                mobile: 12.0,
                                tablet: 16.0,
                                desktop: 20.0,
                              ),
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color.withValues(alpha: 0.1),
                                  color.withValues(alpha: 0.2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ResponsiveIcon(
                              widget.icon,
                              color: color,
                              mobileSize: 24,
                              tabletSize: 28,
                              desktopSize: 32,
                            ),
                          ),
                          const Spacer(),
                          if (widget.trailing != null) widget.trailing!,
                          if (widget.onTap != null && widget.trailing == null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ResponsiveIcon(
                                MdiIcons.chevronRight,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                mobileSize: 16,
                                tabletSize: 18,
                                desktopSize: 20,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveValue(
                        context,
                        mobile: 16.0,
                        tablet: 20.0,
                        desktop: 24.0,
                      )),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ResponsiveText(
                                  widget.value,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                  mobileFontSize: 28,
                                  tabletFontSize: 32,
                                  desktopFontSize: 36,
                                ),
                                const SizedBox(height: 4),
                                ResponsiveText(
                                  widget.title,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  mobileFontSize: 14,
                                  tabletFontSize: 16,
                                  desktopFontSize: 18,
                                ),
                                if (widget.subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  ResponsiveText(
                                    widget.subtitle!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                    ),
                                    mobileFontSize: 12,
                                    tabletFontSize: 14,
                                    desktopFontSize: 14,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (widget.showTrend && widget.trendValue != null)
                            _buildTrendIndicator(context, widget.trendValue!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTrendIndicator(BuildContext context, double trendValue) {
    final isPositive = trendValue >= 0;
    final color = isPositive 
        ? EnhancedAppTheme.customColors['success']!
        : EnhancedAppTheme.customColors['error']!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? MdiIcons.trendingUp : MdiIcons.trendingDown,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${trendValue.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Enhanced action card with modern styling
class EnhancedActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onPressed;
  final Color? color;
  final bool isLoading;
  
  const EnhancedActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onPressed,
    this.color,
    this.isLoading = false,
  });
  
  @override
  State<EnhancedActionCard> createState() => _EnhancedActionCardState();
}

class _EnhancedActionCardState extends State<EnhancedActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: EnhancedAppTheme.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
              boxShadow: EnhancedAppTheme.getElevationShadow(
                _isPressed ? EnhancedAppTheme.elevationXS : EnhancedAppTheme.elevationS,
              ),
            ),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed,
                onTapDown: (_) {
                  setState(() {
                    _isPressed = true;
                  });
                  _animationController.forward();
                },
                onTapUp: (_) {
                  setState(() {
                    _isPressed = false;
                  });
                  _animationController.reverse();
                },
                onTapCancel: () {
                  setState(() {
                    _isPressed = false;
                  });
                  _animationController.reverse();
                },
                borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveValue(
                      context,
                      mobile: 16.0,
                      tablet: 20.0,
                      desktop: 24.0,
                    ),
                    vertical: ResponsiveUtils.getResponsiveValue(
                      context,
                      mobile: 20.0,
                      tablet: 24.0,
                      desktop: 28.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading)
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveIconSize(context),
                          height: ResponsiveUtils.getResponsiveIconSize(context),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: color,
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.all(
                            ResponsiveUtils.getResponsiveValue(
                              context,
                              mobile: 12.0,
                              tablet: 16.0,
                              desktop: 20.0,
                            ),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.1),
                                color.withValues(alpha: 0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ResponsiveIcon(
                            widget.icon,
                            color: color,
                            mobileSize: 24,
                            tabletSize: 28,
                            desktopSize: 32,
                          ),
                        ),
                      SizedBox(height: ResponsiveUtils.getResponsiveValue(
                        context,
                        mobile: 12.0,
                        tablet: 16.0,
                        desktop: 20.0,
                      )),
                      ResponsiveText(
                        widget.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        mobileFontSize: 14,
                        tabletFontSize: 16,
                        desktopFontSize: 16,
                        textAlign: TextAlign.center,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        ResponsiveText(
                          widget.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          mobileFontSize: 12,
                          tabletFontSize: 14,
                          desktopFontSize: 14,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Enhanced info card with modern styling
class EnhancedInfoCard extends StatelessWidget {
  final String title;
  final Widget content;
  final IconData? icon;
  final Color? color;
  final Widget? trailing;
  final VoidCallback? onTap;
  
  const EnhancedInfoCard({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.color,
    this.trailing,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).colorScheme.primary;
    
    return Container(
      margin: ResponsiveUtils.getResponsiveCardMargin(context),
      decoration: BoxDecoration(
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        boxShadow: EnhancedAppTheme.getElevationShadow(EnhancedAppTheme.elevationS),
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
          child: Padding(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ResponsiveText(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        mobileFontSize: 16,
                        tabletFontSize: 18,
                        desktopFontSize: 20,
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 16.0,
                  tablet: 20.0,
                  desktop: 24.0,
                )),
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Enhanced gradient card
class EnhancedGradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  
  const EnhancedGradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.margin,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? ResponsiveUtils.getResponsiveCardMargin(context),
      decoration: BoxDecoration(
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        boxShadow: EnhancedAppTheme.getElevationShadow(EnhancedAppTheme.elevationM),
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
          child: Container(
            padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

