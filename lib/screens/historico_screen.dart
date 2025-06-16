// lib/screens/historico_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/checklist_provider.dart';
import '../models/topico.dart'; // Mantido para o tipo Topico, se você quiser convertê-lo
import '../models/historical_topic_record.dart'; // NOVO IMPORT
import '../models/categoria.dart'; // NOVO IMPORT PARA CATEGORIA

class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ChecklistProvider>(context);

    // Agora usamos a nova lista _archivedTopicRecords diretamente
    final List<HistoricalTopicRecord> archivedRecords = List.from(provider.archivedTopicRecords);

    // Ordenar pelo archivedAt para ser mais preciso no histórico
    archivedRecords.sort((a, b) => b.archivedAt.compareTo(a.archivedAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Tópicos Arquivados')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: archivedRecords.isEmpty
            ? const Center(
                child: Text('Nenhum tópico arquivado ainda.'),
              )
            : ListView.builder(
                itemCount: archivedRecords.length,
                itemBuilder: (context, index) {
                  final record = archivedRecords[index]; // Agora é um HistoricalTopicRecord

                  // Usa o nome da categoria diretamente do registro histórico
                  final String categoryName = record.originalCategoryName;

                  // Formatar a data e hora de arquivamento
                  final String formattedDate =
                      'Arquivado em: ${record.archivedAt.day}/${record.archivedAt.month}/${record.archivedAt.year} '
                      'às ${record.archivedAt.hour.toString().padLeft(2, '0')}:${record.archivedAt.minute.toString().padLeft(2, '0')}';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text(record.title), // Usa o título do registro
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text('Categoria: $categoryName', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Text(formattedDate),
                          if (record.observation.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('Obs: ${record.observation}', style: TextStyle(fontStyle: FontStyle.italic)),
                            ),
                          // Exibe o status de conclusão no momento do arquivamento
                          if (record.checkedAtArchive)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Concluído no arquivo: Sim',
                                style: TextStyle(fontSize: 12, color: Colors.green[700]),
                              ),
                            ),
                           if (!record.checkedAtArchive)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Concluído no arquivo: Não',
                                style: TextStyle(fontSize: 12, color: Colors.red[700]),
                              ),
                            ),
                        ],
                      ),
                      children: [
                        // Bloco que exibe os subtópicos
                        if (record.subtopicsAtArchive.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Subtópicos:', style: TextStyle(fontWeight: FontWeight.bold)),
                                ...record.subtopicsAtArchive.map((sub) => Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                      child: Text(
                                        '- ${sub.titulo} '
                                        '${sub.checked ? '( Concluído )' : ''}'
                                        '${sub.observacao.isNotEmpty ? ' (Obs: ${sub.observacao})' : ''}',
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.unarchive),
                                label: const Text('Desarquivar e Resetar'),
                                onPressed: () {
                                  provider.unarchiveTopico(record); // Passa o registro
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Tópico "${record.title}" desarquivado e resetado.')),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                icon: const Icon(Icons.delete_forever, color: Colors.red),
                                label: const Text('Excluir'),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return AlertDialog(
                                        title: const Text('Confirmar Exclusão'),
                                        content: Text('Tem certeza que deseja excluir permanentemente o tópico "${record.title}" do histórico? Esta ação não pode ser desfeita.'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Cancelar'),
                                            onPressed: () {
                                              Navigator.of(dialogContext).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Excluir'),
                                            onPressed: () {
                                              provider.removeHistoricoTopico(record); // Passa o registro
                                              Navigator.of(dialogContext).pop();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Tópico "${record.title}" removido do histórico.')),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
