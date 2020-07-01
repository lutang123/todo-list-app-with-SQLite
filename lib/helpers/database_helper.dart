import 'dart:io';

import 'package:flutter_todo_list/models/task_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  //Named constructor to create instance of DatabaseHelper
  //this is our constructor
  DatabaseHelper._instance();
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;

  String tasksTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  // Task Tables
  // Id | Title | Date | Priority | Status
  // 0     ''      ''      ''         0
  // 2     ''      ''      ''         0
  // 3     ''      ''      ''         0

  //this is a getter for our database variable
  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  //1. Add the dependencies
  //2. Define the Dog data model
  //3. Open the database
  //4. Create the dogs table
  Future<Database> _initDb() async {
    //we create a dir from path_provider method
    Directory dir = await getApplicationDocumentsDirectory();
    //we go to our current path and then make a new file called todo_list.db
    String path = dir.path + '/todo_list.db';
    //openDatabase
    final todoListDb =
        //we use sqflite package function openDatabase
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  void _createDb(Database db, int version) async {
    //we use sqflite package function db.execute(sql)
    await db.execute(
      'CREATE TABLE $tasksTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colStatus INTEGER)',
    );
  }

  // 6. Retrieve the list of Dogs
  //Tis is to get all the rows from sql table and
  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    //// Get a reference to the database.
    //this is Type: DatabaseHelper
    //this.db refers to our db in this class, Future<Database> get db
    Database db = await this.db;

    //// Query the table for all The Dogs
    //result is a list of map
    final List<Map<String, dynamic>> mapsList = await db.query(tasksTable);

    //// Convert the List<Map<String, dynamic> into a List<Dog>.
    //this function returns all the rows in the task table
    //but the return type is Map in a a list
    //we then use the result to make List<Task> taskList
    return mapsList;
  }

  //Task is the class we constructed before, that's the data format in our app,
  //map is the data in sql
  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> taskList = [];
    taskMapList.forEach((taskMap) {
      //Task.fromMap is the constructor we wrote before
      //this is to convert each map to a Task
      taskList.add(Task.fromMap(taskMap));
    });
    taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    //this return type is TASK
    return taskList;
  }

  //5. Insert a Dog into the database
  Future<int> insertTask(Task task) async {
    Database db = await this.db;
    //Future<int> insert(String table, Map<String, dynamic> values)
    final int result = await db.insert(
      tasksTable,
      task.toMap(),
      //// Insert the Dog into the correct table. You might also specify the
      //  // `conflictAlgorithm` to use in case the same dog is inserted twice.
      //  // In this case, replace any previous data.
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final int result = await db.update(
      tasksTable, //table
      task.toMap(), //value, type is map
      where: '$colId = ?', //this is argument
      whereArgs: [task.id],
    );
    //return the updated row
    return result;
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      tasksTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }
}
