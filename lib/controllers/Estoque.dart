import 'package:flutter/material.dart';

class EstoqueController extends ChangeNotifier {
  String _busca = '';
  String _categoriaFiltro = 'Todas';

  String get busca => _busca;
  String get categoriaFiltro => _categoriaFiltro;

  void setBusca(String value) {
    _busca = value;
    notifyListeners();
  }

  void setCategoriaFiltro(String value) {
    _categoriaFiltro = value;
    notifyListeners();
  }
}
