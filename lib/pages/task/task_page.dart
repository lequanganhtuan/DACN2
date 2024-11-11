import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../bloc/task_bloc.dart';
import '../../bloc/task_state.dart';
import '../../bloc/task_event.dart';
import 'add_task_page.dart';
import '../../models/task_model.dart'; 
import 'package:flutter_slidable/flutter_slidable.dart';

class TaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<TaskBloc>(context).add(FetchTasksEvent());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:const Text(
          'Danh Sách Công Việc',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          color: Colors.white,
          onPressed: () {
            print('Nút menu được nhấn');
          },
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTaskPage()),
              ).then((_) {
                BlocProvider.of<TaskBloc>(context).add(FetchTasksEvent());
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
        if (state is TaskLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded) {
          final incompleteTasks = state.tasks.where((task) => task.status != 'Đã hoàn thành').toList();
          final completedTasks = state.tasks.where((task) => task.status == 'Đã hoàn thành').toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chưa Hoàn Thành",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: incompleteTasks.length,
                    itemBuilder: (context, index) {
                      final task = incompleteTasks[index];
                      return TaskItem(
                        taskId: task.id,
                        text: task.name,
                        isCompleted: false,
                        date: task.deadline,
                        description: task.description,
                        priority: task.priority,
                        flagColor: task.priority == 'Cao' ? Colors.red : task.priority == 'Vừa' ? Colors.yellow : task.priority == 'Thấp' ? Colors.blue : Colors.white,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Đã Hoàn Thành",
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: completedTasks.length,
                    itemBuilder: (context, index) {
                      final task = completedTasks[index];
                      return TaskItem(
                        taskId: task.id,
                        text: task.name,
                        isCompleted: true,
                        date: task.deadline,
                        description: task.description,
                        priority: task.priority,
                        flagColor: task.priority == 'Cao' ? Colors.red : task.priority == 'Vừa' ? Colors.yellow : task.priority == 'Thấp' ? Colors.blue : Colors.white,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else if (state is TaskError) {
          return Center(child: Text('Lỗi: ${state.message}'));
        } else {
          return Center(child: Text('Không có công việc nào.'));
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          ).then((_) {
            BlocProvider.of<TaskBloc>(context).add(FetchTasksEvent());
          });
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskItem extends StatefulWidget {
  final String taskId;
  final String text;
  final bool isCompleted;
  final Timestamp? date;
  final String description;
  String priority;
  Color flagColor;

  TaskItem({
    required this.taskId,
    required this.text,
    this.isCompleted = false,
    required this.date,
    required this.description,
    required this.priority,
    required this.flagColor, 
  });

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  void _showTaskDetails(BuildContext context) {
    TextEditingController textController = TextEditingController(text: widget.text);
    TextEditingController descriptionController = TextEditingController(text: widget.description);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        BlocProvider.of<TaskBloc>(context).add(
                          UpdateTaskEvent(
                            taskId: widget.taskId,
                            updatedTask: Task(
                              id: widget.taskId,
                              name: textController.text, 
                              description: descriptionController.text, 
                              priority: widget.priority, 
                              status: widget.isCompleted ? 'Đã hoàn thành' : 'Chưa hoàn thành',
                              deadline: widget.date ?? Timestamp.now(), 
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      'Chi Tiết Công Việc',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Icon(Icons.more_vert, color: Colors.white),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: widget.isCompleted,
                      onChanged: (bool? value) {
                        BlocProvider.of<TaskBloc>(context).add(
                          ToggleTaskCompletionEvent(
                            taskId: widget.taskId,
                            isCompleted: value ?? false,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      activeColor: Colors.orange,
                    ),
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: widget.date?.toDate() ?? DateTime.now(),
                              firstDate: DateTime(2000), 
                              lastDate: DateTime(2100),   
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Colors.orange,   
                                      onPrimary: Colors.white, 
                                      surface: Color.fromARGB(255, 68, 65, 65), 
                                      onSurface: Colors.white,   
                                    ),
                                    dialogBackgroundColor: Colors.grey[900], 
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (selectedDate != null) {
                              BlocProvider.of<TaskBloc>(context).add(
                                UpdateTaskEvent(
                                  taskId: widget.taskId,
                                  updatedTask: Task(
                                    id: widget.taskId,
                                    name: textController.text, 
                                    description: descriptionController.text,
                                    priority: widget.priority, 
                                    status: widget.isCompleted ? 'Đã hoàn thành' : 'Chưa hoàn thành',
                                    deadline: Timestamp.fromDate(selectedDate),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(widget.date?.toDate() ?? DateTime.now()),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Hiển thị menu chọn mức độ ưu tiên
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Chọn Mức Độ Ưu Tiên', style: TextStyle(color: Colors.white, fontSize: 16)),
                                  ListTile(
                                    leading: const Icon(Icons.flag, color: Colors.red),
                                    title: const Text('Cao', style: TextStyle(color: Colors.white)),
                                    onTap: () {
                                      setState(() {
                                        widget.priority = 'Cao';
                                        widget.flagColor = Colors.red;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.flag, color: Colors.yellow),
                                    title: const Text('Vừa', style: TextStyle(color: Colors.white)),
                                    onTap: () {
                                      setState(() {
                                        widget.priority = 'Vừa';
                                        widget.flagColor = Colors.yellow;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.flag, color: Colors.blue),
                                    title: const Text('Thấp', style: TextStyle(color: Colors.white)),
                                    onTap: () {
                                      setState(() {
                                        widget.priority = 'Thấp';
                                        widget.flagColor = Colors.blue;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.flag, color: Colors.white),
                                    title: const Text('Không Ưu Tiên', style: TextStyle(color: Colors.white)),
                                    onTap: () {
                                      setState(() {
                                        widget.priority = 'Không ưu tiên';
                                        widget.flagColor = Colors.white;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Icon(Icons.flag, color: widget.flagColor), // Hiển thị cờ với màu tương ứng
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Tên công việc',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController, 
                  decoration: const InputDecoration(
                    hintText: 'Mô tả',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
   Widget build(BuildContext context) {
    String formattedDate = widget.date != null ? DateFormat('dd/MM/yyyy').format(widget.date!.toDate()) : '';
    
    return Slidable(
      key: ValueKey(widget.taskId),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              BlocProvider.of<TaskBloc>(context).add(DeleteTaskEvent(widget.taskId));
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Xóa',
          ),
          SlidableAction(
            onPressed: (context) {
              // Xử lý hành động nhắc nhở công việc
            },
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: Icons.calendar_today,
            label: 'Nhắc nhở',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _showTaskDetails(context),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Checkbox(
                value: widget.isCompleted,
                onChanged: (bool? value) {
                  BlocProvider.of<TaskBloc>(context).add(
                    ToggleTaskCompletionEvent(
                      taskId: widget.taskId,
                      isCompleted: value ?? false,
                    ),
                  );
                },
                activeColor: Colors.orange,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.isCompleted ? Colors.white54 : Colors.white,
                        fontSize: 16.0,
                        decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (formattedDate.isNotEmpty)
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.white54, fontSize: 14.0),
                      ),
                  ],
                ),
              ),
              GestureDetector(
              onTap: () {
                // Chọn mức độ ưu tiên sẽ hiện popup
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text("Cao", style: TextStyle(color: Colors.white)),
                            leading: const Icon(Icons.flag, color: Colors.red),
                            onTap: () {
                              setState(() {
                                widget.priority = 'Cao';
                                widget.flagColor = Colors.red;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text("Vừa", style: TextStyle(color: Colors.white)),
                            leading: const Icon(Icons.flag, color: Colors.yellow),
                            onTap: () {
                              setState(() {
                                widget.priority = 'Vừa';
                                widget.flagColor = Colors.yellow;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text("Thấp", style: TextStyle(color: Colors.white)),
                            leading: const Icon(Icons.flag, color: Colors.blue),
                            onTap: () {
                              setState(() {
                                widget.priority = 'Thấp';
                                widget.flagColor = Colors.blue;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text("Không Ưu Tiên", style: TextStyle(color: Colors.white)),
                            leading: const Icon(Icons.flag, color: Colors.white),
                            onTap: () {
                              setState(() {
                                widget.priority = 'Không Ưu Tiên';
                                widget.flagColor = Colors.white;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Icon(Icons.flag, color: widget.flagColor), // Cờ với màu tương ứng
            ),
            ],
          ),
        ),
      ),
    );
  }
}


