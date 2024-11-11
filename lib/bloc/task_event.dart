import 'package:dacn2/models/task_model.dart';


abstract class TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final String name;
  final String description;
  final String priority;
  final String status;
  final String deadline;
  

  AddTaskEvent({
    required this.name,
    required this.description,
    required this.priority,
    required this.status,
    required this.deadline,
  });
}

class UpdateTaskEvent extends TaskEvent {
  final String taskId;
  final Task updatedTask;

  UpdateTaskEvent({required this.taskId, required this.updatedTask});
}

class DeleteTaskEvent extends TaskEvent {
  final String id;
  DeleteTaskEvent(this.id);
}

class ToggleTaskCompletionEvent extends TaskEvent {
  final String taskId;
  final bool isCompleted;

  ToggleTaskCompletionEvent({required this.taskId, required this.isCompleted});
}

class FetchTasksEvent extends TaskEvent {}