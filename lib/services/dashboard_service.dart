import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final firestore = FirebaseFirestore.instance;

  Future<Map<String, int>> getKPIs() async {
    var snapshot = await firestore.collection("ordens_servico").get();

    int abertas = 0;
    int andamento = 0;
    int concluidas = 0;
    int atrasadas = 0;

    DateTime now = DateTime.now();

    for (var doc in snapshot.docs) {
      var data = doc.data();

      var status = data["status"];
      var prazo = data["prazo"]?.toDate();

      if (status == "aberta") abertas++;
      if (status == "em_andamento") andamento++;
      if (status == "concluida") concluidas++;

      if (prazo != null && prazo.isBefore(now) && status != "concluida") {
        atrasadas++;
      }
    }

    return {
      "abertas": abertas,
      "andamento": andamento,
      "concluidas": concluidas,
      "atrasadas": atrasadas
    };
  }
}
