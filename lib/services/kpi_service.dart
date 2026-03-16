import 'package:cloud_firestore/cloud_firestore.dart';

class KPIService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>> getOSMetrics() {
    return _db.collection('ordens_servico').snapshots().map((snapshot) {
      int pendentes = 0;
      int emExecucao = 0;
      int finalizado = 0;
      int pausados = 0;
      int cancelados = 0;
      double totalHorasEstimadas = 0;
      double totalHorasReais = 0;
      double efi = 0;
      double leadTimeHoras = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        String status = (data['status'] ?? "").toString().toLowerCase();
        Timestamp? dataInicio = data['dataInicioEfetivo'];
        Timestamp? dataFim = data['dataFimEfetivo'];

        // Contagem por Status
        if (status.contains("pendente")) pendentes++;
        if (status.contains("execução") || status.contains("pausada"))
          emExecucao++;
        if (status.contains("finalizado") || status.contains("concluído"))
          finalizado++;
        if (status.contains("pausado")) pausados++;
        if (status.contains("cancelado")) cancelados++;

        totalHorasEstimadas += (data['horasEstimadas'] ?? 0).toDouble();
        totalHorasReais += (data['tempoTotalReal'] ?? 0) / 3600; //
        efi = (totalHorasReais / totalHorasEstimadas) * 100;
        if (dataInicio != null) {
          DateTime fim = dataFim?.toDate() ?? DateTime.now();
          leadTimeHoras =
              fim.difference(dataInicio.toDate()).inHours.toDouble();
        }
      }

      int total = snapshot.docs.length;

      return {
        "pendentes": pendentes,
        "emExecucao": emExecucao,
        "finalizado": finalizado,
        "total": total,
        "pausados": pausados,
        "cancelados": cancelados,
        "eficiencia": totalHorasEstimadas > 0 ? efi : 0,
        "leadTime": leadTimeHoras,
      };
    });
  }
}
