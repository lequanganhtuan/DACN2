import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String name;
  final String description;
  final String priority;
  final String status;
  final Timestamp deadline; 

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    required this.status,
    required this.deadline,
  });

  factory Task.fromMap(Map<String, dynamic> data, String documentId) {
    return Task(
      id: documentId,
      name: data['name'] as String,
      description: data['description'] as String,
      priority: data['priority'] as String,
      status: data['status'] as String,
      deadline: data['deadline'] as Timestamp, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'priority': priority,
      'status': status,
      'deadline': deadline, 
    };
  }

  bool get isCompleted => status == 'Đã hoàn thành';
}
