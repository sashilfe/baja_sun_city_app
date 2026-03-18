import 'package:cloud_firestore/cloud_firestore.dart';

class ItemEstoque {
  final String? id;
  final String nome;
  final String categoria;
  final double quantidadeAtual;
  final double quantidadeMinima;
  final String unidade;
  final String posicaoNoAlmoxarifado;
  final double? precoUnitario;
  final List<MovimentacaoEstoque> movimentacoes;

  const ItemEstoque({
    this.id,
    required this.nome,
    required this.categoria,
    required this.quantidadeAtual,
    required this.quantidadeMinima,
    required this.unidade,
    required this.posicaoNoAlmoxarifado,
    this.precoUnitario,
    this.movimentacoes = const [],
  });

  bool get estoqueBaixo => quantidadeAtual <= quantidadeMinima;

  factory ItemEstoque.fromFirestore(Map<String, dynamic> data, String id) {
    return ItemEstoque(
      id: id,
      nome: (data['nome'] ?? '') as String,
      categoria: (data['categoria'] ?? 'Consumiveis') as String,
      quantidadeAtual: _toDouble(data['quantidadeAtual']),
      quantidadeMinima: _toDouble(data['quantidadeMinima']),
      unidade: (data['unidade'] ?? 'un') as String,
      posicaoNoAlmoxarifado: (data['posicaoNoAlmoxarifado'] ?? '') as String,
      precoUnitario: data['precoUnitario'] != null
          ? _toDouble(data['precoUnitario'])
          : null,
      movimentacoes: (data['movimentacoes'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((mov) => MovimentacaoEstoque.fromMap(
              Map<String, dynamic>.from(mov as Map<dynamic, dynamic>)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categoria': categoria,
      'quantidadeAtual': quantidadeAtual,
      'quantidadeMinima': quantidadeMinima,
      'unidade': unidade,
      'posicaoNoAlmoxarifado': posicaoNoAlmoxarifado,
      'precoUnitario': precoUnitario,
      'movimentacoes': movimentacoes.map((mov) => mov.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class MovimentacaoEstoque {
  final String? id;
  final DateTime? data;
  final String tipo;
  final double quantidade;
  final String responsavelNome;
  final String? osId;
  final String? itemId;
  final String? itemNome;
  final String? unidade;
  final double? precoUnitario;

  const MovimentacaoEstoque({
    this.id,
    this.data,
    required this.tipo,
    required this.quantidade,
    required this.responsavelNome,
    this.osId,
    this.itemId,
    this.itemNome,
    this.unidade,
    this.precoUnitario,
  });

  double? get custoEstimado =>
      precoUnitario == null ? null : precoUnitario! * quantidade;

  factory MovimentacaoEstoque.fromMap(Map<String, dynamic> map, {String? id}) {
    return MovimentacaoEstoque(
      id: id,
      data: (map['data'] as Timestamp?)?.toDate(),
      tipo: (map['tipo'] ?? 'Saida') as String,
      quantidade: ItemEstoque._toDouble(map['quantidade']),
      responsavelNome: (map['responsavelNome'] ?? '') as String,
      osId: map['osId'] as String?,
      itemId: map['itemId'] as String?,
      itemNome: map['itemNome'] as String?,
      unidade: map['unidade'] as String?,
      precoUnitario: map['precoUnitario'] != null
          ? ItemEstoque._toDouble(map['precoUnitario'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data != null ? Timestamp.fromDate(data!) : FieldValue.serverTimestamp(),
      'tipo': tipo,
      'quantidade': quantidade,
      'responsavelNome': responsavelNome,
      'osId': osId,
      'itemId': itemId,
      'itemNome': itemNome,
      'unidade': unidade,
      'precoUnitario': precoUnitario,
    };
  }
}

class MaterialConsumidoRelatorio {
  final String itemId;
  final String itemNome;
  final String categoria;
  final double quantidadeConsumida;
  final String unidade;
  final double? precoUnitario;
  final double? custoEstimado;
  final DateTime? data;
  final String responsavelNome;
  final String osId;

  const MaterialConsumidoRelatorio({
    required this.itemId,
    required this.itemNome,
    required this.categoria,
    required this.quantidadeConsumida,
    required this.unidade,
    required this.precoUnitario,
    required this.custoEstimado,
    required this.data,
    required this.responsavelNome,
    required this.osId,
  });

  factory MaterialConsumidoRelatorio.fromMap(Map<String, dynamic> map) {
    final preco = map['precoUnitario'] != null
        ? ItemEstoque._toDouble(map['precoUnitario'])
        : null;
    final quantidade = ItemEstoque._toDouble(
      map['quantidadeConsumida'] ?? map['quantidade'],
    );

    return MaterialConsumidoRelatorio(
      itemId: (map['itemId'] ?? '') as String,
      itemNome: (map['itemNome'] ?? '') as String,
      categoria: (map['categoria'] ?? '') as String,
      quantidadeConsumida: quantidade,
      unidade: (map['unidade'] ?? 'un') as String,
      precoUnitario: preco,
      custoEstimado: map['custoEstimado'] != null
          ? ItemEstoque._toDouble(map['custoEstimado'])
          : (preco == null ? null : preco * quantidade),
      data: (map['data'] as Timestamp?)?.toDate(),
      responsavelNome: (map['responsavelNome'] ?? '') as String,
      osId: (map['osId'] ?? '') as String,
    );
  }
}
