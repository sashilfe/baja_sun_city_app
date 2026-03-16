class KPIModel {
  final String label; // Ex: "Produtividade FASD" ou "Total H/H Semana"
  final double valorAtual; // O que foi realizado
  final double meta; // O planejado no SolidWorks/Cronograma
  final String unidade; // "h", "R$", "%"
  final bool tendenciaPositiva; // Para mostrar setinha pra cima/baixo
  final List<double>? historico; // Para desenhar um mini-gráfico (Sparkline)

  KPIModel({
    required this.label,
    required this.valorAtual,
    required this.meta,
    this.unidade = "",
    this.tendenciaPositiva = true,
    this.historico,
  });

  double get porcentagemAtingida => (valorAtual / meta) * 100;

  bool get ultrapassouMeta => valorAtual > meta;
}
