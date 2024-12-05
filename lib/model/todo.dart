class Todo {
  final int? id;
  final String title;
  final String description;
  final bool completed;

  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      completed: map['completed'] == 0 ? false : true,
    );
  }
}
