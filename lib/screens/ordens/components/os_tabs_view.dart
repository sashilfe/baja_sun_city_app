import 'package:admin/constants.dart';
import 'package:admin/controllers/Auth.dart';
import 'package:admin/models/ItemEstoque.dart';
import 'package:admin/models/OrdemServico.dart';
import 'package:admin/models/Usuario.dart';
import 'package:admin/services/firestore_service.dart';
import 'package:admin/utils/formatters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OSTabsView extends StatelessWidget {
  final OrdemServico os;

  const OSTabsView({Key? key, required this.os}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const TabBar(
              indicatorColor: Colors.orangeAccent,
              labelColor: Colors.orangeAccent,
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(text: 'Comentarios'),
                Tab(text: 'Historico'),
                Tab(text: 'Anexos'),
                Tab(text: 'Dependencias'),
                Tab(text: 'Materiais'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCommentsTab(),
                  _buildHistoryTab(),
                  _buildAttachmentsTab(),
                  _buildDependenciesTab(),
                  _buildMaterialsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsTab() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('ordens_servico')
                .doc(os.id)
                .collection('comentarios')
                .orderBy('data', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              return ListView.builder(
                reverse: true,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return _CommentTile(
                    user: data['usuarioNome'] ?? 'Membro',
                    text: data['texto'] ?? '',
                    time: formatDateTime(data['data']),
                    userImageUrl: data['fotoUrl'],
                  );
                },
              );
            },
          ),
        ),
        OSChatInput(osId: os.id!),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ordens_servico')
          .doc(os.id)
          .collection('historico')
          .orderBy('data', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: defaultPadding),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _HistoryItem(
              action: data['acao'] ?? '',
              user: data['usuario'] ?? '',
              time: formatDateTime(data['data']),
            );
          },
        );
      },
    );
  }

  Widget _buildAttachmentsTab() {
    return GridView.builder(
      padding: const EdgeInsets.only(top: defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: 1,
      itemBuilder: (context, index) => const _AttachmentCard(
        fileName: 'Documento.pdf',
        fileSize: '2.5 MB',
      ),
    );
  }

  Widget _buildDependenciesTab() {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildDependencySection(
              title: 'Dependencias (Pre-requisitos)',
              subtitle: 'Esta OS so pode iniciar apos a conclusao/inicio de:',
              icon: Icons.subdirectory_arrow_left_rounded,
              color: Colors.orangeAccent,
              stream: FirestoreService().getPreRequisitos(os.id!),
            ),
          ),
          const Divider(height: 32, color: Colors.white10),
          Expanded(
            child: _buildDependencySection(
              title: 'Impacto (Dependentes)',
              subtitle: 'As seguintes OSs estao aguardando esta conclusao/inicio:',
              icon: Icons.play_for_work_rounded,
              color: Colors.blueAccent,
              stream: FirestoreService().getOSsDependentes(os.id!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ordens_servico')
          .doc(os.id)
          .collection('materiais_consumidos')
          .orderBy('data', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final materiais = snapshot.data!.docs
            .map((doc) => MaterialConsumidoRelatorio.fromMap(
                doc.data() as Map<String, dynamic>))
            .toList();

        if (materiais.isEmpty) {
          return const Center(
            child: Text(
              'Nenhum material consumido nesta atividade.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        double custoTotal = 0;
        for (final material in materiais) {
          custoTotal += material.custoEstimado ?? 0;
        }

        return Padding(
          padding: const EdgeInsets.only(top: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Rastreabilidade de materiais da OS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      'Custo est.: R\$ ${custoTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: defaultPadding),
              Expanded(
                child: ListView.builder(
                  itemCount: materiais.length,
                  itemBuilder: (context, index) {
                    final material = materiais[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.precision_manufacturing_outlined,
                            color: Colors.orangeAccent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  material.itemNome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${material.quantidadeConsumida.toStringAsFixed(2)} ${material.unidade} • ${material.categoria}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${material.responsavelNome} • ${formatDateTime(material.data)}',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            material.custoEstimado == null
                                ? 'Sem custo'
                                : 'R\$ ${material.custoEstimado!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDependencySection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Stream<List<OrdemServico>> stream,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: defaultPadding),
        Expanded(
          child: StreamBuilder<List<OrdemServico>>(
            stream: stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final dependencia = snapshot.data![index];
                  return _buildDependencyTile(dependencia, color);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDependencyTile(OrdemServico item, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(
            item.codigoSequencial ?? '---',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.titulo ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          _buildStatusBadge(item.status ?? 'Pendente'),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;

    switch (status) {
      case 'Em andamento':
        color = Colors.orangeAccent;
        break;
      case 'Finalizada':
        color = Colors.green;
        break;
      case 'Pendente':
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Nenhuma dependencia registrada',
        style: TextStyle(
          color: Colors.white24,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final String fileName;
  final String? imageUrl;
  final String fileSize;
  final VoidCallback? onDelete;

  const _AttachmentCard({
    required this.fileName,
    this.imageUrl,
    required this.fileSize,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : const Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                    )
                  : Container(
                      color: Colors.white10,
                      child: const Center(
                        child: Icon(
                          Icons.insert_drive_file,
                          color: Colors.white24,
                          size: 40,
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fileSize,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white38),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.download_rounded,
                            size: 16,
                            color: Colors.orangeAccent,
                          ),
                          if (onDelete != null) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Colors.redAccent,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String user;
  final String text;
  final String time;
  final String? userImageUrl;

  const _CommentTile({
    required this.user,
    required this.text,
    required this.time,
    this.userImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.orangeAccent.withValues(alpha: 0.1),
            child: userImageUrl != null
                ? ClipOval(child: Image.network(userImageUrl!))
                : const Icon(Icons.person, size: 18, color: Colors.orangeAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        user,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      Text(
                        time,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String action;
  final String user;
  final String time;

  const _HistoryItem({
    required this.action,
    required this.user,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          const Icon(Icons.history, size: 16, color: Colors.orangeAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$user • $time',
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OSChatInput extends StatefulWidget {
  final String osId;

  const OSChatInput({Key? key, required this.osId}) : super(key: key);

  @override
  State<OSChatInput> createState() => _OSChatInputState();
}

class _OSChatInputState extends State<OSChatInput> {
  final TextEditingController _controller = TextEditingController();

  void _enviar(Usuario user) {
    if (_controller.text.isNotEmpty) {
      FirestoreService().enviarComentario(widget.osId, _controller.text, user);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().usuario!;
    Map<String, dynamic>? data;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ordens_servico')
          .doc(widget.osId)
          .snapshots(),
      builder: (context, snapshot) {
        bool isFinalizado = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          data = snapshot.data!.data() as Map<String, dynamic>;
          isFinalizado =
              data!['status'] == 'Finalizado' || data!['status'] == 'Pendente';
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextField(
            enabled: !isFinalizado,
            controller: _controller,
            onSubmitted: (_) => isFinalizado ? null : _enviar(user),
            style:
                TextStyle(color: isFinalizado ? Colors.white24 : Colors.white),
            decoration: InputDecoration(
              hintText: isFinalizado
                  ? 'OS ${data?['status'] ?? ''} - Chat desativado'
                  : 'Duvida tecnica ou atualizacao...',
              hintStyle: TextStyle(
                color: isFinalizado
                    ? Colors.redAccent.withValues(alpha: 0.5)
                    : Colors.white24,
                fontSize: 13,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.send,
                  color: isFinalizado ? Colors.grey : Colors.orangeAccent,
                ),
                onPressed: isFinalizado ? null : () => _enviar(user),
              ),
              filled: true,
              fillColor: isFinalizado ? Colors.black26 : bgColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      },
    );
  }
}
