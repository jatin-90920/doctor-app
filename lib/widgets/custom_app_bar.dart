import 'package:flutter/material.dart';
import 'package:ayurvedic_doctor_crm/widgets/professional_header.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final bool showGradient;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = false,
    this.showGradient = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalHeader(
      title: title,
      subtitle: subtitle,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      onBack: onBack,
      backgroundColor: backgroundColor,
      showElevation: elevation != null ? elevation! > 0 : true,
      showGradient: showGradient,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 72 : kToolbarHeight);
}

