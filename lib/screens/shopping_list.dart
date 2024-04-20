import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shoppinglist_riverpod/models/list_controller.dart';

// Providers
final filterStatusProvider =
    StateProvider<FilterStatus>((ref) => FilterStatus.all);

final shoppingListProvider =
    StateNotifierProvider<ShoppingListController, List<String>>(
  (ref) => ShoppingListController(),
);

final checkedItemsProvider = StateProvider.autoDispose((ref) => <int, bool>{});

enum FilterStatus {
  all,
  checked,
  unchecked,
}

class ShoppingList extends ConsumerWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Shopping List",
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
        actions: [
          Consumer(builder: (context, ref, child) {
            final status = ref.watch(filterStatusProvider);
            return DropdownButton<FilterStatus>(
              value: status,
              style: const TextStyle(color: Colors.white),
              onChanged: (fS) {
                ref.read(filterStatusProvider.notifier).state = fS!;
              },
              onTap: () {},
              items: FilterStatus.values
                  .map((fS) => DropdownMenuItem<FilterStatus>(
                        value: fS,
                        child: Text(
                          fS.toString().split('.').last,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ))
                  .toList(),
            );
          })
        ],
      ),
      body: Consumer(builder: (context, ref, child) {
        final items = ref.watch(shoppingListProvider);
        final checkedItems = ref.watch(checkedItemsProvider);
        final filterStatus =
            ref.watch(filterStatusProvider); // Access the state property

        List<String> filteredItems = [];
        Map<int, bool> filteredCheckedItems = {};

        // Filter items based on filter status
        switch (filterStatus) {
          case FilterStatus.checked:
            filteredItems = items
                .asMap()
                .entries
                .where((entry) => checkedItems[entry.key] ?? false)
                .map((entry) => entry.value)
                .toList();
            // Preserve checked status for checked items
            filteredCheckedItems = Map.fromEntries(
                checkedItems.entries.where((entry) => entry.value));
            break;
          case FilterStatus.unchecked:
            filteredItems = items
                .asMap()
                .entries
                .where((entry) => !(checkedItems[entry.key] ?? false))
                .map((entry) => entry.value)
                .toList();
            // Preserve checked status for unchecked items
            filteredCheckedItems = Map.fromEntries(
                checkedItems.entries.where((entry) => !entry.value));
            break;
          case FilterStatus.all:
          default:
            filteredItems = items;
            filteredCheckedItems = checkedItems;
            break;
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final isChecked = filteredCheckedItems[index] ??
                false; // Use filteredCheckedItems

            return Slidable(
              endActionPane:
                  ActionPane(motion: const StretchMotion(), children: [
                SlidableAction(
                  backgroundColor: Colors.red,
                  icon: Icons.delete,
                  onPressed: (BuildContext context) {
                    ref.read(shoppingListProvider.notifier).delete(item);
                  },
                )
              ]),
              child: ListTile(
                title: Text(
                  item,
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: filterStatus == FilterStatus.all
                    ? GestureDetector(
                        onTap: () {
                          ref.read(checkedItemsProvider.notifier).state = {
                            ...filteredCheckedItems, // Use filteredCheckedItems
                            index: !isChecked,
                          };
                        },
                        child: Icon(
                          isChecked
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank,
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      }),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const ExtractedAlertDialog();
              },
            );
          },
          shape: const CircleBorder(),
          backgroundColor: Colors.orange,
          child: const Icon(
            Icons.add,
            size: 35,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

String? newItem;

class ExtractedAlertDialog extends ConsumerWidget {
  const ExtractedAlertDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: const Text(
        "ADD AN ITEM TO SHOPPING THE LIST ",
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.infinity,
        height: 45,
        child: TextField(
          onChanged: (value) => {newItem = value},
          decoration: const InputDecoration(
            hintText: "Item name...",
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            ref.read(shoppingListProvider.notifier).addItem(newItem!);

            // Close the screen after that
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text("Save"),
        ),
        const SizedBox(width: 50),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
