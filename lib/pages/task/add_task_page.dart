import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/task_bloc.dart';
import '../../../bloc/task_event.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String? _selectedPriority;
  String? _selectedStatus;
  DateTime? _selectedDate;

  final List<Map<String, dynamic>> _priorityLevels = [
    {'label': 'Cao', 'color': Colors.red},
    {'label': 'Vừa', 'color': Colors.yellow},
    {'label': 'Thấp', 'color': Colors.blue},
    {'label': 'Không ưu tiên', 'color': Colors.grey},
  ];

  final List<String> _statusOptions = ['Chưa hoàn thành', 'Đã hoàn thành'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF242424),
      appBar: AppBar(
        title: Text(
          'Công Việc',
          style: TextStyle(color: Colors.white),
          ),
        centerTitle: true,
        backgroundColor: Color(0xFF353535),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz),
            color: Color(0xFF818181),
            onPressed: () {
              // Hành động khi nhấn vào icon
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Tên Nhiệm Vụ',
                hintStyle: TextStyle(color: Color(0xFF818181)),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none, 
                  borderRadius: BorderRadius.circular(8.0), 
                ),
                filled: true,
                fillColor: Color(0xFF353535)),
                style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              
              decoration: InputDecoration(
                hintText: 'Mô Tả',
                hintStyle: TextStyle(color: Color(0xFF818181)),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none, 
                  borderRadius: BorderRadius.circular(8.0), 
                ),
                filled: true,
                fillColor: Color(0xFF353535)),
                style: TextStyle(color: Colors.white),
                maxLines: 2,
                
            ),

            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              dropdownColor: Color(0xFF353535),
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xFF353535),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),  
              borderRadius: BorderRadius.circular(8.0), 
              hint: Text(
                "Chọn Mức Độ Ưu Tiên",
                style: TextStyle(color: Color(0xFF818181)),
                ),
              style: TextStyle(color: Colors.white),
              items: _priorityLevels.map((priority) {
                return DropdownMenuItem<String>(
                  value: priority['label'],
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        color: priority['color'],
                      ),
                      SizedBox(width: 8),
                      Text(priority['label']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
              
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              dropdownColor: Color(0xFF353535),
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xFF353535),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              hint: Text(
                "Chọn Trạng Thái",
                style: TextStyle(color: Color(0xFF818181)),
              ),
              style: TextStyle(color: Colors.white),
              items: _statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            SizedBox(height: 16.0),

            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: _selectedDate == null
                    ? 'Chọn Ngày'
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                suffixIcon: Icon(Icons.calendar_today),
                filled: true,
                fillColor: Color(0xFF353535),
                hintStyle: TextStyle(color: Color(0xFFFAA80C)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                )
              ),
              onTap: () => _selectDate(context),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addTask(context);
              },
              child: Text('Thêm Công Việc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 196, 131, 9), 
                foregroundColor: Colors.white, 
                shadowColor: Colors.black, 
                elevation: 5, 
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens a date picker dialog to select a date.
  ///
  /// This function presents a date picker to the user, allowing them to select
  /// a date. The selected date is then stored in the [_selectedDate] variable
  /// if it differs from the current value.
  Future<void> _selectDate(BuildContext context) async {
    // Show the date picker and wait for the user's selection.
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), 
      lastDate: DateTime(2101),
    );

    // If a date is picked and it is different from the current selection, update the state.
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate; 
      });
    }
  }

  /// Adds a task to the database.
  ///
  /// This function is called when the user clicks the "Add task" button.
  /// It takes the text from the name and description text fields, and the
  /// selected priority, status, and deadline from the dropdown menus and
  /// date picker, and adds a task to the database with the specified
  /// details.
  ///
  /// The task is then added to the state of the [TaskBloc].
  ///
  /// After adding the task, the function navigates back to the previous
  /// screen.
  void _addTask(BuildContext context) {
  final taskName = _nameController.text;
  final taskDescription = _descriptionController.text;
  final taskPriority = _selectedPriority ?? 'Không ưu tiên';
  final taskStatus = _selectedStatus ?? 'Chưa hoàn thành';
  final taskDeadline = _selectedDate != null
      ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
      : '';

  BlocProvider.of<TaskBloc>(context).add(
    AddTaskEvent(
      name: taskName,
      description: taskDescription,
      priority: taskPriority,
      status: taskStatus,
      deadline: taskDeadline,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Thêm công việc thành công!'),
      duration: Duration(seconds: 2),
    ),
  );

  // Navigator.pop(context);
  }
}
