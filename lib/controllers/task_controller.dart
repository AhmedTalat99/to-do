import 'package:get/get.dart';
import 'package:to_do/db/db_helper.dart';
import '../models/task.dart';

class TaskController extends GetxController {
 final RxList<Task> taskList = <Task>[].obs;


Future<int> addTask({Task? task}){
return DBHelper.insert(task);
  }

 // func to get data from database
 Future<void> getTasks() async{ // i made this type Future<void> ;because i didn't make taskLis await
  final List<Map<String,dynamic>> tasks = await DBHelper.query();
  taskList.assignAll(tasks.map((data) => Task.fromJson(data)));
  }

  // func to delete  data from database
  void deleteTasks(Task task)async{
    await DBHelper.delete(task);
    getTasks();
  }
  // func to delete   the entire table
  void deleteAllTasks()async{
    await DBHelper.deleteAll();
    getTasks();
  }

  // func to update data
  void markTaskCompleted(int id)async{
  await DBHelper.update(id);
  getTasks();
  }
}
