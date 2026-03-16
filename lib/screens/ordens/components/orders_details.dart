import 'package:admin/controllers/Auth.dart';
import 'package:admin/controllers/MenuController.dart' as admin;
import 'package:admin/controllers/OS.dart';
import 'package:admin/models/Usuario.dart';
import 'package:admin/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/models/OrdemServico.dart';
import 'package:provider/provider.dart';
import '../components/os_info_card.dart'; // Vamos criar a seguir
import '../components/os_tabs_view.dart'; // Vamos criar a seguir

class OSDetailsScreen extends StatelessWidget {
  final OrdemServico? os;
  final String? osId; // Adicionamos a opção de receber apenas o ID

  const OSDetailsScreen({Key? key, this.os, this.osId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (os == null && osId != null) {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('ordens_servico')
            .doc(osId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final osCarregada =
              OrdemServico.fromFirestore(data, snapshot.data!.id);

          return _buildDetailsLayout(context, osCarregada);
        },
      );
    }

    // Se já temos o objeto, renderiza direto
    return _buildDetailsLayout(context, os!);
  }
}

Widget _buildDetailsLayout(BuildContext context, OrdemServico osAtiva) {
  final authController = context.watch<AuthController>();
  final user = authController.usuario;

  if (user == null)
    return const Scaffold(body: Center(child: CircularProgressIndicator()));

  return Scaffold(
    appBar: AppBar(
      backgroundColor: bgColor,
      title: Text("OS #${osAtiva.codigoSequencial ?? "000"}"),
      actions: [
        if (osAtiva.status != "Finalizado")
          _buildTimerButton(context, osAtiva.id!, user, osAtiva),
        const SizedBox(width: defaultPadding),
        if (osAtiva.status != "Finalizado" && osAtiva.status != "Pendente")
          _buildFinalizarButton(context, osAtiva.id!, user),
      ],
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: OSInfoCard(os: osAtiva)),
                  const SizedBox(width: defaultPadding),
                  Expanded(flex: 2, child: OSTabsView(os: osAtiva)),
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    OSInfoCard(os: osAtiva),
                    const SizedBox(height: defaultPadding),
                    SizedBox(height: 500, child: OSTabsView(os: osAtiva)),
                  ],
                ),
              );
            }
          },
        ),
      ),
    ),
  );
}

Widget _buildTimerButton(
    BuildContext context, String osId, Usuario user, OrdemServico os) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('ordens_servico')
        .doc(osId)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const CircularProgressIndicator();

      var osData = snapshot.data!.data() as Map<String, dynamic>;
      bool isRunning = osData['status'] == "Em Execução";

      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isRunning ? Colors.redAccent : Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: () async {
          final osController = context.read<OScontroller>();
          bool permitido = await osController.podeIniciarOS(os);

          if (!permitido) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text("Esta OS depende de outra tarefa não finalizada."),
              ),
            );
            return;
          }

          final service = FirestoreService();
          if (isRunning) {
            await service.pausarTarefa(osId, user.nome);
          } else {
            await service.iniciarTarefa(osId, user.nome);
          }
        },
        icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
        label: Text(isRunning ? "PAUSAR" : "INICIAR"),
      );
    },
  );
}

Widget _buildFinalizarButton(BuildContext context, String osId, Usuario user) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('ordens_servico')
        .doc(osId)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox();

      var data = snapshot.data!.data() as Map<String, dynamic>;
      String status = data['status'] ?? "";

      // Se já estiver finalizado, não mostramos o botão
      if (status == "Finalizado") return const SizedBox();

      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey, // Cor sóbria para fechamento
          foregroundColor: Colors.white,
        ),
        onPressed: () async {
          // Confirmar antes de fechar (Boa prática de UX)
          bool? confirmar = await _showConfirmDialog(context);
          if (confirmar == true) {
            await FirestoreService().finalizarTarefa(osId, user.nome);
            Navigator.pop(context); // Fecha o painel lateral após finalizar
          }
        },
        icon: const Icon(Icons.check_circle_outline),
        label: const Text("CONCLUIR OS"),
      );
    },
  );
}

// Função auxiliar para evitar cliques acidentais
Future<bool?> _showConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Concluir Atividade?"),
      content: const Text(
          "Isso encerrará o registro de tempo e marcará a tarefa como concluída."),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCELAR")),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("SIM, CONCLUIR")),
      ],
    ),
  );
}
