// lib/models/topico.dart
import 'package:uuid/uuid.dart';
import 'package:ckeck/models/subtopico.dart';

class Topico {
  final String id;
  String titulo;
  bool checked;
  String observacao;
  List<Subtopico> subtopicos;
  bool isArchived;
  DateTime? completionDate;
  DateTime? archivedDate; // Adicione esta linha: propriedade para a data de arquivamento

  bool get isFullyChecked => subtopicos.isNotEmpty && subtopicos.every((s) => s.checked);

  Topico({
    String? id,
    required this.titulo,
    this.checked = false,
    this.observacao = '',
    List<Subtopico>? subtopicos,
    this.isArchived = false,
    this.completionDate,
    this.archivedDate, // Inicialize archivedDate (pode ser nulo)
  })  : id = id ?? const Uuid().v4(),
        subtopicos = subtopicos ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'checked': checked,
        'observacao': observacao,
        'subtopicos': subtopicos.map((s) => s.toJson()).toList(),
        'isArchived': isArchived,
        'completionDate': completionDate?.toIso8601String(),
        'archivedDate': archivedDate?.toIso8601String(), // Converta DateTime para String ISO 8601 para JSON
      };

  factory Topico.fromJson(Map<String, dynamic> json) => Topico(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        checked: json['checked'] as bool? ?? false,
        observacao: json['observacao'] as String? ?? '',
        subtopicos: (json['subtopicos'] as List<dynamic>?)
                ?.map((e) => Subtopico.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        isArchived: json['isArchived'] as bool? ?? false,
        completionDate: json['completionDate'] != null
            ? DateTime.parse(json['completionDate'] as String)
            : null,
        archivedDate: json['archivedDate'] != null
            ? DateTime.parse(json['archivedDate'] as String)
            : null, // Converta String de volta para DateTime, trate nulos
      );
}