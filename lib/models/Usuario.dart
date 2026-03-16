enum UserRole {
  admin,
  orientador,
  capitao,
  diretor,
  lider,
  membro,
  trainee,
  estagiario
}

class Usuario {
  final String uid;
  final String nome;
  final String email;
  final UserRole role;
  final String? diretoria;
  final String? fotoUrl;
  final List<String> subsistema;
  final bool ativo;

  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    this.fotoUrl,
    required this.role,
    this.diretoria,
    this.subsistema = const ["Geral"],
    this.ativo = true,
    required String id,
  });

  static UserRole roleFromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == role,
      orElse: () => UserRole.membro,
    );
  }

  factory Usuario.fromMap(Map<String, dynamic> map, String id) {
    return Usuario(
      uid: id,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      fotoUrl: map['fotoUrl'],
      role: Usuario.roleFromString(map['role'] ?? 'membro'),
      subsistema: List<String>.from(map['subsistema'] ?? ['Geral']),
      diretoria: map['diretoria'],
      ativo: map['ativo'] ?? true,
      id: '',
    );
  }

  bool get podeCriarOS {
    return role == UserRole.admin ||
        role == UserRole.diretor ||
        role == UserRole.lider ||
        role == UserRole.capitao;
  }
}
