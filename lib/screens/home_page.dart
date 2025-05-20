import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bloc/lista_bloc.dart';

import '../bloc/lista_state.dart';
import '../models/item_model.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/item_title.dart';
import '../theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _excluirItensConcluidos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final itensRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('itens');

    final querySnapshot =
        await itensRef.where('concluido', isEqualTo: true).get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 244, 250, 255),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bem-vindo,',
                    style: TextStyle(color: AppColors.background),
                  ),
                  FutureBuilder<User?>(
                    future: Future.value(FirebaseAuth.instance.currentUser),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          'Usuário desconhecido',
                          style: TextStyle(
                            color: AppColors.background,
                            fontSize: 24,
                          ),
                        );
                      }

                      final user = snapshot.data;
                      return Text(
                        user?.displayName ?? 'Usuário sem nome',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 24,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sair'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<ListaComprasBloc, ListaState>(
        builder: (context, state) {
          return Container(
            color: AppColors.background,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                ),

                // Firebase exibe alterações em tempo real
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('usuarios')
                            .doc(uid)
                            .collection('itens')
                            .orderBy('criadoEm', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Nenhum item cadastrado.'),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final item = Item(
                            name: data['nome'] ?? '',
                            price: (data['preco'] as num?)?.toDouble() ?? 0.0,
                            quantity: (data['quantidade'] as int?) ?? 1,
                            isChecked: data['concluido'] ?? false,
                            docRef: doc.reference,
                          );

                          return GestureDetector(
                            onTap: () => showAddItemDialog(context, item: item),
                            child: ItemTile(item: item),
                          );
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir itens concluídos',
                        onPressed: _excluirItensConcluidos,
                      ),
                      //Adicionar tarefa
                      const SizedBox(width: 12),
                      FloatingActionButton(
                        onPressed: () => showAddItemDialog(context),
                        tooltip: 'Adicionar item',
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),

                const Divider(),
                //Total
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(uid)
                          .collection('itens')
                          .snapshots(),
                  builder: (context, snapshot) {
                    double totalComprado = 0.0;
                    double totalRestante = 0.0;

                    if (snapshot.hasData) {
                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final preco =
                            (data['preco'] as num?)?.toDouble() ?? 0.0;
                        final quantidade =
                            (data['quantidade'] as num?)?.toInt() ?? 1;
                        final concluido = data['concluido'] ?? false;

                        final totalItem = preco * quantidade;

                        if (concluido) {
                          totalComprado += totalItem;
                        } else {
                          totalRestante += totalItem;
                        }
                      }
                    }

                    return Container(
                      color: AppColors.background,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total restante\nR\$ ${totalRestante.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20),
                            ),
                            Text(
                              'Total comprado\nR\$ ${totalComprado.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
