import 'package:flutter/material.dart';
import 'package:flutter_todo_list/helpers/database_helper.dart';
import 'package:flutter_todo_list/models/task_model.dart';
import 'package:flutter_todo_list/screens/add_task_screen.dart';
import 'package:intl/intl.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    //because this function returns a future, we need to wrap our ViewList to a FutureBuilder
    _updateTaskList();
  }

  void _updateTaskList() {
    setState(() {
      //getTaskList() is from database_helper.dart, it returns Future<List<Task>>
      //DatabaseHelper.instance to call the method
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      //maybe use a Card is better
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 18.0,
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text(
              '${_dateFormatter.format(task.date)} • ${task.priority}',
              style: TextStyle(
                fontSize: 15.0,
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            trailing: Checkbox(
              onChanged: (value) {
                //when click, value became true and we assign it to status
                task.status = value ? 1 : 0; //if value is true, status is 1
                //not using setState but each task has an status, and when
                //click, we update the task by id, because it's status changed
                DatabaseHelper.instance.updateTask(task);
                //we also need to update the task list, this function has
                // setState()
                _updateTaskList();
              },
              activeColor: Theme.of(context).primaryColor,
              //this value is true now
              value: task.status == 1 ? true : false,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTaskScreen(
                  //pass data to AddTaskScreen
                  updateTaskList: _updateTaskList, //pass function name only
                  task: task,
                ),
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        //Future<List<Task>> _taskList;
        //_taskList = DatabaseHelper.instance.getTaskList();
        future: _taskList,
        builder: (context, snapshot) {
          //if not data
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          //this is to find all the task where status equals to 1 and
          // changes it to a list and then takes teh length
          final int completedTaskCount = snapshot.data
              .where((Task task) => task.status == 1)
              .toList()
              .length;
//There are four options for constructing a ListView:
//
//The default constructor takes an explicit List<Widget> of children. This constructor is appropriate for list views with a small number of children because constructing the List requires doing work for every child that could possibly be displayed in the list view instead of just those children that are actually visible.
//
//The ListView.builder constructor takes an IndexedWidgetBuilder, which builds the children on demand. This constructor is appropriate for list views with a large (or infinite) number of children because the builder is called only for those children that are actually visible.
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 80.0),
            //snapshot.data is a list of task
            itemCount: 1 + snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'My Tasks',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        '$completedTaskCount of ${snapshot.data.length}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              //itemCount: 1 + snapshot.data.length
              //itemBuilder: (BuildContext context, int index)
              //Widget _buildTask(Task task)
              return _buildTask(snapshot.data[index - 1]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTaskScreen(
              updateTaskList: _updateTaskList, //pass the function name only
            ),
          ),
        ),
      ),
    );
  }
}
