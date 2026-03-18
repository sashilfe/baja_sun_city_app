import 'package:admin/controllers/Auth.dart';
import 'package:admin/controllers/MenuController.dart' as admin;
import 'package:admin/models/Usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<admin.MenuController>();
    final authController = context.watch<AuthController>();
    final usuario = authController.usuario;
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset(
              "assets/images/logo1.png",
              height: 50,
              fit: BoxFit.contain,
              scale: 0.1,
            ),
          ),
          DrawerListTile(
            title: "Inicio",
            svgSrc: "assets/icons/menu_dashbord.svg",
            isActive: menuController.selectedIndex == 0,
            press: () => context.read<admin.MenuController>().setMenuIndex(0),
          ),
          DrawerListTile(
            title: "Ordens de Serviço",
            svgSrc: "assets/icons/menu_tran.svg",
            isActive: menuController.selectedIndex == 1,
            press: () => context.read<admin.MenuController>().setMenuIndex(1),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: menuController.selectedIndex == 2,
              title: Text(
                "Oficina",
                style: TextStyle(
                  color: menuController.selectedIndex == 2
                      ? Colors.orangeAccent
                      : Colors.white54,
                  fontWeight: menuController.selectedIndex == 2
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              leading: SvgPicture.asset(
                "assets/icons/menu_task.svg",
                height: 16,
                color: menuController.selectedIndex == 2
                    ? Colors.orangeAccent
                    : Colors.white54,
              ),
              children: [
                DrawerListTile(
                  title: "Controle de Peças",
                  svgSrc: "assets/icons/menu_store.svg",
                  isActive: menuController.selectedIndex == 2,
                  press: () =>
                      context.read<admin.MenuController>().setMenuIndex(2),
                ),
              ],
            ),
          ),
          DrawerListTile(
              title: "Administrativo",
              svgSrc: "assets/icons/menu_doc.svg",
              isActive: menuController.selectedIndex == 3,
              press:
                  () {} //=> context.read<admin.MenuController>().setMenuIndex(3),
              ),
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              title: Text(
                "Gestão de Pessoas",
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.normal,
                ),
              ),
              leading: SvgPicture.asset(
                "assets/icons/menu_store.svg",
                height: 16,
                color: Colors.white54,
              ),
              children: [
                if (usuario?.role == UserRole.admin ||
                    usuario?.role == UserRole.orientador)
                  DrawerListTile(
                    title: "Gestão de Membros",
                    svgSrc: "assets/icons/menu_store.svg",
                    isActive: menuController.selectedIndex == 4,
                    press: () =>
                        context.read<admin.MenuController>().setMenuIndex(4),
                  ),
                DrawerListTile(
                  title: "Equipes",
                  svgSrc:
                      "assets/icons/menu_tran.svg", // Dica: use um ícone diferente para Equipes
                  isActive: menuController.selectedIndex == 5,
                  press: () =>
                      context.read<admin.MenuController>().setMenuIndex(5),
                ),
              ],
            ),
          ),
          DrawerListTile(
            title: "Wiki",
            svgSrc: "assets/icons/menu_setting.svg",
            isActive: menuController.selectedIndex == 6,
            press: () => context.read<admin.MenuController>().setMenuIndex(6),
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {},
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile(
      {Key? key,
      // For selecting those three line once press "Command+D"
      required this.title,
      required this.svgSrc,
      required this.press,
      this.isActive = false})
      : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      selected: isActive,
      selectedTileColor: Colors.white10,
      leading: SvgPicture.asset(
        svgSrc,
        color: isActive ? Colors.orangeAccent : Colors.white54,
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.orangeAccent : Colors.white54,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
