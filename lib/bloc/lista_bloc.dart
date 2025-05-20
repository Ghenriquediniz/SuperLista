import 'package:flutter_bloc/flutter_bloc.dart';
import 'lista_event.dart';
import 'lista_state.dart';

//Tratar os eventos da lista e atualizar o estado
class ListaComprasBloc extends Bloc<ListaEvent, ListaState> {
  /// Iniciar lista vazia
  ListaComprasBloc() : super(ListaState(items: [])) {
    /// Adcionar o item

    on<AddItem>((event, emit) {
      emit(state.copyWith(items: [...state.items, event.item]));
    });

    /// Remover
    on<RemoveItem>((event, emit) {
      emit(
        state.copyWith(
          items: state.items.where((item) => item != event.item).toList(),
        ),
      );
    });

    //Add quantidade
    on<UpdateItemQuantity>((event, emit) {
      final updatedItems =
          state.items.map((item) {
            return item == event.item
                ? item.copyWith(quantity: event.novaQuantidade)
                : item;
          }).toList();

      emit(state.copyWith(items: updatedItems));
    });

    //Delete
    on<DeleteCheckedItems>((event, emit) {
      emit(
        state.copyWith(
          items: state.items.where((item) => !item.isChecked).toList(),
        ),
      );
    });

    //Editar
    on<UpdateItem>((event, emit) {
      final updatedItems =
          state.items.map((item) {
            return item == event.oldItem ? event.newItem : item;
          }).toList();

      emit(state.copyWith(items: updatedItems));
    });

    /// Marcado
    on<CheckItem>((event, emit) {
      final updatedItems =
          state.items.map((item) {
            return item == event.item
                ? item.copyWith(isChecked: !item.isChecked)
                : item;
          }).toList();

      emit(state.copyWith(items: updatedItems));
    });
  }
}
