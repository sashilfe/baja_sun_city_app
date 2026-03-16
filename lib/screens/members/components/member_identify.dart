import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/models/Usuario.dart';

class MemberIdentityCard extends StatelessWidget {
  final Usuario user;

  const MemberIdentityCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar ou Foto com borda laranja
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.orangeAccent,
            child: CircleAvatar(
              radius: 47,
              backgroundImage:
                  user.fotoUrl != null ? NetworkImage(user.fotoUrl!) : null,
              child: user.fotoUrl == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: defaultPadding),

          Text(
            user.nome,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            user.role.toString().split('.').last.toUpperCase(),
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: defaultPadding),
          const Divider(color: Colors.white10),
          const SizedBox(height: defaultPadding),

          _buildInfoRow(Icons.engineering_outlined, "Subsistema",
              user.subsistema.join(", ")),
          _buildInfoRow(Icons.info_outline, "Cargo",
              user.role.toString().split('.').last.toUpperCase()),
          _buildInfoRow(Icons.calendar_month_outlined, "Na equipe desde",
              "Data não registrada"),
          _buildInfoRow(Icons.badge_outlined, "ID Membro",
              user.uid.substring(0, 8).toUpperCase()),

          const SizedBox(height: defaultPadding),

          // Badge de Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: const Text(
              "ATIVO",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Data não registrada";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
