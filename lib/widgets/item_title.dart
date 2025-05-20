import 'package:flutter/material.dart';
import '../models/item_model.dart';

class ItemTile extends StatelessWidget {
  final Item item;

  const ItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Checkbox(
              value: item.isChecked,
              onChanged: (_) {
                if (item.docRef != null) {
                  item.docRef!.update({'concluido': !item.isChecked});
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            const SizedBox(width: 8.0),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      decoration:
                          item.isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    'R\$ ${item.price.toStringAsFixed(2)} x${item.quantity}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Text(
              'R\$ ${(item.price * item.quantity).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8.0),
            const Icon(Icons.drag_handle, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
