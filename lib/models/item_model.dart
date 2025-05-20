import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String name;
  final double price;
  final bool isChecked;
  final int quantity;
  final DocumentReference? docRef; // para deletar/atualizar no Firestore

  Item({
    required this.name,
    required this.price,
    this.isChecked = false,
    this.quantity = 1,
    this.docRef,
  });

  Item copyWith({
    String? name,
    double? price,
    bool? isChecked,
    int? quantity,
    DocumentReference? docRef,
  }) {
    return Item(
      name: name ?? this.name,
      price: price ?? this.price,
      isChecked: isChecked ?? this.isChecked,
      quantity: quantity ?? this.quantity,
      docRef: docRef ?? this.docRef,
    );
  }
}
