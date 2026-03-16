class OSSummary {
  final int abertas; // Em andamento/Execução
  final int pendentes; // Aguardando início (backlog)
  final int fechadas; // Concluídas/Finalizadas
  final int total; // Soma de todas

  OSSummary({
    this.abertas = 0,
    this.pendentes = 0,
    this.fechadas = 0,
  }) : total = abertas + pendentes + fechadas;

  double get aproveitamento => total > 0 ? (fechadas / total) * 100 : 0;
}
