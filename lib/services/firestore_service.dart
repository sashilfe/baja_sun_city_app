import 'dart:io';

import 'package:admin/models/OSSummary.dart';
import 'package:admin/models/Usuario.dart';
import 'package:admin/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/OrdemServico.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> abrirNovaOS(OrdemServico novaOS, String criadoPorNome) async {
    final counterRef = _db.collection('settings').doc('os_counters');
    final osCollection = _db.collection('ordens_servico');

    try {
      await _db.runTransaction((transaction) async {
        DocumentSnapshot counterSnap = await transaction.get(counterRef);

        // 1. Preparamos os dados do contador com segurança
        Map<String, dynamic> data = {};
        if (counterSnap.exists) {
          data = counterSnap.data() as Map<String, dynamic>;
        }

        // 2. Pegamos a contagem atual. Se for null (subsistema novo), vira 0.
        int contagemAtual = data[novaOS.subsistema] ?? 0;
        int novoNumero = contagemAtual + 1;

        // 3. Geramos o ID Visual (Ex: FASD-001)
        String sufixo = novoNumero.toString().padLeft(3, '0');
        String idVisual = "${novaOS.subsistema}-$sufixo";

        // 4. ATUALIZAÇÃO SEGURA: Usamos 'set' com 'merge' para evitar erro de campo inexistente
        transaction.set(
            counterRef,
            {
              novaOS.subsistema!:
                  novoNumero // O '!' aqui é seguro pois validamos no Form
            },
            SetOptions(merge: true));

        // 5. Criamos a OS Principal
        DocumentReference novaOsRef = osCollection.doc();

        transaction.set(novaOsRef, {
          'id': novaOsRef.id,
          'codigoSequencial': idVisual,
          'titulo': novaOS.titulo ?? "Nova Atividade",
          'subsistema': novaOS.subsistema,
          'responsavel': novaOS.responsavel,
          'descricao': novaOS.descricao,
          'horasEstimadas': novaOS.horasEstimadas,
          'criadoPor': criadoPorNome,
          'status': 'Pendente',
          'prioridade': novaOS.prioridade ?? 'Media',
          'dataInicio': FieldValue.serverTimestamp(),
          'dependentes': novaOS.dependentes
              ?.map((d) => {'osId': d.osId, 'tipo': d.tipo})
              .toList(),
          'tempoGasto': 0,
          'tempoTotalReal': 0,
          'ativo': false,
        });
        criarOSENotificar(novaOS, idVisual, novaOsRef);

        // 6. Registro de Histórico (Audit Trail)
        transaction.set(novaOsRef.collection('historico').doc(), {
          'acao': "Ordem de Serviço $idVisual Gerada",
          'usuario': criadoPorNome,
          'data': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      // Se o erro persistir, o print abaixo no console do navegador dirá se é PERMISSÃO
      print("ERRO REAL NA TRANSAÇÃO: $e");
      rethrow;
    }
  }

  Future<void> criarOSENotificar(
      OrdemServico os, String visualId, DocumentReference? docRef) async {
    //
    List<String> responsaveis =
        os.responsavel is List ? List<String>.from(os.responsavel!) : [];
    for (String nomeResponsavel in responsaveis) {
      final userQuery = await _db
          .collection('usuarios')
          .where('nome', isEqualTo: nomeResponsavel)
          .get();

      if (userQuery.docs.isNotEmpty) {
        var userData = userQuery.docs.first.data();
        String uidDestinatario = userQuery.docs.first.id;
        String? token = userData['fcmToken'];

        // 1. SALVAR NO BANCO (Para o Badge do Sininho no Dashboard)
        await _db.collection('notificacoes').add({
          'uid_destinatario': uidDestinatario,
          'titulo': "Nova OS: $visualId",
          'mensagem': "Você foi escalado para: ${os.titulo}",
          'lida': false,
          'timestamp': FieldValue.serverTimestamp(),
          'osId': docRef != null ? docRef.id : os.id,
        });

        // 2. ENVIAR PUSH (Para o celular/navegador avisar fora do app)
        if (token != null) {
          await NotificationService().enviarPushV1(
              token,
              "Nova OS para você! 🏎️",
              "Você foi atribuído à OS #$visualId: ${os.titulo}");
        }
      }
    }
  }

  Future<void> atualizarTokenFCM(String userId) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 1. Solicita permissão (obrigatório para iOS e Android 13+)
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Pega o token único deste dispositivo
        String? token = await messaging.getToken(
            vapidKey:
                "BLpJK6nHWh6dcwjpcF76B9OHCAFTWOjmnE9gq6T0baQMhSpCCrMEzR_GsBMc4T4HUn7gdN8mzwgV_Vt_G1klNjE");

        if (token != null) {
          // 3. Salva no Firestore dentro do documento do usuário
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(userId)
              .update({
            'fcmToken': token,
            'ultimaSincronizacaoToken': FieldValue.serverTimestamp(),
          });
          print("Token FCM atualizado com sucesso!");
        }
      }
    } catch (e) {
      print("Erro ao atualizar token FCM: $e");
    }
  }

  Stream<List<Usuario>> getMembrosPorSubsistema(String subsistema) {
    if (subsistema.isEmpty) {
      return Stream.value([]);
    }

    return _db
        .collection('usuarios')
        .where('subsistema', whereIn: [subsistema])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Usuario.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<List<Usuario>> getUsuariosPorSubsistema(Usuario usuarioLogado) {
    var query = _db.collection('usuarios');

    if (usuarioLogado.role != UserRole.admin) {
      return query
          .where('subsistema', whereIn: usuarioLogado.subsistema)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Usuario.fromMap(doc.data(), doc.id))
            .toList();
      });
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Usuario.fromMap(doc.data(), doc.id))
          .where((usuario) =>
              usuario.role != UserRole.admin &&
              usuario.role != UserRole.orientador)
          .toList();
    });
  }

  Stream<List<Usuario>> getTodosUsuarios() {
    return _db.collection('usuarios').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return Usuario.fromMap(doc.data(), doc.id);
            } catch (e) {
              print("Erro ao converter usuário ${doc.id}: $e");
              rethrow;
            }
          })
          .where((usuario) => usuario.role != UserRole.admin)
          .toList();
    });
  }

  Stream<OSSummary> getOSSummaryStream() {
    return FirebaseFirestore.instance
        .collection('ordens_servico')
        .snapshots()
        .map((snapshot) {
      int abertas = 0;
      int pendentes = 0;
      int fechadas = 0;

      for (var doc in snapshot.docs) {
        String status = doc.data()['status']?.toString().toLowerCase() ?? "";

        if (status == "em andamento" || status == "execução") {
          abertas++;
        } else if (status == "pendente" || status == "atrasada") {
          pendentes++;
        } else if (status == "concluída" || status == "finalizada") {
          fechadas++;
        }
      }

      return OSSummary(
        abertas: abertas,
        pendentes: pendentes,
        fechadas: fechadas,
      );
    });
  }

  Future<void> adicionarComentario(
      String osId, String mensagem, String usuarioId) async {
    await _db
        .collection("ordens_servico")
        .doc(osId)
        .collection("comentarios")
        .add({
      "usuario_id": usuarioId,
      "mensagem": mensagem,
      "created_at": Timestamp.now()
    });
  }

  Future<void> registrarHistorico(String osId, String acao, String antigo,
      String novo, String usuario) async {
    await _db
        .collection("ordens_servico")
        .doc(osId)
        .collection("historico")
        .add({
      "acao": acao,
      "valor_anterior": antigo,
      "valor_novo": novo,
      "usuario_id": usuario,
      "timestamp": Timestamp.now()
    });
  }

  Future<String> uploadArquivo(File file) async {
    var ref = FirebaseStorage.instance.ref().child("anexos/${DateTime.now()}");

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  // Métodos para atualizar o status da OS

  Future<void> iniciarTarefa(String osId, String usuarioNome) async {
    final batch = _db.batch();
    final osRef = _db.collection('ordens_servico').doc(osId);
    final doc = await osRef.get();

    // 1. Atualiza Status para "Em Execução"
    batch.update(osRef, {'status': 'Em Execução'});
    if (doc.data()?['dataInicioEfetivo'] == null) {
      batch.update(osRef, {'dataInicioEfetivo': FieldValue.serverTimestamp()});
    }

    // 2. Adiciona Log de Início na subcoleção de registros de tempo
    final logRef = osRef.collection('time_logs').doc();
    batch.set(logRef, {
      'inicio': FieldValue.serverTimestamp(),
      'usuario': usuarioNome,
      'ativo': true,
    });

    // 3. Registra no Histórico da OS para a aba de auditoria
    final historicoRef = osRef.collection('historico').doc();
    batch.set(historicoRef, {
      'acao': "Iniciou a execução da tarefa",
      'usuario': usuarioNome,
      'data': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> pausarTarefa(String osId, String usuarioNome) async {
    final query = await _db
        .collection('ordens_servico')
        .doc(osId)
        .collection('time_logs')
        .where('usuario', isEqualTo: usuarioNome)
        .where('ativo', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final logDoc = query.docs.first;
      final logRef = logDoc.reference;
      final DateTime agora = DateTime.now();

      // Recupera o início e calcula a diferença antes de atualizar
      final Timestamp inicioTS = logDoc.data()['inicio'];
      final DateTime inicio = inicioTS.toDate();
      final int segundosGastos = agora.difference(inicio).inSeconds;

      final osRef = _db.collection('ordens_servico').doc(osId);

      final batch = _db.batch();

      batch.update(logRef, {
        'fim': Timestamp.fromDate(agora),
        'ativo': false,
        'duracao_segundos': segundosGastos,
      });

      batch.update(osRef, {
        'status': 'Pausada',
        'tempoTotalReal':
            FieldValue.increment(segundosGastos), // Acumulado total
      });

      final historicoRef = osRef.collection('historico').doc();
      batch.set(historicoRef, {
        'acao': "Pausou a execução da tarefa",
        'usuario': usuarioNome,
        'data': FieldValue.serverTimestamp(),
        'detalhe':
            "${(segundosGastos / 60).toStringAsFixed(2)} minutos registrados",
      });

      await batch.commit();
    }
  }

  Future<void> finalizarTarefa(String osId, String usuarioNome) async {
    try {
      await pausarTarefa(osId, usuarioNome);

      final osRef = _db.collection('ordens_servico').doc(osId);
      final batch = _db.batch();
      final doc = await osRef.get();
      final data = doc.data()!;
      final fim = DateTime.now();
      int segundosTotais = 0;

      if (data['dataInicioEfetivo'] != null) {
        final DateTime inicio =
            (data['dataInicioEfetivo'] as Timestamp).toDate();
        segundosTotais = fim.difference(inicio).inSeconds;
      }
      batch.update(osRef, {
        'status': 'Finalizado',
        'dataFim': FieldValue.serverTimestamp(),
        'ativo': false, // Membro não está mais "ocupado" com esta OS
        'ultimo_play': FieldValue.serverTimestamp(),
        'dataFimEfetivo': Timestamp.fromDate(fim),
        'tempo_gasto': segundosTotais,
      });

      final historicoRef = osRef.collection('historico').doc();
      batch.set(historicoRef, {
        'acao': "Finalizou a execução da tarefa",
        'usuario': usuarioNome,
        'data': FieldValue.serverTimestamp(),
        'detalhe': "OS encerrada com sucesso e todos os tempos contabilizados.",
      });

      await batch.commit();
    } catch (e) {
      print("Erro ao finalizar tarefa: $e");
      rethrow;
    }
  }

  // Métodos para Comentarios e Histórico de Auditoria

  Future<void> enviarComentario(String osId, String texto, Usuario user) async {
    if (texto.trim().isEmpty) return;

    await _db
        .collection('ordens_servico')
        .doc(osId)
        .collection('comentarios')
        .add({
      'texto': texto,
      'usuarioNome': user.nome,
      'usuarioId': user.uid,
      'fotoUrl': user.fotoUrl,
      'data': FieldValue.serverTimestamp(),
    });
  }

  Stream<Duration> getTempoTotalOS(String osId) {
    return _db
        .collection('ordens_servico')
        .doc(osId)
        .collection('time_logs')
        .snapshots()
        .map((snapshot) {
      Duration total = Duration.zero;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['inicio'] != null && data['fim'] != null) {
          DateTime inicio = (data['inicio'] as Timestamp).toDate();
          DateTime fim = (data['fim'] as Timestamp).toDate();
          total += fim.difference(inicio);
        } else if (data['inicio'] != null && data['ativo'] == true) {
          // Se a tarefa estiver a decorrer agora, calculamos o tempo até o momento atual
          DateTime inicio = (data['inicio'] as Timestamp).toDate();
          total += DateTime.now().difference(inicio);
        }
      }
      return total;
    });
  }

  Stream<List<OrdemServico>> getDashboardRecentOS(Usuario user) {
    Query query = _db.collection('ordens_servico');

    const subsistemasOficina = ['FASD', 'CE', 'EAD', 'PEE'];
    const subsistemasAdm = ['Marketing', 'Financeiro', 'Patrocínio'];

    if (user.role == UserRole.admin ||
        user.role == UserRole.orientador ||
        user.role == UserRole.capitao) {
    } else if (user.role == UserRole.diretor) {
      if (user.diretoria == 'oficina') {
        query = query.where('subsistema', whereIn: subsistemasOficina);
      } else if (user.diretoria == 'administrativo') {
        query = query.where('subsistema', whereIn: subsistemasAdm);
      }
      ;
    } else if (user.role == UserRole.lider) {
      query = query.where('subsistema', whereIn: user.subsistema);
    } else {
      query = query.where('responsavel', arrayContains: user.nome);
    }

    return query.limit(10).snapshots().map((snap) => snap.docs
        .map((doc) => OrdemServico.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Stream<List<OrdemServico>> getDashboardOS(Usuario user) {
    Query query = _db.collection('ordens_servico');

    const subsistemasOficina = ['FASD', 'CE', 'EAD', 'PEE'];
    const subsistemasAdm = ['Marketing', 'Financeiro', 'Patrocínio'];

    if (user.role == UserRole.admin ||
        user.role == UserRole.orientador ||
        user.role == UserRole.capitao) {
    } else if (user.role == UserRole.diretor) {
      if (user.diretoria == 'oficina') {
        query = query.where('subsistema', whereIn: subsistemasOficina);
      } else if (user.diretoria == 'administrativo') {
        query = query.where('subsistema', whereIn: subsistemasAdm);
      }
      ;
    } else if (user.role == UserRole.lider) {
      query = query.where('subsistema', whereIn: user.subsistema);
    } else {
      query = query.where('responsavel', isEqualTo: user.nome);
    }

    return query.snapshots().map((snap) => snap.docs
        .map((doc) => OrdemServico.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Stream<List<OrdemServico>> getOrdensServico() {
    return _db
        .collection('ordens_servico')
        .orderBy('dataInicio', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrdemServico.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<OrdemServico?> getOS(String osId) async {
    final doc = await FirebaseFirestore.instance
        .collection("ordens_servico")
        .doc(osId)
        .get();

    if (!doc.exists) return null;

    return OrdemServico.fromFirestore(doc.data()!, doc.id);
  }

  Stream<List<OrdemServico>> getTodasOS() {
    return FirebaseFirestore.instance
        .collection("ordens_servico")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrdemServico.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<List<OrdemServico>> getDependencias(List<OSDependencia>? deps) async {
    if (deps == null || deps.isEmpty) return [];

    List<String> ids = deps.map((d) => d.osId).toList();

    final snapshot = await FirebaseFirestore.instance
        .collection("ordens_servico")
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return snapshot.docs.map((doc) {
      return OrdemServico.fromFirestore(doc.data(), doc.id);
    }).toList();
  }

  Stream<List<OrdemServico>> getPreRequisitos(String osId) {
    return FirebaseFirestore.instance
        .collection('ordens_servico')
        .doc(osId)
        .snapshots()
        .asyncMap((doc) async {
      final data = doc.data();

      if (data == null || data['dependentes'] == null) {
        return [];
      }

      List deps = data['dependentes'];

      List<String> ids = deps.map((d) => d['osId'] as String).toList();

      if (ids.isEmpty) return [];

      final query = await FirebaseFirestore.instance
          .collection('ordens_servico')
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      return query.docs
          .map((d) => OrdemServico.fromFirestore(d.data(), d.id))
          .toList();
    });
  }

  Stream<List<OrdemServico>> getOSsDependentes(String osId) {
    return FirebaseFirestore.instance
        .collection('ordens_servico')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            final idDocumento = doc.id; // Este é o UID real do Firebase

            return OrdemServico.fromFirestore(data, idDocumento);
          })
          .where(
              (os) => os.dependentes?.any((dep) => dep.osId == osId) ?? false)
          .toList();
    });
  }

  // Stream por Subsistema (Para os líderes de área)
  Stream<List<OrdemServico>> getOSPorSubsistema(String subsistema) {
    return _db
        .collection('ordens_servico')
        .where('subsistema', isEqualTo: subsistema)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => OrdemServico.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Stream Atribuído a Mim (Para o membro individual)
  Stream<List<OrdemServico>> getMinhasOS(String nomeResponsavel) {
    return _db
        .collection('ordens_servico')
        .where('responsavel', isEqualTo: nomeResponsavel)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => OrdemServico.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> criarNotificacaoNovaOS(OrdemServico os, String membroId) async {
    await _db.collection('notificacoes').add({
      'uid_destinatario': membroId,
      'titulo': "Nova OS Atribuída",
      'mensagem': "Tarefa: ${os.titulo} no subsistema ${os.subsistema}",
      'lida': false,
      'data': FieldValue.serverTimestamp(),
    });
  }

  Future<void> checkAndSeedDatabase(List<OrdemServico> demoData) async {
    // Referência para a coleção
    final collectionRef = _db.collection('ordens_servico');

    // Tenta buscar pelo menos 1 documento
    final snapshot = await collectionRef.limit(1).get();

    // Se não houver documentos, sobe os dados fictícios
    if (snapshot.docs.isEmpty) {
      print("Coleção vazia. Iniciando upload de dados fictícios...");

      for (var os in demoData) {
        await collectionRef.add({
          'titulo': os.titulo,
          'descricao': os.descricao,
          'subsistema': os.subsistema,
          'responsavel': os.responsavel,
          'status': os.status,
          'prioridade': os.prioridade,
          'dataInicio': os.dataInicio ?? FieldValue.serverTimestamp(),
          'horasEstimadas': os.horasEstimadas,
          'criadoEm': FieldValue.serverTimestamp(),
        });
      }
      print("Dados sincronizados com sucesso!");
    } else {
      print("A coleção já contém dados. Sincronização ignorada.");
    }
  }

  Future<void> salvarMembro(
      {String? uid,
      required String nome,
      required String email,
      required List<String> subsistema,
      required String role,
      required bool ativo}) async {
    // Referência para a coleção de usuários
    final CollectionReference usersRef = _db.collection('usuarios');

    final dadosMembro = {
      'nome': nome,
      'email': email.toLowerCase().trim(),
      'subsistema': subsistema,
      'role': role,
      'ativo': ativo,
      'ultimaAtualizacao': FieldValue.serverTimestamp(),
    };

    try {
      if (uid != null && uid.isNotEmpty) {
        await usersRef.doc(uid).update(dadosMembro);
      } else {
        await usersRef.add({
          ...dadosMembro,
          'dataCadastro': FieldValue.serverTimestamp(),
          'fotoUrl': null, // Inicializa vazio
        });
        final auth = FirebaseAuth.instance;
        await auth.createUserWithEmailAndPassword(
          email: email.toLowerCase().trim(),
          password: "senha123",
        );
      }
    } catch (e) {
      print("Erro ao salvar membro no SunSystem: $e");
      rethrow;
    }
  }
}
