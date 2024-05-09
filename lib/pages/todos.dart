import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project_1/model/todos.dart';

// TODO add priority to the edit todo list
// TODO update the edit/add form to look better maybe make them bigger and come from bottom and take up half the screen

class MyTodos extends StatefulWidget {
  const MyTodos({super.key});

  @override
  State<MyTodos> createState() => _MyTodosState();
}

class _MyTodosState extends State<MyTodos> {
  TodoList todoList = TodoList();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
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
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background3.webp'),
              fit: BoxFit.cover,
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
            '${todo.name} - ${DateFormat('MM/dd').format(todo.date)} - ${DateFormat('hh:mm a').format(todo.date)}',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                      '${todo.name} - ${DateFormat('MM/dd').format(todo.date)}',
                      style: const TextStyle(
                        color: Colors.black,
                      )),
                  content: Text(
                    todo.todo,
                    style: const TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          subtitle: Text(
            todo.todo,
            style: const TextStyle(color: Colors.grey),
          ),
          leading: Checkbox(
            activeColor: todo.priority == 'High'
                ? Colors.red
                : todo.priority == 'Medium'
                    ? Colors.orange
                    : Colors.green,
            value: todo.isActive,
            shape: const CircleBorder(),
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
            return Card(
              color: Colors.grey[100],
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: ListTile(
                title: Text(
                  '${todo.name} - ${DateFormat('MM/dd').format(todo.date)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  todo.todo,
                  style: const TextStyle(
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                leading: Checkbox(
                  activeColor: Colors.black,
                  value: todo.isActive,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: 2,
                          color: todo.priority == 'High'
                              ? Colors.red
                              : todo.priority == 'Medium'
                                  ? Colors.orange
                                  : Colors.green)),
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
            );
          },
        );
      },
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background4.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              AppBar(
                automaticallyImplyLeading: false,
                title: const Text('Inactive Todos',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w400)),
                backgroundColor: Colors.black,
              ),
              Expanded(
                child: _buildInactiveTodoList(context),
              ),
              StreamBuilder<List<Todo>>(
                stream: todoList.getInactiveTodos(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ElevatedButton(
                      child: const Text('Clear All Inactive Todos'),
                      onPressed: () {
                        todoList.deleteAllInactiveTodos();
                      },
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.all(20),
                      child: const Text('No inactive todos',
                          style:
                              TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400)),
                    );
                  }
                },
              ),
            ],
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
            backgroundColor: Colors.black,
            title: const Text('TODO List',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Cursive')),
            leading: Builder(builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
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
    String priority = 'Low';
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
                    TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000, 1, 1),
                          lastDate: DateTime(2100, 12, 31),
                        );

                        if (selectedDate != null) {
                          final TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (selectedTime != null) {
                            final DateTime selectedDateTimeUtc = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            ).toUtc();

                            final DateFormat formatter =
                                DateFormat('yyyy-MM-dd HH:mm');
                            final String formatted =
                                formatter.format(selectedDateTimeUtc);

                            setState(() {
                              _dateController.text = formatted;
                            });
                          }
                        }
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Priority'),
                        DropdownButton<String>(
                          value: priority,
                          items: <String>['Low', 'Medium', 'High']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              priority = newValue!;
                            });
                          },
                        ),
                      ],
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
                    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
                    final DateTime selectedDateTime =
                        formatter.parse(_dateController.text);
                    todoList.addTodo(
                        name, todo, _isActive, selectedDateTime, priority);
                    Navigator.of(context).pop();
                    _nameController.clear();
                    _todoController.clear();
                    _dateController.clear();
                    _isActive = true;
                  },
                )
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

  Future<void> _deleteTodo(BuildContext context, Todo todo) async {
    await todoList.removeTodo(todo);
    setState(() {});
  }

  void _showEditDialog(BuildContext context, Todo todo) {
    TextEditingController nameController =
        TextEditingController(text: todo.name);
    TextEditingController todoController =
        TextEditingController(text: todo.todo);
    TextEditingController dateController =
        TextEditingController(text: DateFormat('yyyy-MM-dd').format(todo.date));
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
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                ),
                readOnly: true, // make it read-only
                onTap: () async {
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000, 1, 1),
                    lastDate: DateTime(2100, 12, 31),
                  );

                  if (selectedDate != null) {
                    final TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selectedTime != null) {
                      final DateTime selectedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      final DateFormat formatter =
                          DateFormat('yyyy-MM-dd HH:mm');
                      final String formatted =
                          formatter.format(selectedDateTime);

                      setState(() {
                        _dateController.text = formatted;
                      });
                    }
                  }
                },
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
                todoList.updateTodo(
                  todo,
                  nameController.text,
                  todoController.text, // Pass the new todo text
                  DateFormat('yyyy-MM-dd').parse(dateController.text),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


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