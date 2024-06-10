import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ingredient_list.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({Key? key}) : super(key: key);

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  TextEditingController _ingredientController = TextEditingController();
  List<String> _ingredientSuggestions = [];
  List<String> _selectedIngredients = [];
  List<String> _recipes = [];

  @override
  void initState() {
    super.initState();
    _fetchIngredientSuggestions();
  }

  Future<void> _fetchIngredientSuggestions() async {
    List<String> ingredients = await fetchIngredients();
    setState(() {
      _ingredientSuggestions = ingredients;
    });
  }

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
              suggestions: _ingredientSuggestions,
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getRecipes,
              child: const Text('Get Recipes'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 150,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/basket.png'), // Ensure this image exists in your assets
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _selectedIngredients.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedIngredients[index]),
                    GestureDetector(
                      onTap: () => _removeIngredient(index),
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _addIngredient() {
    setState(() {
      if (_ingredientController.text.isNotEmpty && !_selectedIngredients.contains(_ingredientController.text)) {
        _selectedIngredients.add(_ingredientController.text);
        print('Ingredient added: ${_ingredientController.text}'); // Debug print statement
      }
      _ingredientController.clear();
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      print('Ingredient removed: ${_selectedIngredients[index]}'); // Debug print statement
      _selectedIngredients.removeAt(index);
    });
  }

  Future<void> _getRecipes() async {
    final response = await http.post(
      Uri.parse('https://api.yourgeminiapi.com/recipes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, List<String>>{
        'ingredients': _selectedIngredients,
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
