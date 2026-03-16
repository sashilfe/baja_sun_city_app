import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/models/Usuario.dart';
import 'package:admin/models/OrdemServico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberHistoryTab extends StatelessWidget {
  final Usuario user;

  const MemberHistoryTab({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Buscamos as OSs onde o nome do membro aparece no array de responsáveis
      stream: FirebaseFirestore.instance
          .collection('ordens_servico')
          .where('responsavel', arrayContains: user.nome)
          .orderBy('dataInicio', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("Nenhuma atividade registrada.",
                style: TextStyle(color: Colors.white24)),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final id = snapshot.data!.docs[index].id;
            // Usamos o fromFirestore que ajustamos anteriormente para Duration
            final os = OrdemServico.fromFirestore(data, id);

            return _buildHistoryCard(context, os);
          },
        );
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, OrdemServico os) {
    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding / 2),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(os.status).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(os.status),
            color: _getStatusColor(os.status),
            size: 20,
          ),
        ),
        title: Text(
          os.titulo ?? "Sem título",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          "Cód: #${os.codigoSequencial} • ${os.subsistema}",
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              os.tempoFormatado, // Aquele getter que criamos!
              style: const TextStyle(
                  color: Colors.orangeAccent, fontWeight: FontWeight.bold),
            ),
            const Text("dedicados",
                style: TextStyle(fontSize: 10, color: Colors.white38)),
          ],
        ),
        onTap: () {
          // Aqui você pode navegar para os detalhes da OS se desejar
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'finalizado':
        return Colors.green;
      case 'em execução':
        return Colors.orange;
      case 'pendente':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'finalizado':
        return Icons.check_circle_outline;
      case 'em execução':
        return Icons.play_circle_outline;
      case 'pendente':
        return Icons.history;
      default:
        return Icons.help_outline;
    }
  }
}
