import 'package:flutter/material.dart';
import '../../core/theme/dsaialap_glass.dart';
import '../chats/e2ee_cloud_hub_screen.dart';
import '../dialer/smart_dialer_screen.dart';
import '../mesh/offgrid_mesh_radar_screen.dart';
import '../settings/saas_settings_portal_screen.dart';
import 'connection_status_badge.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _index = 0;

  static const _pages = [
    E2eeCloudHubScreen(),
    OffgridMeshRadarScreen(),
    SmartDialerScreen(),
    SaasSettingsPortalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsaialapTokens.oled,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('dsaialap', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: ConnectionStatusBadge()),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xEE0B1018),
        indicatorColor: DsaialapTokens.neonCyan.withValues(alpha: 0.18),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.lock_outline), selectedIcon: Icon(Icons.lock), label: 'Cloud'),
          NavigationDestination(icon: Icon(Icons.radar), selectedIcon: Icon(Icons.radar), label: 'Mesh'),
          NavigationDestination(icon: Icon(Icons.dialpad), selectedIcon: Icon(Icons.dialpad), label: 'Dialer'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Portal'),
        ],
      ),
    );
  }
}
