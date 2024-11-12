// ignore_for_file: use_build_context_synchronously

import 'package:aplikasi_todo/database_helper.dart';
import 'package:aplikasi_todo/todo.dart';
import 'package:flutter/material.dart';
import 'styles.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final dbHelper = DatabaseHelper();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Todo> _todos = [];

  @override
  void initState() {
    refreshItemList();
    super.initState();
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  void refreshItemList() async {
    final todos = await dbHelper.getAllTodos();
    setState(() {
      _todos = todos;
    });
  }

  void searchItems() async {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      final todos = await dbHelper.getTodoByTitle(keyword);
      setState(() {
        _todos = todos;
      });
    } else {
      refreshItemList();
    }
  }

  void addItem(String title, String desc) async {
    final todo = Todo(title: title, description: desc, completed: false);
    await dbHelper.insertTodo(todo);
    refreshItemList();
    showSuccess(context, "Task added successfully!");
  }

  void updateItem(Todo todo, bool completed,
      {bool updatedComplete = false}) async {
    final item = Todo(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      completed: completed,
    );
    await dbHelper.updateTodo(item);
    refreshItemList();
    if (!updatedComplete) showSuccess(context, "Task updated successfully!");
  }

  void deleteItem(int id) async {
    await dbHelper.deleteTodo(id);
    refreshItemList();
    showSuccess(context, "Task deleted successfully!",
        bgColor: Colors.orange[600]);
  }

  void deleteAllItem() async {
    await dbHelper.deleteAllTodo();
    refreshItemList();
    showSuccess(context, "All completed tasks deleted!",
        bgColor: Colors.orange[600]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo List Task',
          style: Styles.title1,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: showBody(context),
      floatingActionButton: showFab(context),
    );
  }

  Padding showFab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0, right: 20),
      child: FloatingActionButton(
        onPressed: () {
          showModal(context);
        },
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }

  Future<dynamic> showModal(BuildContext context, {Todo? existingTodo}) {
    if (existingTodo != null) {
      // Pre-fill the controllers with the existing todo data
      _titleController.text = existingTodo.title;
      _descController.text = existingTodo.description;
    } else {
      // Clear controllers for a new task
      _titleController.clear();
      _descController.clear();
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Wrap(
            children: [
              Center(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      width: 100,
                      height: 5,
                      color: Colors.grey[400],
                    )),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  existingTodo == null ? 'Add Task' : 'Edit Task',
                  style: Styles.headerBold3,
                ),
              ),
              const SizedBox(height: 50),
              ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: double.infinity,
                    height: 2,
                    color: Colors.grey[400],
                  )),
              const SizedBox(height: 32),
              const Text(
                "Title Task",
                style: Styles.headerBold2,
              ),
              const SizedBox(height: 40),
              outlineTextField(_titleController, 'Add Task Name...'),
              const SizedBox(height: 80),
              const Text(
                "Description",
                style: Styles.headerBold2,
              ),
              const SizedBox(height: 40),
              outlineTextField(_descController, 'Add Descriptions...'),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: outlineButton(context, 'Cancel'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: solidButton(
                        context,
                        existingTodo == null ? 'Create' : 'Update',
                        Theme.of(context).colorScheme.primary, () {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (existingTodo == null) {
                          // Add new task
                          addItem(_titleController.text, _descController.text);
                        } else {
                          // Update existing task
                          final updatedTodo = Todo(
                            id: existingTodo.id,
                            title: _titleController.text,
                            description: _descController.text,
                            completed: existingTodo.completed,
                          );
                          updateItem(updatedTodo, updatedTodo.completed);
                        }
                        _titleController.clear();
                        _descController.clear();
                        Navigator.pop(context);
                      }
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton outlineButton(BuildContext context, String? text) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16.0), // Add padding here
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      child: Text(
        text ?? "",
        style: Styles.medium,
      ),
    );
  }

  ElevatedButton solidButton(BuildContext context, String text, Color? bgColor,
      Function()? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: bgColor),
      child: Text(
        text,
        style: Styles.mediumWhite,
      ),
    );
  }

  Stack showBody(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            searchTextField(),
            expandedTodoList(),
          ],
        ),
        if (_todos.any((todo) => todo.completed))
          Positioned(
            bottom: 50, // Adjust this value to control how far from the bottom
            left: 0,
            right: 0,
            child: Center(
              child: solidButton(
                context,
                'Delete All Completed',
                Colors.red[400],
                () {
                  confirmDeleteAllCompleted();
                },
              ),
            ),
          ),
      ],
    );
  }

  Expanded expandedTodoList() {
    return Expanded(
      child: _todos.isEmpty
          ? Center(
              child: Text(
              _searchController.text.isNotEmpty
                  ? "Can't find task"
                  : "There are no tasks available",
              style: Styles.medium,
            ))
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                var todo = _todos[index];
                return ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15.0)),
                      border: Border.all(color: Colors.grey, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 75,
                          width: 15,
                          decoration: BoxDecoration(
                            color: todo.completed
                                ? Colors.green[400]
                                : Colors.red[300], // Dynamic color
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 0.0),
                            visualDensity:
                                const VisualDensity(horizontal: 0, vertical: 0),
                            leading: todo.completed
                                ? IconButton(
                                    icon: Icon(
                                      Icons.check_circle,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      updateItem(todo, !todo.completed,
                                          updatedComplete: true);
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(
                                        Icons.radio_button_unchecked),
                                    onPressed: () {
                                      updateItem(todo, !todo.completed,
                                          updatedComplete: true);
                                    },
                                  ),
                            title: Text(
                              todo.title,
                              style: todo.completed
                                  ? Styles.headerBoldCross1
                                  : Styles.headerBold1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              todo.description,
                              style: todo.completed
                                  ? Styles.subtitleCross1
                                  : Styles.subtitle1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.green[800],
                                  ),
                                  onPressed: () {
                                    showModal(context, existingTodo: todo);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red[600],
                                  ),
                                  onPressed: () {
                                    deleteItem(todo.id!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Padding searchTextField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search Task..',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
            borderSide:
                const BorderSide(color: Colors.grey), // No border outline
          ),
        ),
        onChanged: (_) {
          searchItems();
        },
      ),
    );
  }

  TextFormField outlineTextField(
      TextEditingController controller, String? hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        fillColor: Colors.grey[300],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Can't be empty";
        }
        return null;
      },
    );
  }

  void showSuccess(BuildContext context, String text, {Color? bgColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: bgColor ?? Colors.green,
      ),
    );
  }

  void confirmDeleteAllCompleted() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Confirm Deletion",
            style: Styles.headerBold3,
          ),
          content: const Text(
            "Are you sure you want to delete all completed tasks?",
            style: Styles.subtitle2,
          ),
          actions: [
            outlineButton(context, 'Cancel'),
            solidButton(
              context,
              'Confirm',
              Colors.red[400],
              () {
                deleteAllItem(); // Perform the deletion
                Navigator.of(context).pop(); // Close the dialog
                showSuccess(context, 'All Data Completed has been Deleted',
                    bgColor: Colors.green[400]);
              },
            ),
          ],
        );
      },
    );
  }
}
