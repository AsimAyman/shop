import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/categories.dart';
import 'package:shop/model/category.dart';

import '../../model/grocery_item.dart';

class NewItem extends StatefulWidget {
  NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();

  String _enteredName = '';

  int _enteredCount = 0;

  Category _selectedCategory = categories.entries.toList()[0].value;

  bool isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: "name",
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Not valid, must be between 2 and 50 characters';
                  }
                  return null;
                },
                onSaved: (nwVal) {
                  _enteredName = nwVal!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: '1',
                      decoration: const InputDecoration(
                        labelText: "count",
                      ),
                      validator: (value) {
                        if (value == null ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Not Valid, must be a number greater than 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      onChanged: (value) {
                        _selectedCategory = value!;
                      },
                      items: [
                        for (var category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 21,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isLoaded == true
                        ? () {}
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoaded == true
                        ? () {}
                        : () async {
                            _formKey.currentState!.validate();
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              var url = Uri.https(
                                  'flutter-shop-test-36581-default-rtdb.firebaseio.com',
                                  'list.json');
                              var res = await http.post(url,
                                  body: json.encode({
                                    'id': DateTime.now().toString(),
                                    'name': _enteredName,
                                    'quantity': _enteredCount,
                                    'category': _selectedCategory.title,
                                  }));
                              if (res.statusCode == 200) {
                                setState(() {
                                  isLoaded = true;
                                });
                                 Future.delayed(Duration(seconds: 1), () {
                                  var resp = jsonDecode(res.body);
                                  Navigator.of(context).pop(
                                    GroceryItem(
                                        id: resp['name'],
                                        category: _selectedCategory,
                                        quantity: _enteredCount,
                                        name: _enteredName),
                                  );
                                });
                              }
                            }
                          },
                    child: isLoaded == true
                        ? SizedBox(child: CircularProgressIndicator())
                        : Text('Add Item'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
