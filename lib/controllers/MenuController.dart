import 'package:flutter/material.dart';

class MenuController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  String? _selectedOsId;
  String? get selectedOsId => _selectedOsId;

  void setMenuIndex(int index) {
    _selectedIndex = index;
    _selectedOsId = null;
    notifyListeners();
  }

  void setSelectedOsId(String? osId) {
    _selectedIndex = 1;
    _selectedOsId = osId;
    notifyListeners();
  }

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  String get currentScreenTitle {
    if (_selectedOsId != null) {
      return "Detalhes da OS";
    }

    switch (_selectedIndex) {
      case 0:
        return "Inicio";
      case 1:
        return "Ordens de Serviço";
      case 2:
        return "Oficina";
      case 3:
        return "Administrativo";
      case 4:
        return "Gestão de Membros";
      case 5:
        return "Equipes";
      case 6:
        return "Configurações";
      default:
        return "SunSystem";
    }
  }
}
