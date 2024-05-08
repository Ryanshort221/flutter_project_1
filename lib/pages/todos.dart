import 'package:flutter/material.dart';
import 'package:flutter_project_1/model/todos.dart';

class MyTodos extends StatefulWidget {
  const MyTodos({super.key});

  @override
  State<MyTodos> createState() => _MyTodosState();
}

class _MyTodosState extends State<MyTodos> {
  TodoList todoList = TodoList(); // Create an instance of TodoList

  @override
  void initState() {
    super.initState();
    todoList
        .getTodos(); // Fetch the active todos when the widget is initialized
  }

  void _toggle(Todo todo) {
    todo.isActive = !todo.isActive;
    setState(() {}); // Trigger rebuild
    todoList.toggleActive(todo); // This should handle Firestore update
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      itemCount: todoList.todosList.length,
      itemBuilder: (context, index) {
        return _buildListItem(context, todoList.todosList[index]);
      },
    );
  }

  Widget _buildBody() {
    return StreamBuilder<List<Todo>>(
      stream: todoList.getTodos(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData) return const LinearProgressIndicator();
        return _buildList(context); // Ensure this is being called
      },
    );
  }

  Widget _buildListItem(BuildContext context, Todo todo) {
    return ListTile(
      title: Text(todo.name),
      subtitle: Text(todo.todo),
      trailing: Checkbox(
        value: !todo.isActive,
        onChanged: (bool? value) {
          setState(() {
            _toggle(todo);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TODO List',
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: _buildBody(),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ));
  }

  void _showAddDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController todoController = TextEditingController();
    final TextEditingController isActiveController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add TODO'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Enter your name'),
              ),
              TextField(
                controller: todoController,
                decoration: const InputDecoration(hintText: 'Enter your TODO'),
              ),
              // checkbox with text complete or incomplete complete isActive = true incomplete isActive = false
              TextField(
                controller: isActiveController,
                decoration: const InputDecoration(hintText: 'Enter your TODO'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                todoList.addTodo(nameController.text, todoController.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
