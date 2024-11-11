import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_event.dart';
import 'task_state.dart';
import 'package:dacn2/models/task_model.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TaskBloc() : super(TaskInitial()) {
    on<AddTaskEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        await _addTask(event);
        emit(TaskAdded());
      } catch (e) {
        emit(TaskError('Failed to add task: $e'));
      }
    });
    on<UpdateTaskEvent>(_onUpdateTask); 
    on<DeleteTaskEvent>(_onDeleteTask);
    on<FetchTasksEvent>(_onFetchTasks);
    on<ToggleTaskCompletionEvent>(_onToggleTaskCompletion);
  }

  // Thêm task mới vào Firestore
  Future<void> _addTask(AddTaskEvent event) async {
    await _firestore.collection('tasks').add({
      'name': event.name,
      'description': event.description,
      'priority': event.priority,
      'status': event.status,
      'deadline': Timestamp.fromMillisecondsSinceEpoch(DateTime.parse(event.deadline).millisecondsSinceEpoch),
    });
  }

  // Cập nhật task đã chọn
  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await _firestore.collection('tasks').doc(event.taskId).update(event.updatedTask.toMap());
      emit(TaskLoaded(await _fetchTasks()));  // Lấy lại danh sách task sau khi cập nhật
    } catch (e) {
      emit(TaskError('Failed to update task: $e'));
    }
  }

  // Xóa task
  // Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
  //   emit(TaskLoading());
  //   try {
  //     await _firestore.collection('tasks').doc(event.id).delete();
  //     emit(TaskLoaded(await _fetchTasks()));
  //   } catch (e) {
  //     emit(TaskError('Failed to delete task: $e'));
  //   }
  // }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await _firestore.collection('tasks').doc(event.id).delete();
      final tasks = await _fetchTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Failed to delete task: $e'));
    }
  }

  // Lấy danh sách task từ Firestore
  Future<List<Task>> _fetchTasks() async {
    final snapshot = await _firestore.collection('tasks').get();
    return snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList();
  }

  // Xử lý sự kiện lấy danh sách task
  Future<void> _onFetchTasks(FetchTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await _fetchTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      print('Error fetching tasks: $e'); // Log lỗi ra console
      emit(TaskError('Failed to fetch tasks: $e')); // Cập nhật thông báo lỗi
    }
  }

  // Chuyển đổi trạng thái hoàn thành của task
  Future<void> _onToggleTaskCompletion(ToggleTaskCompletionEvent event, Emitter<TaskState> emit) async {
    try {
      await _firestore.collection('tasks').doc(event.taskId).update({
        'status': event.isCompleted ? 'Đã hoàn thành' : 'Chưa hoàn thành',
      });
      add(FetchTasksEvent()); // Tải lại danh sách sau khi cập nhật
    } catch (e) {
      emit(TaskError('Failed to update task completion status: $e'));
    }
  }
}
