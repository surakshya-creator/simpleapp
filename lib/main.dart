import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TO-Do List',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(appBar: AppBar(title:Text('To-Do List'),
      
      ),
      body: Container(
        color: Colors.pink[100],
        child: TodoListScreen(),
        ),
      ),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  //const TodoListScreen({super.key, required this.title});
_TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State <TodoListScreen> {
  List<TodoItem> todos = [];
List<TodoItem> filteredTodos = [];
TextEditingController _textEditingController =TextEditingController();
TextEditingController _editTextEditingController =TextEditingController();
int _selectedIndex = -1;
bool _showCompleted = true;

  @override
  void initState(){
    super.initState();
    filteredTodos =todos;
  }
  
  void addTodo(){
    setState(() {
      String newTodo =_textEditingController.text;
      if(newTodo.isNotEmpty){
        todos.add(
          TodoItem(
            title:newTodo,
            dateTime:DateTime.now(),

          ),
          );
          _textEditingController.clear();
          filterTasks();
      }
    });
  }
  void removeTodo(){
    setState(() {
      todos.removeAt(_selectedIndex);
      _selectedIndex =-1;
      filterTasks();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task removed'),
        action:SnackBarAction(label: 'UNDO',
        onPressed:  () {
          setState(() {
            todos.insert(_selectedIndex, todos[_selectedIndex]);
            filterTasks();
          });
        },
        ),
    ),
    );
  }
  void updateTodo(){
    setState(() {
      todos[_selectedIndex].title =_editTextEditingController.text;
      _editTextEditingController.clear();
      _selectedIndex =-1;
      filterTasks();
    });
  }
  void toggleCompleted(int index) {
    setState(() {
      todos[index].completed =!todos[index].completed;
      filterTasks();
    });
  }
  void filterTasks() {
    setState(() {
      filteredTodos =todos.where((todo) {
        if (_showCompleted){
          return true;
        }else{
          return !todo.completed;
        }
      }).toList();
    });
  }

  void clearcompleted() {
    setState(() {
      todos.removeWhere((todo) => todo.completed);
      filterTasks();
    });
  }
  String formatDateTime(DateTime dateTime){
    return DateFormat.yMd().add_jm().format(dateTime);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.pink[200],
          padding:const EdgeInsets.all(8.0),
          child:Row(
            children:[
              Expanded(child: TextField(controller:_textEditingController,
              decoration:InputDecoration(
                labelText:'Add a new Task',
               ),
                ),
                ),
                ElevatedButton(onPressed: addTodo,
                 child: Text('add'),
                 ),
            ],
          ),
        ),
        Container(
          color:Colors.pink[200],
          padding: const EdgeInsets.symmetric(vertical:8.0,horizontal:16.0),
          child:Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children:[
              Text('Show Completed'),
              Switch(
                value: _showCompleted,
              onChanged: (value){
                setState(() {
                  _showCompleted =value;
                  filterTasks();
                });
              },
              ),
              ElevatedButton(onPressed: clearcompleted,
                 child: Text('Clear Completed'),
                 ),
            ],
          ),
        ),
        Expanded(child: Container(decoration:BoxDecoration(color:Colors.white,
        borderRadius: BorderRadius.only(topLeft:Radius.circular(24.0),
        topRight: Radius.circular(24.0),
         ),
        ),
        child:ListView.builder(
          itemCount: filteredTodos.length,
          itemBuilder: (context, index) {
            return ListTile(title:Text(
              filteredTodos[index].title,
              style:TextStyle(decoration:filteredTodos[index].completed 
              ?TextDecoration.lineThrough
              :TextDecoration.none,
              ),
            ),
            subtitle:Text(formatDateTime(filteredTodos[index].dateTime)),
            onTap: (){
              setState(() {
                _selectedIndex =todos.indexOf(filteredTodos[index]);
                _editTextEditingController.text =filteredTodos[index].title;

              });
              showDialog(
                context: context, builder: (context) => AlertDialog(
                title:Text('Modify Task'),
                content: TextField(
                controller:_editTextEditingController,
                decoration: InputDecoration(
                  labelText:'Task',
                ),
              ),
              actions: [
                ElevatedButton(onPressed: (){
                  updateTodo();
                  Navigator.pop(context);
                },
                 child: Text('Update'),
                 ),
                 ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                 }, child: Text('Cancel'),
                 ),
              ],
              ),
              );
            },
            trailing: IconButton(icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _selectedIndex =todos.indexOf(filteredTodos[index]);
              });
              showDialog(context: context, builder: (context) => AlertDialog(
                title:Text('Delete Task'),
                content:Text('Are you sure you want to delete this task?'),
                actions: [
                  ElevatedButton(onPressed: () {
                    removeTodo();
                    Navigator.pop(context);
                  },
                   child: Text('Delete'),
                   ),
                   ElevatedButton(onPressed: () {
                     Navigator.pop(context);
                   },
                    child: Text('Cancel'),
                    ),
                ],
              ),
              );
            },
            ),
            leading: Checkbox(
              value:filteredTodos[index].completed,
              onChanged: (value){
                toggleCompleted(todos.indexOf(filteredTodos[index]));

              },
             ),
            );
          },
        
        ),
        ),
        ),
      ],
    );
  }
  }
  class TodoItem {
    String title;
    bool completed;
    DateTime dateTime;
    TodoItem(
      {required this.title,this.completed =false, required this.dateTime}
    );
  }