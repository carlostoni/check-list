// lib/models/historical_topic_record.dart
import 'package:ckeck/models/subtopico.dart';
import 'package:uuid/uuid.dart';
 // Garanta que este caminho está correto

class HistoricalTopicRecord {
  final String id; // ID único para este registro histórico específico
  final String originalTopicId; // ID do Topico original
  final String originalCategoryId; // ID da categoria de onde veio (para desarquivamento)
  final String originalCategoryName; // NOVO: Nome da categoria original
  final String title;
  final String observation;
  final bool checkedAtArchive; // Status de marcado no momento do arquivamento
  final DateTime archivedAt;
  final DateTime? completionDateAtArchive; // Data de conclusão no momento do arquivamento
  final List<Subtopico> subtopicsAtArchive; // Snapshot dos subtópicos no momento do arquivamento

  HistoricalTopicRecord({
    String? id,
    required this.originalTopicId,
    required this.originalCategoryId,
    required this.originalCategoryName, // NOVO: Inicialização
    required this.title,
    required this.observation,
    required this.checkedAtArchive,
    required this.archivedAt,
    this.completionDateAtArchive,
    List<Subtopico>? subtopicsAtArchive,
  }) : id = id ?? const Uuid().v4(), // Gera um UUID para cada registro histórico
       subtopicsAtArchive = subtopicsAtArchive ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalTopicId': originalTopicId,
        'originalCategoryId': originalCategoryId,
        'originalCategoryName': originalCategoryName, // NOVO: Inclusão no JSON
        'title': title,
        'observation': observation,
        'checkedAtArchive': checkedAtArchive,
        'archivedAt': archivedAt.toIso8601String(),
        'completionDateAtArchive': completionDateAtArchive?.toIso8601String(),
        'subtopicsAtArchive': subtopicsAtArchive.map((s) => s.toJson()).toList(),
      };

  factory HistoricalTopicRecord.fromJson(Map<String, dynamic> json) => HistoricalTopicRecord(
        id: json['id'] as String,
        originalTopicId: json['originalTopicId'] as String,
        originalCategoryId: json['originalCategoryId'] as String,
        originalCategoryName: json['originalCategoryName'] as String? ?? 'Desconhecida', // NOVO: Leitura do JSON
        title: json['title'] as String,
        observation: json['observation'] as String,
        checkedAtArchive: json['checkedAtArchive'] as bool,
        archivedAt: DateTime.parse(json['archivedAt'] as String),
        completionDateAtArchive: json['completionDateAtArchive'] != null
            ? DateTime.parse(json['completionDateAtArchive'] as String)
            : null,
        subtopicsAtArchive: (json['subtopicsAtArchive'] as List<dynamic>?)
                ?.map((e) => Subtopico.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
