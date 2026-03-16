import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String formatDateTime(dynamic data) {
  if (data == null) return "--/--";

  DateTime dt;

  // O Firebase retorna Timestamp, mas as variáveis locais podem ser DateTime
  if (data is Timestamp) {
    dt = data.toDate();
  } else if (data is DateTime) {
    dt = data;
  } else {
    return "--/--";
  }

  // Formato: 09/03/26 15:08 (Ideal para tabelas e histórico)
  return DateFormat('dd/MM/yy HH:mm').format(dt);
}
