import 'package:admin/models/OrdemServico.dart';
import 'package:admin/models/ItemEstoque.dart';
import 'package:admin/services/estoque_service.dart';
import 'package:admin/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OScontroller extends ChangeNotifier {
  List<OrdemServico> _ordensServico = [];
  List<OrdemServico> get ordensServico => _ordensServico;
  final FirestoreService _service = FirestoreService();
  final EstoqueService _estoqueService = EstoqueService();

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

  Future<void> vincularMaterialAOS(
    String osId,
    String itemId,
    double quantidade, {
    required String responsavelNome,
  }) async {
    final db = FirebaseFirestore.instance;
    final osRef = db.collection('ordens_servico').doc(osId);
    final itemRef = db.collection('estoque_itens').doc(itemId);

    await db.runTransaction((transaction) async {
      final osSnapshot = await transaction.get(osRef);
      final itemSnapshot = await transaction.get(itemRef);

      if (!osSnapshot.exists) {
        throw Exception('OS nao encontrada.');
      }

      if (!itemSnapshot.exists || itemSnapshot.data() == null) {
        throw Exception('Item de estoque nao encontrado.');
      }

      final item = ItemEstoque.fromFirestore(itemSnapshot.data()!, itemSnapshot.id);
      if (item.quantidadeAtual < quantidade) {
        throw Exception(
            'Estoque insuficiente para ${item.nome}. Saldo atual: ${item.quantidadeAtual.toStringAsFixed(2)} ${item.unidade}.');
      }

      final novaQuantidade = item.quantidadeAtual - quantidade;
      final movimentacaoRef = itemRef.collection('movimentacoes').doc();
      final consumoOSRef =
          osRef.collection('materiais_consumidos').doc(movimentacaoRef.id);

      final payload = {
        'data': FieldValue.serverTimestamp(),
        'tipo': 'Saida',
        'quantidade': quantidade,
        'responsavelNome': responsavelNome,
        'osId': osId,
        'itemId': item.id,
        'itemNome': item.nome,
        'categoria': item.categoria,
        'unidade': item.unidade,
        'precoUnitario': item.precoUnitario,
        'custoEstimado':
            item.precoUnitario == null ? null : item.precoUnitario! * quantidade,
      };

      transaction.update(itemRef, {
        'quantidadeAtual': novaQuantidade,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(movimentacaoRef, payload);
      transaction.set(consumoOSRef, payload);
      transaction.set(osRef.collection('historico').doc(), {
        'acao': 'Baixa de material no estoque',
        'usuario': responsavelNome,
        'data': FieldValue.serverTimestamp(),
        'detalhe':
            '${item.nome} - ${quantidade.toStringAsFixed(2)} ${item.unidade}',
      });
    });
  }

  Future<List<MaterialConsumidoRelatorio>> gerarRelatorioMateriaisOS(
      String osId) {
    return _estoqueService.getMateriaisConsumidosPorOS(osId);
  }
}
