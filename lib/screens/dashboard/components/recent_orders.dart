import 'package:admin/constants.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/OrdemServico.dart';

class RecentOrders extends StatelessWidget {
  final Stream<List<OrdemServico>> osStream;

  const RecentOrders({
    Key? key,
    required this.osStream, // Tornamos obrigatório
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ordens de Serviço",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 400, minHeight: 200),
            child: StreamBuilder<List<OrdemServico>>(
              stream: osStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  print("⚠️ Stream ativo, mas dados são nulos.");
                  return const Center(child: Text("Sem dados disponíveis"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: defaultPadding * 2),
                      child: Column(
                        children: [
                          Icon(Icons.fact_check_outlined,
                              size: 50, color: Colors.white24),
                          SizedBox(height: 10),
                          Text(
                            "Tudo em ordem!",
                            style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Não há ordens pendentes para o seu perfil no momento.",
                            style:
                                TextStyle(color: Colors.white24, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                List<OrdemServico> ordens = snapshot.data!;

                return DataTable2(
                  columnSpacing: defaultPadding,
                  minWidth: 600,
                  columns: [
                    DataColumn(label: Text("Tarefa")),
                    DataColumn(label: Text("Subsistema")),
                    DataColumn(label: Text("Responsável")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Horário")),
                  ],
                  rows: List.generate(
                    ordens.length,
                    (index) => ordensServicoDataRow(ordens[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

DataRow ordensServicoDataRow(OrdemServico osInfo) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Icon(
              Icons.engineering_outlined,
              size: 20,
              color: _getStatusColor(osInfo.status!),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                osInfo.titulo!,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis, // Adiciona "..." se for muito grande
              ),
            ),
          ],
        ),
      ),
      DataCell(Text(osInfo.subsistema!)),
      DataCell(
        Text(
          (osInfo.responsavel == null || osInfo.responsavel!.isEmpty)
              ? "Sem responsável"
              : (osInfo.responsavel!.length > 1
                  ? "${osInfo.responsavel![0]} + ${osInfo.responsavel!.length - 1}"
                  : osInfo.responsavel![0]),
        ),
      ),
      DataCell(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(osInfo.status!).withValues(alpha: 0.1),
            border: Border.all(color: _getStatusColor(osInfo.status!)),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            osInfo.status!,
            style: TextStyle(
              color: _getStatusColor(osInfo.status!),
              fontSize: 12,
            ),
          ),
        ),
      ),
      // Formata a data para exibir apenas Hora:Minuto
      DataCell(Text(
          "${osInfo.dataInicio!.hour.toString().padLeft(2, '0')}:${osInfo.dataInicio!.minute.toString().padLeft(2, '0')}")),
    ],
  );
}

// Lógica de cores para o Status (BI Visual)
Color _getStatusColor(String status) {
  switch (status) {
    case "Em Execução":
      return Colors.blue;
    case "Finalizado":
      return Colors.green;
    case "Pendente":
      return Colors.orangeAccent;
    default:
      return Colors.white54;
  }
}
