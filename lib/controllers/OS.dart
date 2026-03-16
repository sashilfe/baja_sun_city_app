import 'package:admin/models/OrdemServico.dart';
import 'package:admin/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OScontroller extends ChangeNotifier {
  List<OrdemServico> _ordensServico = [];
  List<OrdemServico> get ordensServico => _ordensServico;
  final FirestoreService _service = FirestoreService();

  Stream<List<OrdemServico>> get ordensStream => _service.getOrdensServico();

  Future<void> carregarOrdensServico() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('ordens_servico').get();

      _ordensServico = snapshot.docs
          .map((doc) => OrdemServico.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      print("Erro ao carregar OS: $e");
    }
  }

  Future<bool> podeIniciarOS(OrdemServico os) async {
    if (os.dependentes == null) return true;

    for (var dep in os.dependentes!) {
      OrdemServico? dependente = await FirestoreService().getOS(dep.osId);

      if (dep.tipo == "FS" && dependente!.status != "Finalizado") {
        return false;
      }

      if (dep.tipo == "SS" && dependente!.status == "Pendente") {
        return false;
      }
    }

    return true;
  }
}
