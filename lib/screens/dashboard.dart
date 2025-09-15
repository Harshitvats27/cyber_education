import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'menu_dashboard_screen.dart';
import 'main_dashboard_screen.dart';

class Dashboard extends StatefulWidget {
  final String role; // Use role instead of email
  const Dashboard({super.key, required this.role});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ZoomDrawerController _zoomDrawerController = ZoomDrawerController();

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _zoomDrawerController,
      style: DrawerStyle.defaultStyle,
      menuScreen: MenuDashboardScreen(
        role: widget.role,
        onItemSelected: () {; // ✅ prints role in terminal
          _zoomDrawerController.toggle?.call();        // toggles the drawer
        },
      ),

      mainScreen: MainDashboardScreen(role: widget.role),
      borderRadius: 24.0,
      showShadow: true,
      angle: -12.0,
      slideWidth: MediaQuery.of(context).size.width,
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.elasticInOut,
      drawerShadowsBackgroundColor: Colors.black87,
    );
  }
}
