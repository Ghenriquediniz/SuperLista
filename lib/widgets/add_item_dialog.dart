import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';
import '../theme/app_colors.dart';

void showAddItemDialog(BuildContext context, {Item? item}) {
  final nomeController = TextEditingController(text: item?.name ?? '');
  final precoController = TextEditingController(
    text: item?.price.toStringAsFixed(2) ?? '',
  );
  int quantidade = item?.quantity ?? 1;
  final FocusNode nomeFocusNode = FocusNode();

  bool jaDeiFoco = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        color: AppColors.background,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              if (!jaDeiFoco) {
                jaDeiFoco = true;
                Future.delayed(const Duration(milliseconds: 100), () {
                  FocusScope.of(context).requestFocus(nomeFocusNode);
                });
              }

              double getTotal() {
                final preco =
                    double.tryParse(
                      precoController.text.replaceAll(',', '.'),
                    ) ??
                    0.0;
                return preco * quantidade;
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nome do item',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nomeController,
                    focusNode: nomeFocusNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Preço',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: precoController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                              ),
                              style: const TextStyle(fontSize: 14),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Qtd',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    if (quantidade > 1)
                                      setState(() => quantidade--);
                                  },
                                  iconSize: 30,
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      quantidade.toString(),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => setState(() => quantidade++),
                                  iconSize: 30,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: R\$ ${getTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final nome = nomeController.text.trim();
                              final preco =
                                  double.tryParse(
                                    precoController.text.replaceAll(',', '.'),
                                  ) ??
                                  0.0;

                              if (nome.isNotEmpty && preco > 0) {
                                final novoItem = {
                                  'nome': nome,
                                  'preco': preco,
                                  'quantidade': quantidade,
                                  'concluido': item?.isChecked ?? false,
                                  'criadoEm': FieldValue.serverTimestamp(),
                                };

                                final uid =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (uid == null) return;

                                final colecao = FirebaseFirestore.instance
                                    .collection('usuarios')
                                    .doc(uid)
                                    .collection('itens');

                                if (item == null || item.docRef == null) {
                                  await colecao.add(novoItem);
                                } else {
                                  await item.docRef!.update(novoItem);
                                }

                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(item == null ? 'Adicionar' : 'Salvar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}
