import 'package:flutter/material.dart';
import 'package:flutter_project_1/model/todos.dart';

// class AnimatedTodoListItem extends StatefulWidget {
//   final Todo todo;
//   final VoidCallback onDismissed;
//   final VoidCallback onTap;

//   const AnimatedTodoListItem({
//     super.key,
//     required this.todo,
//     required this.onDismissed,
//     required this.onTap,
//   });

//   @override
//   _AnimatedTodoListItemState createState() => _AnimatedTodoListItemState();
// }

// class _AnimatedTodoListItemState extends State<AnimatedTodoListItem>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _animation,
//       child: Dismissible(
//         key: Key(widget.todo.reference.id),
//         background: Container(
//           color: Colors.red,
//           alignment: Alignment.centerRight,
//           child: const Icon(Icons.delete, color: Colors.white),
//         ),
//         onDismissed: (direction) => widget.onDismissed(),
//         child: Card(
//           elevation: 5,
//           margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//           child: ListTile(
//             title: Text(widget.todo.name,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             subtitle: Text(widget.todo.todo,
//                 style: const TextStyle(color: Colors.grey)),
//             trailing: Row(
//               mainAxisSize: MainAxisSize
//                   .min, // This ensures the row only takes up necessary space
//               children: [
//                 Checkbox(
//                   value: widget.todo.isActive,
//                   onChanged: (bool? value) {
//                     if (value != null) {
//                       widget
//                           .onTap(); // Assuming onTap is used to toggle the active state
//                     }
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.more_vert),
//                   onPressed: () => widget.onTap(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class MyTodos extends StatefulWidget {
  const MyTodos({super.key});

  @override
  State<MyTodos> createState() => _MyTodosState();
}

class _MyTodosState extends State<MyTodos> {
  TodoList todoList = TodoList();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _todoController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    todoList.getTodos();
  }

  void _toggle(Todo todo) {
    setState(() {
      todo.isActive = !todo.isActive;
      todoList.toggleActive(todo);
    });
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      itemCount: todoList.todosList.length,
      itemBuilder: (context, index) {
        final todo = todoList.todosList[index];
        return _buildListItem(context, todo);
      },
    );
  }

  Widget _buildBody() {
    return Stack(
      fit: StackFit.expand, // Ensure the stack takes all available space
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.webp'),
              fit: BoxFit.cover, // Cover the entire area of the stack
            ),
          ),
        ),
        StreamBuilder<List<Todo>>(
          stream: todoList.getTodos(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (!snapshot.hasData) return const LinearProgressIndicator();
            return _buildList(context);
          },
        ),
      ],
    );
  }

Widget _buildListItem(BuildContext context, Todo todo) {
  return Dismissible(
    key: Key(todo.reference.id),
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    direction: DismissDirection.endToStart,
    onDismissed: (direction) {
      _deleteTodo(context, todo);
    },
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: ListTile(
        title: Text(
          todo.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          todo.todo,
          style: const TextStyle(color: Colors.grey),
        ),
        leading: Checkbox(
          value: todo.isActive,
          onChanged: (bool? value) {
            if (value != null) {
              _toggle(todo);
            }
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showOptions(context, todo),
        ),
      ),
    ),
  );
}


  Widget _buildInactiveTodoList(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: todoList.getInactiveTodos(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData) return const LinearProgressIndicator();

        var inactiveTodos = snapshot.data;
        return ListView.builder(
          itemCount: inactiveTodos!.length,
          itemBuilder: (context, index) {
            var todo = inactiveTodos[index];
            return CheckboxListTile(
              title: Text(todo.name),
              subtitle: Text(todo.todo),
              value: todo
                  .isActive, // Since these are inactive, the checkbox should reflect that
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    todo.isActive = !todo.isActive; // Toggle active state
                    todoList
                        .toggleActive(todo); // Update in the backend/data list
                  });
                }
              },
              secondary: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteTodo(context, todo),
              ),
            );
          },
        );
      },
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading:
                false, // Don't show a back button inside the drawer
            title: const Text('Inactive Todos'),
            backgroundColor: Theme.of(context)
                .primaryColor, // Ensures the AppBar uses the primary theme color
          ),
          Expanded(
            child: _buildInactiveTodoList(
                context), // This builds the list of inactive todos
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TODO List',
        home: Scaffold(
          appBar: AppBar(
            leading: Builder(builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            }),
          ),
          body: _buildBody(),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
          drawer: buildDrawer(context),
        ));
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Todo'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter your name',
                      ),
                    ),
                    TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(
                        labelText: 'Todo',
                        hintText: 'Enter your todo',
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Is Active'),
                      value: _isActive,
                      onChanged: (bool value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    final String name = _nameController.text;
                    final String todo = _todoController.text;
                    todoList.addTodo(name, todo, _isActive);
                    Navigator.of(context).pop();
                    // Clear the inputs after use
                    _nameController.clear();
                    _todoController.clear();
                    _isActive = true; // Reset the toggle state
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showOptions(BuildContext context, Todo todo) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context, todo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTodo(context, todo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteTodo(BuildContext context, Todo todo) {
    setState(() {
      todoList.removeTodo(todo);
    });
  }

  void _showEditDialog(BuildContext context, Todo todo) {
    TextEditingController nameController =
        TextEditingController(text: todo.name);
    TextEditingController todoController =
        TextEditingController(text: todo.todo);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: todoController,
                decoration: const InputDecoration(labelText: 'Todo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                todoList.updateName(todo, nameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
