// lib/models/categoria.dart
import 'package:uuid/uuid.dart';
import 'topico.dart';

class Categoria {
  final String id;
  String nome;
  List<Topico> topicos;
  bool isArchived;
  DateTime? archivedDate; // Adicione esta linha: propriedade para a data de arquivamento

  Categoria({
    String? id,
    required this.nome,
    List<Topico>? topicos,
    this.isArchived = false,
    this.archivedDate, // Inicialize archivedDate (pode ser nulo)
  })  : id = id ?? const Uuid().v4(),
        topicos = topicos ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'topicos': topicos.map((t) => t.toJson()).toList(),
        'isArchived': isArchived,
        'archivedDate': archivedDate?.toIso8601String(), // Converta DateTime para String ISO 8601 para JSON
      };

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        id: json['id'] as String,
        nome: json['nome'] as String,
        topicos: (json['topicos'] as List<dynamic>?)
                ?.map((e) => Topico.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        isArchived: json['isArchived'] as bool? ?? false,
        archivedDate: json['archivedDate'] != null
            ? DateTime.parse(json['archivedDate'] as String)
            : null, // Converta String de volta para DateTime, trate nulos
      );
}