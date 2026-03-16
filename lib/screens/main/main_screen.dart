import 'package:admin/constants.dart';
import 'package:admin/controllers/MenuController.dart' as admin;
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:admin/screens/members/members_screen.dart';
import 'package:admin/screens/members/team_screen.dart';
import 'package:admin/screens/ordens/components/orders_details.dart';
import 'package:admin/screens/ordens/os_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      DashboardScreen(),
      OrdensServicoScreen(),
      Placeholder(), // Oficina
      Placeholder(), // Administrativo
      MembrosScreen(), // Gestão de Membros
      TeamScreen(), // Equipes
    ];

    return Scaffold(
      key: context.read<admin.MenuController>().scaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.all(defaultPadding), child: Header()),
                  Expanded(
                    child: Consumer<admin.MenuController>(
                      builder: (context, menuController, _) {
                        int index = menuController.selectedIndex;
                        if (index < 0 || index >= _screens.length) {
                          return Center(
                              child: Text(
                                  "Tela em desenvolvimento ou não encontrada"));
                        }
                        if (index == 1) {
                          // Índice da OrdensServicoScreen
                          if (menuController.selectedOsId != null) {
                            return OSDetailsScreen(
                                osId: menuController.selectedOsId!);
                          }
                        }

                        return _screens[index];
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
