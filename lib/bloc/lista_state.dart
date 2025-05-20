import '../models/item_model.dart';

//Estado autal da lista
class ListaState {
  //Lista de todos os itens da compra
  final List<Item> items;
  ListaState({required this.items});
  //Calcular o valor total dos items
  double get totalComprado => items
      .where((item) => item.isChecked)
      .fold(0, (soma, item) => soma + item.price);
  // Calcula o valor total dos itens ainda não comprados.
  double get totalRestante => items
      .where((item) => !item.isChecked)
      .fold(0, (soma, item) => soma + item.price);
  //Retorna uma cópia modificada
  ListaState copyWith({List<Item>? items}) {
    return ListaState(items: items ?? this.items);
  }
}
