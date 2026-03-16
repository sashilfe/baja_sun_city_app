import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrdemServico {
  final String? id;
  final String? codigoSequencial;
  final String? titulo;
  final String? descricao, subsistema, status, prioridade;
  final List<String>? responsavel;
  final DateTime? dataInicio;
  final int? horasEstimadas;
  final List<TimeLog>? logs;
  final List<OSDependencia>? dependentes;
  final Duration? tempoTotalReal;

  OrdemServico({
    this.id,
    this.codigoSequencial,
    this.titulo,
    this.descricao,
    this.subsistema,
    this.responsavel,
    this.status,
    this.prioridade,
    this.dataInicio,
    this.horasEstimadas,
    this.logs,
    this.dependentes,
    this.tempoTotalReal,
  });

  double get tempoTotalEmHoras {
    if (tempoTotalReal == null) return 0.0;
    return tempoTotalReal!.inSeconds / 3600;
  }

  // Formata para o Dashboard (ex: 2h 45m)
  String get tempoFormatado {
    if (tempoTotalReal == null || tempoTotalReal!.inSeconds == 0)
      return "0h 00m";

    int horas = tempoTotalReal!.inHours;
    int minutos = tempoTotalReal!.inMinutes.remainder(60);

    return "${horas}h ${minutos.toString().padLeft(2, '0')}m";
  }

  double get porcentagemConsumida {
    if (horasEstimadas == null || horasEstimadas == 0) return 0.0;

    // (Tempo Real / Tempo Estimado) * 100
    double percent = (tempoTotalEmHoras / horasEstimadas!) * 100;

    return percent;
  }

  Color get corStatusEficiencia {
    double percent = porcentagemConsumida;
    if (percent <= 80) return Colors.green; // Eficiente
    if (percent <= 100) return Colors.orange; // No limite
    return Colors.red; // Estourou o planejado
  }

  factory OrdemServico.fromFirestore(Map<String, dynamic> data, String id) {
    var responsavelData = data['responsavel'];
    List<String> listaTratada = [];
    if (responsavelData is List) {
      // Se já for uma lista, convertemos os itens para String com segurança
      listaTratada = responsavelData.map((e) => e.toString()).toList();
    } else if (responsavelData is String && responsavelData.isNotEmpty) {
      // Caso existam documentos antigos onde era apenas uma String, tratamos aqui
      listaTratada = [responsavelData];
    }

    return OrdemServico(
      id: id,
      codigoSequencial: data['codigoSequencial'] ?? '',
      titulo: data['titulo'] ?? '',
      descricao: data['descricao'] ?? '',
      subsistema: data['subsistema'] ?? '',
      responsavel: listaTratada,
      status: data['status'] ?? 'Pendente',
      prioridade: data['prioridade'] ?? 'Média',
      dataInicio: (data['dataInicio'] as Timestamp?)?.toDate(),
      horasEstimadas: data['horasEstimadas'] ?? 0,
      tempoTotalReal: Duration(seconds: data['tempoTotalReal'] ?? 0),
      dependentes: data['dependentes'] != null
          ? List<OSDependencia>.from((data['dependentes'] as List)
              .map((d) => OSDependencia.fromMap(d)))
          : [],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'codigoSequencial': codigoSequencial,
      'titulo': titulo,
      'descricao': descricao,
      'subsistema': subsistema,
      'responsavel': responsavel ?? [],
      'status': status,
      'prioridade': prioridade,
      'dataInicio': dataInicio,
      'horasEstimadas': horasEstimadas,
      'tempoTotalReal': tempoTotalReal?.inSeconds ?? 0,
      'dependentes': dependentes?.map((d) => d.toMap()).toList() ?? [],
    };
  }
}

class TimeLog {
  final DateTime inicio;
  final DateTime? fim;
  final String usuarioId;

  TimeLog({required this.inicio, this.fim, required this.usuarioId});
}

class ComentarioModel {
  final String id;
  final String usuarioId;
  final String mensagem;
  final DateTime createdAt;

  ComentarioModel(
      {required this.id,
      required this.usuarioId,
      required this.mensagem,
      required this.createdAt});
}

class HistoricoModel {
  final String acao;
  final String valorAnterior;
  final String valorNovo;
  final String usuarioId;
  final DateTime timestamp;

  HistoricoModel(
      {required this.acao,
      required this.valorAnterior,
      required this.valorNovo,
      required this.usuarioId,
      required this.timestamp});
}

class AnexoModel {
  final String nome;
  final String url;
  final String tipo;
  final String uploadedBy;
  final DateTime createdAt;

  AnexoModel(
      {required this.nome,
      required this.url,
      required this.tipo,
      required this.uploadedBy,
      required this.createdAt});
}

class OSDependencia {
  final String osId;
  final String tipo;
  final String codigoSequencial;

  OSDependencia({
    required this.osId,
    required this.tipo,
    required this.codigoSequencial,
  });

  Map<String, dynamic> toMap() {
    return {
      'osId': osId,
      'tipo': tipo,
    };
  }

  factory OSDependencia.fromMap(Map<String, dynamic> map) {
    return OSDependencia(
      osId: map['osId'],
      tipo: map['tipo'],
      codigoSequencial: map['codigoSequencial'] ?? '',
    );
  }
}
