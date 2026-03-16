import 'package:admin/screens/ordens/components/orders_details.dart';
import 'package:admin/services/firestore_service.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/OrdemServico.dart';

class OSTableFull extends StatelessWidget {
  final Stream<List<OrdemServico>> osStream;
  const OSTableFull({Key? key, required this.osStream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500, // Altura fixa ou Expanded se dentro de Column flexível
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: StreamBuilder<List<OrdemServico>>(
        stream: osStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: defaultPadding * 2),
                child: Column(
                  children: [
                    Icon(Icons.fact_check_outlined,
                        size: 50, color: Colors.white24),
                    SizedBox(height: 10),
                    Text(
                      "Tudo em ordem!",
                      style: TextStyle(
                          color: Colors.white54, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Não há ordens pendentes para o seu perfil no momento.",
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          var ordens = snapshot.data!;
          ordens.sort((a, b) =>
              (a.codigoSequencial ?? "").compareTo(b.codigoSequencial ?? ""));

          return DataTable2(
            columnSpacing: defaultPadding,
            showCheckboxColumn: false,
            minWidth: 900,
            columns: [
              DataColumn2(label: Text("ID"), size: ColumnSize.S),
              DataColumn(label: Text("Titulo")),
              DataColumn(label: Text("Subsistema")),
              DataColumn(label: Text("Responsável")),
              DataColumn(label: Text("Status")),
              DataColumn(label: Text("Estimativa (h)")),
              DataColumn(label: Text("Dependências")),
            ],
            rows: List.generate(
              ordens.length,
              (index) => _buildRow(ordens[index], context),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildRow(OrdemServico os, BuildContext context) {
    return DataRow(
        onSelectChanged: (selected) {
          if (selected != null && selected) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OSDetailsScreen(os: os),
              ),
            );
          }
        },
        cells: [
          DataCell(Text(os.codigoSequencial ?? "----")),
          DataCell(Text(os.titulo!)),
          DataCell(Text(os.subsistema!)),
          DataCell(
            Text(
              os.responsavel == null || os.responsavel!.isEmpty
                  ? "Sem responsável"
                  : os.responsavel!.join(", "),
            ),
          ),
          DataCell(_buildStatusBadge(
              os.status ?? "Pendente")), // Badge colorido que criamos
          DataCell(Text("${os.horasEstimadas ?? 0}h")),
          DataCell(_buildDependenciaCell(os)),
        ]);
  }
}

Widget _buildDependenciaCell(OrdemServico os) {
  if (os.dependentes == null || os.dependentes!.isEmpty) {
    return const Text("-");
  }

  return FutureBuilder<List<OrdemServico>>(
    future: FirestoreService().getDependencias(os.dependentes),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      }

      final deps = snapshot.data!;

      bool bloqueada = false;

      for (var dep in deps) {
        final tipo = os.dependentes!.firstWhere((d) => d.osId == dep.id).tipo;

        if (tipo == "FS" && dep.status != "Finalizado") {
          bloqueada = true;
        }

        if (tipo == "SS" && dep.status == "Pendente") {
          bloqueada = true;
        }
      }

      if (bloqueada) {
        return Row(
          children: const [
            Icon(Icons.lock, color: Colors.red, size: 16),
            SizedBox(width: 4),
            Text("Bloqueada"),
          ],
        );
      }

      return Row(
        children: const [
          Icon(Icons.link, color: Colors.orangeAccent, size: 16),
          SizedBox(width: 4),
          Text("Dependente"),
        ],
      );
    },
  );
}

Widget _buildStatusBadge(String status) {
  Color mainColor;

  // Lógica de cores baseada no status da manufatura/projeto
  switch (status) {
    case "Em Execução":
      mainColor = Colors.blue;
      break;
    case "Finalizado":
      mainColor = Colors.green;
      break;
    case "Pendente":
      mainColor = Colors.orangeAccent;
      break;
    case "Cancelado":
      mainColor = Colors.redAccent;
      break;
    case "Pausado":
      mainColor = Colors.grey;
      break;
    default:
      mainColor = Colors.white54;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      // Fundo levemente opaco com a cor do status
      color: mainColor.withOpacity(0.1),
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      border: Border.all(color: mainColor.withOpacity(0.5)),
    ),
    child: Text(
      status.toUpperCase(),
      style: TextStyle(
        color: mainColor,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ),
  );
}
