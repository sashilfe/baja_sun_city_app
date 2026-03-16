// lib/screens/ordens_servico/components/os_info_card.dart

import 'package:admin/constants.dart';
import 'package:admin/models/OrdemServico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin/services/firestore_service.dart';

class OSInfoCard extends StatelessWidget {
  final OrdemServico os;
  const OSInfoCard({Key? key, required this.os}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    StreamBuilder<Duration>(
      stream: firestoreService.getTempoTotalOS(os.id!),
      builder: (context, snapshot) {
        final duracao = snapshot.data ?? Duration.zero;
        return _buildInfoRow(
          "H/H Real Acumulado",
          formatDuration(duracao),
        );
      },
    );
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(os.id!),
          Divider(color: Colors.white10, height: 30),
          _buildInfoRow("Título", os.titulo ?? ""),
          _buildInfoRow("Subsistema", os.subsistema ?? ""),
          _buildInfoRow("Responsável", os.responsavel?.join(", ") ?? ""),
          _buildInfoRow("Status", os.status ?? ""),
          SizedBox(height: defaultPadding),
          Text("Descrição Técnica",
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          SizedBox(height: 8),
          Text(
            os.descricao ?? "Sem descrição detalhada.",
            style: TextStyle(height: 1.5),
            maxLines: 10,
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    return "${hours}h ${minutes}m";
  }

  Widget _buildProgressComparison(Duration real, int estimadaHoras) {
    double progresso = real.inHours / estimadaHoras;
    bool acimaDoEsperado = progresso > 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Progresso vs Estimativa",
                style: TextStyle(fontSize: 12, color: Colors.white54)),
            Text("${(progresso * 100).toStringAsFixed(1)}%",
                style: TextStyle(
                    color: acimaDoEsperado ? Colors.red : Colors.green,
                    fontSize: 12)),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progresso > 1.0 ? 1.0 : progresso,
          backgroundColor: Colors.white10,
          color: acimaDoEsperado ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _buildHeader(String osId) {
    return StreamBuilder<DocumentSnapshot>(
      // Escuta o documento da OS específica no Firestore
      stream: FirebaseFirestore.instance
          .collection('ordens_servico')
          .doc(osId)
          .snapshots(),
      builder: (context, snapshot) {
        // Enquanto carrega ou se houver erro, exibe um estado neutro
        if (!snapshot.hasData) {
          return const Text("Carregando status...");
        }

        // Extrai os dados atuais do banco
        var data = snapshot.data!.data() as Map<String, dynamic>;
        String statusAtual = data['status'] ?? "Pendente";

        // Lógica de cores dinâmica para o MENTES (Opcional, mas profissional)
        Color statusColor = statusAtual == "Em Execução"
            ? Colors.green
            : (statusAtual == "Atrasado" ? Colors.red : Colors.orangeAccent);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Detalhes da Atividade",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    color: statusColor.withOpacity(0.3)), // Borda sutil
              ),
              child: Text(
                statusAtual.toUpperCase(),
                style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
