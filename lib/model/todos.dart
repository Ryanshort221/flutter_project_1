import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String name;
  final String todo;
  final DocumentReference reference;
  bool isActive;

  Todo.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot['name'],
        todo = snapshot['todo'],
        reference = snapshot.reference,
        isActive = snapshot['isActive'];
}

class TodoList {
  final CollectionReference todos =
      FirebaseFirestore.instance.collection('todos');
  final List<Todo> _todos = [];

  List<Todo> get todosList => _todos;

  Future<void> addTodo(String name, String todo) async {
    await todos.add({'name': name, 'todo': todo, 'isActive': true});
  }

  Future<void> removeTodo(Todo todo) async {
    await todo.reference.delete();
  }

  Stream<List<Todo>> getTodos() {
    return todos.where('isActive', isEqualTo: true).snapshots().map((snapshot) {
      _todos.clear(); // Clear existing todos
      var fetchedTodos =
          snapshot.docs.map((doc) => Todo.fromSnapshot(doc)).toList();
      _todos.addAll(fetchedTodos); // Update todos list
      return fetchedTodos;
    });
  }

  Future<void> toggleActive(Todo todo) async {
    await todo.reference
        .update({'isActive': todo.isActive}).catchError((error) {});
  }

  List<Todo> get inactiveTodos =>
      _todos.where((todo) => !todo.isActive).toList();

  Future<void> updateName(Todo todo, String name) async {
    await todo.reference.update({'name': name});
  }
}
