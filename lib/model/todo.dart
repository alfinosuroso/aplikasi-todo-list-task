class Todo {
  final String uid;
  final String title;
  final String description;
  final bool completed;

  Todo({
    required this.uid,
    required this.title,
    required this.description,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'title': title,
      'description': description,
      'completed': completed,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      uid: map['uid'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      completed: map['completed'] == 0 ? false : true,
    );
  }
}
