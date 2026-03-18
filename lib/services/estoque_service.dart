import 'package:admin/models/ItemEstoque.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EstoqueService {
  EstoqueService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _estoqueRef =>
      _db.collection('estoque_itens');

  Stream<List<ItemEstoque>> getItensEstoque() {
    return _estoqueRef
        .orderBy('nome')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemEstoque.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<MovimentacaoEstoque>> getMovimentacoesItem(String itemId) {
    return _estoqueRef
        .doc(itemId)
        .collection('movimentacoes')
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MovimentacaoEstoque.fromMap(doc.data(), id: doc.id))
            .toList());
  }

  Future<ItemEstoque?> getItemById(String itemId) async {
    final doc = await _estoqueRef.doc(itemId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ItemEstoque.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> salvarItem(ItemEstoque item) async {
    final isNovo = item.id == null || item.id!.isEmpty;
    final docRef = isNovo ? _estoqueRef.doc() : _estoqueRef.doc(item.id);
    final payload = {
      'id': docRef.id,
      ...item.toMap(),
    };

    if (isNovo) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(payload, SetOptions(merge: true));
  }

  Future<void> registrarEntrada({
    required String itemId,
    required double quantidade,
    required String responsavelNome,
  }) async {
    final itemRef = _estoqueRef.doc(itemId);

    await _db.runTransaction((transaction) async {
      final itemSnapshot = await transaction.get(itemRef);
      if (!itemSnapshot.exists || itemSnapshot.data() == null) {
        throw Exception('Item de estoque nao encontrado.');
      }

      final item = ItemEstoque.fromFirestore(itemSnapshot.data()!, itemSnapshot.id);
      final novaQuantidade = item.quantidadeAtual + quantidade;
      final movimentacaoRef = itemRef.collection('movimentacoes').doc();

      transaction.update(itemRef, {
        'quantidadeAtual': novaQuantidade,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(movimentacaoRef, {
        'data': FieldValue.serverTimestamp(),
        'tipo': 'Entrada',
        'quantidade': quantidade,
        'responsavelNome': responsavelNome,
        'itemId': item.id,
        'itemNome': item.nome,
        'categoria': item.categoria,
        'unidade': item.unidade,
        'precoUnitario': item.precoUnitario,
      });
    });
  }

  Future<List<MaterialConsumidoRelatorio>> getMateriaisConsumidosPorOS(
      String osId) async {
    final snapshot = await _db
        .collection('ordens_servico')
        .doc(osId)
        .collection('materiais_consumidos')
        .orderBy('data', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MaterialConsumidoRelatorio.fromMap(doc.data()))
        .toList();
  }

  Future<void> removerItem(String itemId) async {
    final itemRef = _estoqueRef.doc(itemId);
    final movimentacoes = await itemRef.collection('movimentacoes').limit(1).get();

    if (movimentacoes.docs.isNotEmpty) {
      throw Exception(
          'Nao e possivel remover um item que ja possui movimentacoes registradas.');
    }

    await itemRef.delete();
  }
}
