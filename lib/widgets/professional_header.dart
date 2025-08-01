import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ProfessionalHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final bool showElevation;
  final bool showGradient;
  final Widget? flexibleSpace;

  const ProfessionalHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.onBack,
    this.backgroundColor,
    this.showElevation = true,
    this.showGradient = false,
    this.flexibleSpace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determine background color with proper contrast
    final effectiveBackgroundColor = backgroundColor ?? 
        (showGradient ? null : colorScheme.surface);
    
    // Ensure text visibility with high contrast
    final textColor = _getContrastingTextColor(
      effectiveBackgroundColor ?? colorScheme.surface,
      colorScheme,
    );
    
    return AppBar(
      title: _buildTitle(context, textColor),
      leading: leading ?? (automaticallyImplyLeading && Navigator.canPop(context)
          ? _buildBackButton(context, textColor)
          : null),
      actions: actions?.map((action) => _wrapActionWithTheme(action, textColor)).toList(),
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      elevation: showElevation ? 4 : 0,
      scrolledUnderElevation: showElevation ? 8 : 0,
      backgroundColor: effectiveBackgroundColor,
      surfaceTintColor: Colors.transparent,
      foregroundColor: textColor,
      flexibleSpace: flexibleSpace ?? (showGradient ? _buildGradientBackground(colorScheme) : null),
      systemOverlayStyle: _getSystemOverlayStyle(textColor),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.15,
        height: 1.2,
      ),
      toolbarTextStyle: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(
        color: textColor,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: textColor,
        size: 24,
      ),
    );
  }

  Widget _buildTitle(BuildContext context, Color textColor) {
    if (subtitle != null) {
      return Column(
        crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.15,
              height: 1.1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor.withValues(alpha: 0.8),
              letterSpacing: 0.4,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }
    
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.15,
        height: 1.2,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBackButton(BuildContext context, Color textColor) {
    return IconButton(
      icon: Icon(
        MdiIcons.arrowLeft,
        color: textColor,
        size: 24,
      ),
      onPressed: onBack ?? () => Navigator.of(context).pop(),
      tooltip: 'Back',
      splashRadius: 20,
      padding: const EdgeInsets.all(8),
    );
  }

  Widget _wrapActionWithTheme(Widget action, Color textColor) {
    if (action is IconButton) {
      return IconButton(
        icon: action.icon,
        onPressed: action.onPressed,
        tooltip: action.tooltip,
        splashRadius: 20,
        padding: const EdgeInsets.all(8),
        color: textColor,
      );
    }
    
    if (action is TextButton) {
      return TextButton(
        onPressed: action.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: textColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.1,
          ),
        ),
        child: action.child!,
      );
    }
    
    return action;
  }

  Widget _buildGradientBackground(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
            colorScheme.primaryContainer,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Color _getContrastingTextColor(Color backgroundColor, ColorScheme colorScheme) {
    // Calculate luminance to determine if we need light or dark text
    final luminance = backgroundColor.computeLuminance();
    
    if (luminance > 0.5) {
      // Light background - use dark text
      return colorScheme.onSurface;
    } else {
      // Dark background - use light text
      return Colors.white;
    }
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(Color textColor) {
    final isLightText = textColor == Colors.white;
    
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isLightText ? Brightness.light : Brightness.dark,
      statusBarBrightness: isLightText ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isLightText ? Brightness.light : Brightness.dark,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 72 : kToolbarHeight);
}

// Enhanced header with additional features
class EnhancedProfessionalHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final VoidCallback? onBack;
  final Widget? bottom;
  final double? expandedHeight;
  final bool pinned;
  final bool floating;
  final bool snap;
  final Widget? background;
  final List<Widget>? tabs;

  const EnhancedProfessionalHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.onBack,
    this.bottom,
    this.expandedHeight,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.background,
    this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (expandedHeight != null || background != null) {
      return SliverAppBar(
        title: _buildTitle(context),
        leading: leading ?? (automaticallyImplyLeading && Navigator.canPop(context)
            ? _buildBackButton(context)
            : null),
        actions: actions,
        automaticallyImplyLeading: false,
        centerTitle: centerTitle,
        expandedHeight: expandedHeight ?? 200,
        pinned: pinned,
        floating: floating,
        snap: snap,
        elevation: 4,
        scrolledUnderElevation: 8,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        flexibleSpace: FlexibleSpaceBar(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              shadows: background != null ? [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black.withValues(alpha: 0.3),
                )
              ] : null,
            ),
          ),
          background: background,
          centerTitle: centerTitle,
          titlePadding: EdgeInsets.only(
            left: centerTitle ? 0 : 16,
            bottom: 16,
          ),
        ),
        bottom: bottom as PreferredSizeWidget? ?? (tabs != null ? TabBar(
          tabs: tabs!.map((tab) => Tab(child: tab)).toList(),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ) : null),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.light 
              ? Brightness.dark 
              : Brightness.light,
        ),
      );
    }

    return ProfessionalHeader(
      title: title,
      subtitle: subtitle,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      onBack: onBack,
      showElevation: true,
      showGradient: false,
    );
  }

  Widget _buildTitle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (subtitle != null) {
      return Column(
        crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: 0.15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              letterSpacing: 0.4,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }
    
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: 0.15,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        MdiIcons.arrowLeft,
        size: 24,
      ),
      onPressed: onBack ?? () => Navigator.of(context).pop(),
      tooltip: 'Back',
      splashRadius: 20,
      padding: const EdgeInsets.all(8),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    (expandedHeight ?? kToolbarHeight) + 
    ((bottom is PreferredSizeWidget) ? (bottom as PreferredSizeWidget).preferredSize.height : 0) +
    (subtitle != null ? 16 : 0)
  );
}

