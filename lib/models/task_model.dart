class Task {
  int id;
  String title;
  DateTime date;
  String priority;
  int status; // 0 - Incomplete, 1 - Complete

  Task({this.title, this.date, this.priority, this.status});
  //this is a named constructor
  Task.withId({this.id, this.title, this.date, this.priority, this.status});

  //when we store our task object into sql database, we have to convert our task to a map
  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    //we then need to assign the keys of the map to the corresponding values
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    //we can not store DataTime in sql, so we have to convert to Iso
    map['date'] = date.toIso8601String();
    map['priority'] = priority;
    map['status'] = status;
    return map;
  }

  //when we grab the task from database we have to write a function to convert the map back into a task object
  //factory function allow you to return objects and constructors
  //so we take map and return Task.withId
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(
      id: map['id'],
      title: map['title'],
      //parse map to object
      date: DateTime.parse(map['date']),
      priority: map['priority'],
      status: map['status'],
    );
  }
}
