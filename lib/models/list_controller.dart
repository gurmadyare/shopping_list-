import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShoppingListController extends StateNotifier<List<String>> {
  ShoppingListController() : super(["Banana", "Apple", "Orange"]);

  void addItem(String item) {
    state = [...state, item];
  }

  void delete(String item) {
    state = [...state.where((element) => element != item)];
  }
}
