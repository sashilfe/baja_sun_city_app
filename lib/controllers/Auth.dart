import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/models/Usuario.dart';
import 'package:admin/services/firestore_service.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  Usuario? _usuario;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  User? get usuarioAtual => _user;
  Usuario? get usuario => _usuario;

  bool get podeGerenciarUsuarios {
    if (_usuario == null) return false;
    return _usuario!.role == UserRole.admin ||
        _usuario!.role == UserRole.orientador;
  }

  AuthController() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;

      if (user != null) {
        await _carregarDadosUsuario(user.uid); // Busca dados do Firestore
        // criarPerfilAdminInicial(user);
      } else {
        _usuario = null;
      }
      notifyListeners();
    });
  }
  Future<void> _carregarDadosUsuario(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();
      if (doc.exists) {
        _usuario = Usuario.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print('Erro ao carregar usuário: $e');
    }
  }

  // Função para cadastrar novos membros (Apenas Admin e Orientador)
  Future<String?> registrarNovoMembro({
    required String email,
    required String password,
    required String nome,
    required String role,
    required String subsistema,
  }) async {
    if (!podeGerenciarUsuarios) {
      return "Acesso negado: Apenas Admin ou Orientador podem realizar esta ação.";
    }

    try {
      // 1. Cria o usuário no Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Salva os detalhes e o Role no Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'nome': nome,
        'email': email,
        'role': role,
        'subsistema': subsistema,
        'dataCriacao': FieldValue.serverTimestamp(),
      });

      return null; // Sucesso
    } catch (e) {
      return e.toString();
    }
  }

  // Função para excluir usuário
  Future<String?> excluirUsuario(String uid) async {
    if (!podeGerenciarUsuarios) {
      return "Acesso negado.";
    }

    try {
      // Remove do Firestore (A remoção do Auth exige re-autenticação ou Cloud Functions)
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> criarPerfilAdminInicial(User user) async {
    await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
      'nome': 'Saulo Alves (Admin)',
      'email': user.email,
      'role': 'admin',
      'fotoUrl':
          "https://img.freepik.com/fotos-gratis/homem-bonito-posando-e-sorrindo_23-2149396133.jpg",
      'subsistema': ["Geral"],
      'dataCriacao': FieldValue.serverTimestamp(),
      'ativo': true,
    });
  }

  // Função de Login
  Future<String?> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {
        await FirestoreService().atualizarTokenFCM(userCredential.user!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message; // Retorna o erro para a View exibir
    }
  }

  // Função de Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
