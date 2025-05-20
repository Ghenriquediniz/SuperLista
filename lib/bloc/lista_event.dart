import '../models/item_model.dart';

//Eventos realizados por usuarios
abstract class ListaEvent {}

//Adcionar item
class AddItem extends ListaEvent {
  final Item item;
  AddItem(this.item);
}

//Remover item
class RemoveItem extends ListaEvent {
  final Item item;
  RemoveItem(this.item);
}

//Marca o item
class CheckItem extends ListaEvent {
  final Item item;
  CheckItem(this.item);
}

// Deletar item da lista
class DeleteCheckedItems extends ListaEvent {}

//Add Quantidade
class UpdateItemQuantity extends ListaEvent {
  final Item item;
  final int novaQuantidade;
  UpdateItemQuantity(this.item, this.novaQuantidade);
}

//Editar
class UpdateItem extends ListaEvent {
  final Item oldItem;
  final Item newItem;

  UpdateItem(this.oldItem, this.newItem);
}
