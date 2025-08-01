import 'package:flutter/material.dart';

/// Responsive breakpoints
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double smallLaptop = 1200;
  static const double desktop = 1440;
}

/// Screen size types
enum ScreenType { mobile, tablet, smallLaptop, desktop }

/// Responsive utility class
class ResponsiveUtils {
  /// Get the current screen type based on width
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < ResponsiveBreakpoints.mobile) {
      return ScreenType.mobile;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return ScreenType.tablet;
    } else if (width < ResponsiveBreakpoints.smallLaptop) {
      return ScreenType.smallLaptop;
    } else {
      return ScreenType.desktop;
    }
  }
  
  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }
  
  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }
  
  /// Check if current screen is small laptop
  static bool isSmallLaptop(BuildContext context) {
    return getScreenType(context) == ScreenType.smallLaptop;
  }
  
  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }
  
  /// Get responsive value based on screen type
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? smallLaptop,
    T? desktop,
  }) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.smallLaptop:
        return smallLaptop ?? tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? smallLaptop ?? tablet ?? mobile;
    }
  }
  
  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(20),
      smallLaptop: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }
  
  /// Get responsive card margin
  static EdgeInsets getResponsiveCardMargin(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tablet: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      smallLaptop: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      desktop: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    );
  }
  
  /// Get responsive grid columns
  static int getResponsiveColumns(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 1,
      tablet: 2,
      smallLaptop: 2,
      desktop: 3,
    );
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? smallLaptop,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.05,
      smallLaptop: smallLaptop ?? mobile * 1.1,
      desktop: desktop ?? mobile * 1.2,
    );
  }
  
  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 24.0,
      tablet: 26.0,
      smallLaptop: 28.0,
      desktop: 32.0,
    );
  }
  
  /// Get responsive card elevation
  static double getResponsiveElevation(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 2.0,
      tablet: 3.0,
      smallLaptop: 4.0,
      desktop: 8.0,
    );
  }
  
  /// Get responsive border radius
  static BorderRadius getResponsiveBorderRadius(BuildContext context) {
    return BorderRadius.circular(
      getResponsiveValue(
        context,
        mobile: 8.0,
        tablet: 10.0,
        smallLaptop: 12.0,
        desktop: 16.0,
      ),
    );
  }
}

/// Responsive layout widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? smallLaptop;
  final Widget? desktop;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.smallLaptop,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      smallLaptop: smallLaptop,
      desktop: desktop,
    );
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? smallLaptopColumns;
  final int? desktopColumns;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.mobileColumns,
    this.tabletColumns,
    this.smallLaptopColumns,
    this.desktopColumns,
  });
  
  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      smallLaptop: smallLaptopColumns ?? 2,
      desktop: desktopColumns ?? 3,
    );
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// Responsive card widget
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? color;
  final VoidCallback? onTap;
  
  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    final responsiveMargin = margin ?? ResponsiveUtils.getResponsiveCardMargin(context);
    final responsiveElevation = elevation ?? ResponsiveUtils.getResponsiveElevation(context);
    
    return Container(
      margin: responsiveMargin,
      child: Card(
        elevation: responsiveElevation,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
          child: Padding(
            padding: responsivePadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? smallLaptopFontSize;
  final double? desktopFontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileFontSize,
    this.tabletFontSize,
    this.smallLaptopFontSize,
    this.desktopFontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsiveFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      mobile: mobileFontSize ?? 14.0,
      tablet: tabletFontSize,
      smallLaptop: smallLaptopFontSize,
      desktop: desktopFontSize,
    );
    
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: responsiveFontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive icon widget
class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? mobileSize;
  final double? tabletSize;
  final double? smallLaptopSize;
  final double? desktopSize;
  
  const ResponsiveIcon(
    this.icon, {
    super.key,
    this.color,
    this.mobileSize,
    this.tabletSize,
    this.smallLaptopSize,
    this.desktopSize,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsiveSize = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: mobileSize ?? 24.0,
      tablet: tabletSize ?? 26.0,
      smallLaptop: smallLaptopSize ?? 28.0,
      desktop: desktopSize ?? 32.0,
    );
    
    return Icon(
      icon,
      color: color,
      size: responsiveSize,
    );
  }
}

