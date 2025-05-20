import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';

//Salvar item
Future<void> salvarItemNoFirestore(Item item) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(user.uid)
      .collection('itens')
      .add({
        'nome': item.name,
        'preco': item.price,
        'quantidade': item.quantity,
        'criadoEm': FieldValue.serverTimestamp(),
      });
}

//Excluir item
Future<bool> excluirItemDoFirestore(DocumentReference docRef) async {
  try {
    await docRef.delete();
    return true;
  } catch (e) {
    print('Erro ao excluir item: $e');
    return false;
  }
}
