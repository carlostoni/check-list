import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/categoria.dart';
import '../providers/checklist_provider.dart';
import '../screens/checklist_screen.dart'; // Importe ChecklistScreen
import '../screens/historico_screen.dart'; // Importe HistoricoScreen (para tópicos)
import '../widgets/categoria_drawer.dart'; // Importe CategoriaDrawer

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Categoria? _categoriaSelecionada; // Ainda útil para destacar no Drawer

  @override
  void initState() {
    super.initState();
    // Após a primeira renderização, tenta selecionar a primeira categoria ativa
    // se nenhuma estiver selecionada.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChecklistProvider>(context, listen: false);
      if (_categoriaSelecionada == null && provider.categorias.isNotEmpty) {
        final activeCategories = provider.categorias.where((cat) => !cat.isArchived).toList();
        if (activeCategories.isNotEmpty) {
          setState(() {
            _categoriaSelecionada = activeCategories.first;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consumer é usado aqui para que apenas este widget (e seus filhos) reconstruam
    // quando houver mudanças nas categorias do provider, otimizando o desempenho.
    return Consumer<ChecklistProvider>(
      builder: (context, provider, child) {
        // Assegura que _categoriaSelecionada esteja sempre em um estado válido
        // baseado nas categorias ativas atuais.
        final activeCategories = provider.categorias.where((cat) => !cat.isArchived).toList();
        if (_categoriaSelecionada != null && !activeCategories.contains(_categoriaSelecionada)) {
          // Se a categoria selecionada foi removida ou arquivada, limpa a seleção
          // ou seleciona a primeira categoria ativa disponível.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _categoriaSelecionada = activeCategories.isNotEmpty ? activeCategories.first : null;
            });
          });
        } else if (_categoriaSelecionada == null && activeCategories.isNotEmpty) {
          // Se nenhuma categoria estiver selecionada mas houver categorias ativas, seleciona a primeira.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _categoriaSelecionada = activeCategories.first;
            });
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Checklist'),
          ),
          drawer: CategoriaDrawer(
            onCategorySelected: (category) {
              setState(() {
                _categoriaSelecionada = category;
              });
              Navigator.pop(context); // Fecha o drawer
              // Navega para a ChecklistScreen quando uma categoria é selecionada pelo drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => ChecklistScreen(categoria: category),
                ),
              );
            },
            selectedCategoryId: _categoriaSelecionada?.id,
          ),
          body: activeCategories.isEmpty
              ? const Center(
                  child: Text('Nenhuma categoria disponível. Adicione uma pelo menu lateral!'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 cards por linha
                    crossAxisSpacing: 16.0, // Espaçamento horizontal
                    mainAxisSpacing: 16.0, // Espaçamento vertical
                    childAspectRatio: 3 / 2, // Proporção da largura pela altura do card
                  ),
                  itemCount: activeCategories.length,
                  itemBuilder: (context, index) {
                    final categoria = activeCategories[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: InkWell( // Permite o efeito de toque no card
                        borderRadius: BorderRadius.circular(15.0),
                        onTap: () {
                          setState(() {
                            _categoriaSelecionada = categoria;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => ChecklistScreen(categoria: categoria),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              categoria.nome,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis, // Lida com nomes longos
                              maxLines: 3,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
