// lib/models/agendamento.dart


class Agendamento {
  final int? id;
  final int idAnimal;
  final String? nomeAnimal;
  final int idServicos;
  final String? nomeServico; // Opcional, para facilitar a exibição
  final DateTime dataAgendamento;
  final String horaAgendamento;
  final String? observacoes;

  Agendamento({
    this.id,
    required this.idAnimal,
    this.nomeAnimal,
    required this.idServicos,
    this.nomeServico,
    required this.dataAgendamento,
    required this.horaAgendamento,
    this.observacoes,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      idAnimal: json['id_animal'],
      nomeAnimal: json['nome_animal'],
      idServicos: json['id_servicos'],
      nomeServico: json['nome_servico'],
      dataAgendamento: DateTime.parse(json['data_agendamento']),
      horaAgendamento: json['hora_agendamento'],
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_animal': idAnimal,
      'id_servicos': idServicos,
      'data_agendamento': dataAgendamento.toIso8601String().substring(0, 10),
      'hora_agendamento': horaAgendamento,
      'observacoes': observacoes,
    };
  }
}