// lib/providers/checklist_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/categoria.dart';
import '../models/topico.dart';
import '../models/subtopico.dart';
import '../models/historical_topic_record.dart';

class ChecklistProvider with ChangeNotifier {
  List<Categoria> _categorias = [];
  List<HistoricalTopicRecord> _archivedTopicRecords = [];

  List<Categoria> get categorias => _categorias;
  List<HistoricalTopicRecord> get archivedTopicRecords => _archivedTopicRecords;

  ChecklistProvider() {
    loadData();
  }

  // O getter historicoTopicos agora retorna HistoricalTopicRecord
  List<Topico> get historicoTopicos {
    // Isso é para compatibilidade, mas HistoricoScreen deve usar archivedTopicRecords diretamente
    // Ou HistoricoScreen pode criar Tópicos a partir de HistoricalTopicRecord
    return _archivedTopicRecords.map((record) => Topico(
      id: record.originalTopicId, // Mantém o ID original do tópico, mas o ID do registro é o record.id
      titulo: record.title,
      checked: record.checkedAtArchive,
      observacao: record.observation,
      completionDate: record.completionDateAtArchive,
      isArchived: true, // Sempre verdadeiro para itens no histórico
      archivedDate: record.archivedAt,
      subtopicos: record.subtopicsAtArchive, // Incluir subtopicos para desarquivamento, mesmo que não exibidos
    )).toList();
  }

  // Categoria methods
  void addCategoria(String nome) {
    if (nome.trim().isEmpty) return;
    _categorias.add(Categoria(nome: nome));
    saveData();
    notifyListeners();
  }

  void removeCategoria(Categoria categoria) {
    // MODIFICADO: Não remove mais os registros históricos associados à categoria.
    // _archivedTopicRecords.removeWhere((record) => record.originalCategoryId == categoria.id);
    _categorias.remove(categoria);
    saveData();
    notifyListeners();
  }

  void archiveCategoria(Categoria categoria) {
    for (var topico in List<Topico>.from(categoria.topicos)) {
      archiveTopico(categoria, topico);
    }
    saveData();
    notifyListeners();
  }

  void unarchiveCategoria(Categoria categoria) {
    categoria.isArchived = false;
    categoria.archivedDate = null;
    for (var topico in categoria.topicos) {
      topico.isArchived = false;
      topico.archivedDate = null;
      resetTopicoCompletion(topico);
    }
    saveData();
    notifyListeners();
  }

  void resetCategoria(Categoria categoria) {
    for (var topico in categoria.topicos) {
      resetTopicoCompletion(topico);
    }
    saveData();
    notifyListeners();
  }

  // Topic methods
  void addTopico(Categoria categoria, String titulo) {
    if (titulo.trim().isEmpty) return;
    categoria.topicos.add(Topico(titulo: titulo));
    saveData();
    notifyListeners();
  }

  void removeTopico(Categoria categoria, Topico topico) {
    categoria.topicos.removeWhere((t) => t.id == topico.id);
    saveData();
    notifyListeners();
  }

  void toggleTopico(Topico topico, bool? checked) {
    topico.checked = checked ?? false;
    if (topico.checked) {
      topico.completionDate = DateTime.now();
    } else {
      topico.completionDate = null;
    }
    if (!topico.checked) {
      for (var subtopico in topico.subtopicos) {
        subtopico.checked = false;
      }
    }
    saveData();
    notifyListeners();
  }

  void archiveTopico(Categoria categoria, Topico topico) {
    final historicalRecord = HistoricalTopicRecord(
      originalTopicId: topico.id,
      originalCategoryId: categoria.id,
      originalCategoryName: categoria.nome, // NOVO: Salva o nome da categoria
      title: topico.titulo,
      observation: topico.observacao,
      checkedAtArchive: topico.checked,
      archivedAt: DateTime.now(),
      completionDateAtArchive: topico.completionDate,
      subtopicsAtArchive: List.from(topico.subtopicos),
    );
    _archivedTopicRecords.add(historicalRecord);

    saveData();
    notifyListeners();
  }

  void unarchiveTopico(HistoricalTopicRecord record) {
    _archivedTopicRecords.removeWhere((r) => r.id == record.id);

    final originalCategory = _categorias.firstWhere(
      (cat) => cat.id == record.originalCategoryId,
      orElse: () {
        // Se a categoria original não for encontrada, cria uma nova usando o nome original.
        final newCat = Categoria(nome: record.originalCategoryName); // NOVO: Usa o nome original
        _categorias.add(newCat);
        return newCat;
      },
    );

    final newActiveTopico = Topico(
      id: record.originalTopicId,
      titulo: record.title,
      observacao: record.observation,
      checked: false,
      completionDate: null,
      isArchived: false,
      archivedDate: null,
      subtopicos: List.from(record.subtopicsAtArchive),
    );

    originalCategory.topicos.add(newActiveTopico);

    saveData();
    notifyListeners();
  }

  void removeHistoricoTopico(HistoricalTopicRecord record) {
    _archivedTopicRecords.removeWhere((r) => r.id == record.id);
    saveData();
    notifyListeners();
  }

  void resetTopicoCompletion(Topico topico) {
    topico.checked = false;
    topico.completionDate = null;
    for (var subtopico in topico.subtopicos) {
      subtopico.checked = false;
      subtopico.observacao = '';
    }
    saveData();
    notifyListeners();
  }

  // Subtopico methods
  void addSubtopico(Topico topico, String titulo) {
    if (titulo.trim().isEmpty) return;
    topico.subtopicos.add(Subtopico(titulo: titulo));
    if (topico.checked) {
      topico.checked = false;
      topico.completionDate = null;
    }
    saveData();
    notifyListeners();
  }

  void removeSubtopico(Topico topico, Subtopico subtopico) {
    topico.subtopicos.removeWhere((s) => s.id == subtopico.id);
    if (topico.subtopicos.isEmpty) {
      topico.checked = false;
      topico.completionDate = null;
    } else if (topico.isFullyChecked) {
      topico.checked = true;
      topico.completionDate = DateTime.now();
    } else {
      topico.checked = false;
      topico.completionDate = null;
    }
    saveData();
    notifyListeners();
  }

  void toggleSubtopico(Topico topico, Subtopico subtopico, bool? checked) {
    subtopico.checked = checked ?? false;

    if (topico.subtopicos.every((s) => s.checked)) {
      topico.checked = true;
      topico.completionDate = DateTime.now();
    } else {
      topico.checked = false;
      topico.completionDate = null;
    }
    saveData();
    notifyListeners();
  }

  // Observation updates
  void updateTopicoObservation(Topico topico, String observacao) {
    topico.observacao = observacao;
    saveData();
    notifyListeners();
  }

  void updateSubtopicoObservation(Subtopico subtopico, String observacao) {
    subtopico.observacao = observacao;
    saveData();
    notifyListeners();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? categoriasString = prefs.getString('categorias');
    if (categoriasString != null) {
      final List<dynamic> jsonList = json.decode(categoriasString);
      _categorias = jsonList.map((e) => Categoria.fromJson(e as Map<String, dynamic>)).toList();
    }

    final String? archivedRecordsString = prefs.getString('archivedTopicRecords');
    if (archivedRecordsString != null) {
      final List<dynamic> jsonList = json.decode(archivedRecordsString);
      _archivedTopicRecords = jsonList.map((e) => HistoricalTopicRecord.fromJson(e as Map<String, dynamic>)).toList();
    }
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String categoriasJson = json.encode(_categorias.map((c) => c.toJson()).toList());
    await prefs.setString('categorias', categoriasJson);

    final String archivedRecordsJson = json.encode(_archivedTopicRecords.map((r) => r.toJson()).toList());
    await prefs.setString('archivedTopicRecords', archivedRecordsJson);
  }
}
