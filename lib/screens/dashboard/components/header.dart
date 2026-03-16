import 'package:admin/controllers/Auth.dart';
import 'package:admin/controllers/MenuController.dart' as admin;
import 'package:admin/models/Usuario.dart';
import 'package:admin/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<admin.MenuController>();
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context.read<admin.MenuController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            menuController.currentScreenTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        NotificationIcon(),
        SizedBox(width: defaultPadding / 2),
        ProfileCard()
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    // Se não tiver ID, não temos o que escutar
    if (auth.usuario?.uid == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      // Criamos um stream direto para o documento deste usuário específico
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(auth.usuario!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Se ainda está carregando o stream, mantém o dado antigo do Auth ou um loading
        if (!snapshot.hasData) return _buildLoadingProfile();

        // Converte os dados em tempo real para a sua Model
        final usuarioData = snapshot.data!.data() as Map<String, dynamic>;
        final usuarioVivo = Usuario.fromMap(usuarioData, snapshot.data!.id);

        return PopupMenuButton<String>(
          offset: const Offset(0, 55),
          color: secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.white10),
          ),
          onSelected: (value) async {
            if (value == 'sair') {
              await context.read<AuthController>().logout();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sair',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  SizedBox(width: 10),
                  Text("Sair", style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: defaultPadding * 0.3,
              horizontal: defaultPadding * 0.4,
            ),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: usuarioVivo.fotoUrl != null &&
                          usuarioVivo.fotoUrl!.isNotEmpty
                      ? Image.network(
                          usuarioVivo.fotoUrl!,
                          height: 38,
                          width: 38,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
                if (!Responsive.isMobile(context))
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding / 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuarioVivo.nome,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          usuarioVivo.role
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                const Icon(Icons.keyboard_arrow_down,
                    size: 20, color: Colors.white54),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingProfile() {
    return Container(width: 100, height: 40, color: Colors.transparent);
  }

  Widget _buildDefaultAvatar() {
    return Container(
      height: 38,
      width: 38,
      color: Colors.orangeAccent.withValues(alpha: 0.1),
      child: const Icon(Icons.person, color: Colors.orangeAccent),
    );
  }
}

void _showNotificationMenu(
    BuildContext context, List<QueryDocumentSnapshot>? docs) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey[900],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      print("Notificações: ${docs?.length ?? 0}");
      return Container(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Notificações",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (docs != null && docs.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Lógica de "Marcar todas como lidas"
                      for (var doc in docs) {
                        doc.reference.update({'lida': true});
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("Marcar todas como lidas",
                        style: TextStyle(color: Colors.orangeAccent)),
                  ),
              ],
            ),
            const Divider(color: Colors.white10),
            if (docs == null || docs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: defaultPadding * 2),
                child: Text("Sem novas notificações de OS",
                    style: TextStyle(color: Colors.white54)),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String? osId = data['osId'];
                    return InkWell(
                      onTap: () async {
                        Navigator.pop(context);

                        await FirebaseFirestore.instance
                            .collection('notificacoes')
                            .doc(docs[index].id)
                            .update({'lida': true});

                        if (osId != null) {
                          final menuController =
                              Provider.of<admin.MenuController>(context,
                                  listen: false);

                          menuController.setSelectedOsId(osId);
                        }
                      },
                      child: NotificationTile(
                        title: data['titulo'] ?? "Nova OS",
                        subtitle: data['mensagem'] ?? "",
                        time: data['timestamp'] != null
                            ? _formatTimestamp(data['timestamp'])
                            : "Agora",
                        isAlert: data['prioridade'] == "alta",
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

String _formatTimestamp(dynamic timestamp) {
  if (timestamp == null) return "Agora";
  DateTime date = (timestamp as Timestamp).toDate();
  return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
}

class NotificationTile extends StatelessWidget {
  final String title, subtitle, time;
  final bool isAlert;

  const NotificationTile({
    required this.title,
    required this.subtitle,
    required this.time,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isAlert
                ? Colors.red.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            child: Icon(
              isAlert
                  ? Icons.warning_amber_rounded
                  : Icons.assignment_ind_outlined,
              color: isAlert ? Colors.red : Colors.orangeAccent,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                Text(time,
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notificacoes')
          .where('uid_destinatario', isEqualTo: auth.usuario?.uid)
          .where('lida', isEqualTo: false)
          // .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        int total = snapshot.data?.docs.length ?? 0;

        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications_none, color: Colors.white54),
              onPressed: () =>
                  _showNotificationMenu(context, snapshot.data?.docs),
            ),
            if (total > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration:
                      BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    "$total",
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset("assets/icons/Search.svg"),
          ),
        ),
      ),
    );
  }
}
