// lib/models/subtopico.dart
import 'package:uuid/uuid.dart'; // Importe a biblioteca uuid

class Subtopico {
  final String id; // Adicione um ID único
  String titulo;
  bool checked;
  String observacao;

  Subtopico({
    String? id, // Permite que o ID seja passado ou gerado
    required this.titulo,
    this.checked = false,
    this.observacao = '',
  }) : id = id ?? const Uuid().v4(); // Gera um UUID se nenhum ID for fornecido

  Map<String, dynamic> toJson() => {
        'id': id, // Inclua o ID no JSON para persistência
        'titulo': titulo,
        'checked': checked,
        'observacao': observacao,
      };

  factory Subtopico.fromJson(Map<String, dynamic> json) => Subtopico(
        id: json['id'] as String, // Leia o ID do JSON
        titulo: json['titulo'] as String,
        checked: json['checked'] as bool? ?? false,
        observacao: json['observacao'] as String? ?? '',
      );
}