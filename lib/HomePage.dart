import 'package:flutter/material.dart';
import 'package:sqlflite/sql_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //All journals
  List<Map<String, dynamic>> _journals = [];

  bool isLoading = true;

  void _refreshJournals() async {
    // ignore: unused_local_variable
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshJournals();
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void _showFrom(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      titleController.text = existingJournal['title'];
      descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Title',
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(hintText: 'Decoration'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await addItem();
                        }
                        if (id != null) {
                          await updateItem(id);
                        }
                        titleController.text = '';
                        descriptionController.text = '';

                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New ' : 'Update'))
                ],
              ),
            ));
  }

  Future<void> addItem() async {
    await SQLHelper.createItem(
        titleController.text, descriptionController.text);
    _refreshJournals();
  }

  Future<void> updateItem(int id) async {
    await SQLHelper.updateItem(
        id, titleController.text, descriptionController.text);
    _refreshJournals();
  }

  void deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kindacode.com'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                    color: Colors.amber,
                    margin: EdgeInsets.all(15),
                    child: ListTile(
                      title: Text(_journals[index]['title']),
                      subtitle: Text(_journals[index]['description']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () =>
                                    _showFrom(_journals[index]['id']),
                                icon: Icon(Icons.edit)),
                            IconButton(
                                onPressed: () =>
                                    deleteItem(_journals[index]['id']),
                                icon: Icon(Icons.delete))
                          ],
                        ),
                      ),
                    ),
                  )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showFrom(null),
      ),
    );
  }
}
