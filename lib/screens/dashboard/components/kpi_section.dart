import 'package:admin/screens/dashboard/components/file_info_card.dart';
import 'package:flutter/material.dart';
import 'package:admin/services/kpi_service.dart';
import 'package:admin/responsive.dart';
import 'package:admin/constants.dart';

class OSKpiSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: KPIService().getOSMetrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Erro ao carregar indicadores"));
        }

        final data = snapshot.data!;
        if (data == null) return const SizedBox();

        return Responsive(
          mobile: _buildGrid(context, data, crossAxisCount: 2, ratio: 1.3),
          tablet: _buildGrid(context, data, crossAxisCount: 4, ratio: 1),
          desktop: _buildGrid(context, data, crossAxisCount: 5, ratio: 1.4),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, Map<String, dynamic> data,
      {required int crossAxisCount, required double ratio}) {
    int total = data['total'] ?? 0;
    int pendentes = data['pendentes'] ?? 0;
    int emExecucao = data['emExecucao'] ?? 0;
    int concluidas = data['finalizado'] ?? 0;
    double eficiencia = (data['eficiencia'] ?? 0.0).toDouble();

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: ratio,
      ),
      children: [
        FileInfoCard(
          title: "Pendentes",
          amount: pendentes.toString() + " OSs",
          svgSrc: "assets/icons/Documents.svg",
          color: primaryColor,
          percentage: total > 0 ? ((pendentes / total) * 100).toInt() : 0,
        ),
        FileInfoCard(
          title: "Em Execução",
          amount: emExecucao.toString() + " OSs",
          svgSrc: "assets/icons/google_drive.svg",
          color: const Color(0xFFFFA113),
          percentage: total > 0 ? ((emExecucao / total) * 100).toInt() : 0,
        ),
        FileInfoCard(
          title: "Finalizadas",
          amount: concluidas.toString() + " OSs",
          svgSrc: "assets/icons/one_drive.svg",
          color: const Color(0xFF00B127),
          percentage: total > 0 ? ((concluidas / total) * 100).toInt() : 0,
        ),
        FileInfoCard(
          title: "Eficiência H/H",
          amount: "${eficiencia.toStringAsFixed(2)}%",
          svgSrc: "assets/icons/drop_box.svg",
          color: Colors.blueAccent,
          percentage: eficiencia.toInt().clamp(0, 100),
        ),
        FileInfoCard(
          title: "Lead Time",
          amount: "${data['leadTime']?.toStringAsFixed(1) ?? '0'}h",
          svgSrc: "assets/icons/drop_box.svg",
          color: Colors.orangeAccent,
          percentage: 0,
        ),
      ],
    );
  }
}
