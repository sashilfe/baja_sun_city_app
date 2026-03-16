import 'package:admin/constants.dart';
import 'package:admin/models/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberKPITab extends StatelessWidget {
  final Usuario user;
  const MemberKPITab({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ordens_servico')
          .where('responsavel', arrayContains: user.nome)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        double totalEsforco = 0;
        double totalLeadTime = 0;
        double totalEstimado = 0;
        int concluidas = 0;
        int ossAtivas = 0;
        int ossFinalizadasNoPrazo = 0;
        int totalConcluidas = 0;

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          String status = data['status'] ?? "";
          print("OS: ${doc.id} | Status: $status");
          double horasEstimadas = (data['horasEstimadas'] ?? 0).toDouble();
          double tempoRealHoras = (data['tempoTotalReal'] ?? 0) / 3600;
          if (status == "Em Execução" || status == "Pausada") {
            print("OS Ativa: ${doc.id} | Status: $status");
            ossAtivas++;
          }
          if (status == "Finalizado") {
            totalConcluidas++;
            if (tempoRealHoras <= horasEstimadas && horasEstimadas > 0) {
              ossFinalizadasNoPrazo++;
            }
          }

          totalEsforco += (tempoRealHoras) / 3600;
          if (data['dataInicioEfetivo'] != null) {
            DateTime inicio = (data['dataInicioEfetivo'] as Timestamp).toDate();
            DateTime fim = data['dataFimEfetivo'] != null
                ? (data['dataFimEfetivo'] as Timestamp).toDate()
                : DateTime.now();
            totalLeadTime += fim.difference(inicio).inHours.toDouble();
          }
          totalEstimado += (horasEstimadas).toDouble();
          if (status == "Finalizado") concluidas++;
        }

        double percentualPontualidade = totalConcluidas > 0
            ? (ossFinalizadasNoPrazo / totalConcluidas) * 100
            : 0;

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildMetricCard(
                  "Eficiência H/H",
                  totalEstimado > 0
                      ? "${((totalEsforco / totalEstimado) * 100).toStringAsFixed(1)}%"
                      : "0%",
                  Colors.green),
              _buildMetricCard(
                  "Índice de Fluxo (Lead Time)",
                  totalEsforco > 0
                      ? "${(totalLeadTime / totalEsforco).toStringAsFixed(1)}x"
                      : "0x",
                  Colors.blueAccent),
              _buildMetricCard(
                "Carga Atual",
                "$ossAtivas OSs",
                ossAtivas > 3 ? Colors.orangeAccent : Colors.greenAccent,
              ),
              _buildMetricCard(
                "Pontualidade",
                "${percentualPontualidade.toStringAsFixed(0)}%",
                percentualPontualidade >= 80
                    ? Colors.greenAccent
                    : Colors.redAccent,
              ),
              const SizedBox(height: defaultPadding),
              // Aqui você pode inserir um gráfico de barras simples depois
              Text(
                  "Total de Horas Dedicadas: ${totalEsforco.toStringAsFixed(1)}h",
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54)),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}
