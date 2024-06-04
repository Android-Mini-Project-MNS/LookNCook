import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';


class RecipeScreen extends StatefulWidget {
  const RecipeScreen({Key? key}) : super(key: key);

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  TextEditingController _ingredientController = TextEditingController();
  List<String> _ingredients = [];
  List<String> _recipes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LookNCook'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AutoCompleteTextField<String>(
              key: key,
              clearOnSubmit: false,
              suggestions: _ingredients,
              decoration: InputDecoration(
                labelText: 'Enter an ingredient',
              ),
              controller: _ingredientController,
              itemFilter: (item, query) {
                return item.toLowerCase().startsWith(query.toLowerCase());
              },
              itemSorter: (a, b) {
                return a.compareTo(b);
              },
              itemSubmitted: (item) {
                setState(() {
                  _ingredientController.text = item;
                });
              },
              itemBuilder: (context, item) {
                return ListTile(
                  title: Text(item),
                );
              },
            ),
            ElevatedButton(
              onPressed: _addIngredient,
              child: const Text('Add Ingredient'),
            ),
            // Rest of your code...
          ],
        ),
      ),
    );
  }
  void _addIngredient() {
    setState(() {
      _ingredients.add(_ingredientController.text);
      _ingredientController.clear();
    });
  }

  Future<void> _getRecipes() async {
    final response = await http.post(
      Uri.parse('https://api.yourgeminiapi.com/recipes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, List<String>>{
        'ingredients': _ingredients,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _recipes = data.map((item) => item['name'] as String).toList();
      });
    } else {
      throw Exception('Failed to load recipes');
    }
  }

}
