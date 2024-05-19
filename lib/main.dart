import 'package:flutter/material.dart';
import 'api_service.dart';
import 'item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Itens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ItemScreen(),
    );
  }
}

class ItemScreen extends StatefulWidget {
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  TextEditingController _controller = TextEditingController();
  List<Item> _items = [];
  int? _editIndex;
  final ApiService apiService = ApiService(baseUrl: 'https://app-uniara-eb91fc9ec7bf.herokuapp.com/api/v1');

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      final items = await apiService.fetchItems();
      setState(() {
        _items = items;
      });
    } catch (e) {
      // Handle API errors
      print(e);
    }
  }

  Future<void> _addItem() async {
    try {
      if (_controller.text.isNotEmpty) {
        if (_editIndex == null) {
          final newItem = await apiService.createItem(_controller.text);
          setState(() {
            _items.add(newItem);
          });
        } else {
          final item = _items[_editIndex!];
          await apiService.updateItem(item.id, _controller.text);
          setState(() {
            item.name = _controller.text;
            _editIndex = null;
          });
        }
        _controller.clear();
      }
    } catch (e) {
      // Handle API errors
      print(e);
    }
  }

  void _editItem(int index) {
    setState(() {
      _controller.text = _items[index].name;
      _editIndex = index;
    });
  }

  Future<void> _deleteItem(int index) async {
    try {
      final item = _items[index];
      await apiService.deleteItem(item.id);
      setState(() {
        _items.removeAt(index);
      });
    } catch (e) {
      // Handle API errors
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Itens'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: _editIndex == null ? 'Novo Item' : 'Editar Item',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => _controller.clear(),
                    ),
                  ),
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              ElevatedButton(
                onPressed: _addItem,
                child: Text(_editIndex == null ? 'Adicionar' : 'Salvar'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: _items.map((item) {
                          return DataRow(cells: [
                            DataCell(Text(item.id.toString())),
                            DataCell(Text(item.name)),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editItem(_items.indexOf(item)),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteItem(_items.indexOf(item)),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
