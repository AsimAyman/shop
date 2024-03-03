import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/categories.dart';
import 'package:shop/model/category.dart';
import 'package:shop/model/grocery_item.dart';
import 'package:shop/ui/screen/new_item.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  List<GroceryItem> items = [];
  bool isLoaded = false;
  String? _error;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Category'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: _error != null
          ? Center(
              child: Text(_error!),
            )
          : isLoaded == false
              ? Center(child: const CircularProgressIndicator())
              : items.isEmpty
                  ? const Center(
                      child: Text("You did  not add any Items yet"),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) => Dismissible(
                        key: ValueKey(items[index].id),
                        onDismissed: (_) {
                          _deleteItem(items[index]);
                        },
                        child: ListTile(
                          title: Text(items[index].name),
                          leading: Container(
                            height: 24,
                            width: 24,
                            color: items[index].category.color,
                          ),
                          trailing: Text(
                            items[index].quantity.toString(),
                          ),
                        ),
                      ),
                    ),
    );
  }

  _deleteItem(GroceryItem item) {
    var index = items.indexOf(item);
    setState(() {
      items.remove(item);
    });
    var uri = Uri.https('flutter-shop-test-36581-default-rtdb.firebaseio.com',
        'list/${item.id}.json');
    http.delete(uri).then((value) {
      if (value.statusCode >= 400) {
        setState(() {
          items.insert(index, item);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('we failed to remove this it'),
          ));
        });
      }
    });
  }

  _getData() async {
    log('111111111111111');
    var uri = Uri.https(
        'dflutter-shop-test-36581-default-rtdb.firebaseio.com', 'list.json');
    http.Response res = await http.get(uri);
    if (res.statusCode >= 400) {
      setState(() {
        _error =
            "there is an error happened while getting data, please load later";
      });

      return;
    }

    log('222222222222');
    Map data = jsonDecode(res.body);
    List<GroceryItem> loadedData = [];
    for (var i in data.entries) {
      Category category = categories.entries
          .firstWhere((element) => element.value.title == i.value['category'])
          .value;
      loadedData.add(GroceryItem(
          id: i.key,
          name: i.value['name'],
          quantity: i.value['quantity'],
          category: category));
    }
    setState(() {
      items = loadedData;
      isLoaded = true;
    });
  }

  _addItem() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => NewItem()))
        .then((value) {
      setState(() {
        print(value.toString());
        items.add(value);
      });
      //_getData()
    });
  }
}
