import 'package:flutter/material.dart';

//TODO:: This needs to be merged with child model
class Student with ChangeNotifier {
  final String? studentID;
  final String? studentImage;
  final String? studentName;

  Student({
    this.studentID,
    this.studentName,
    this.studentImage,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentID: json['studentID'],
      studentName: json['studentName'],
      studentImage: json['studentImage'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'studentID': studentID,
      'studentName': studentName,
      'studentImage': studentImage,
    };
  }

  Map<String, dynamic> toMap(Student student) {
    return {
      'studentID': student.studentID,
      'studentName': student.studentName,
      'studentImage': student.studentImage,
    };
  }

  static List<Map> convertStudentsToMap({
    required List<Student> studentList,
  }) {
    List<Map> students = [];
    studentList.forEach((Student obj) {
      Map objMap = Student().toMap(obj);
      students.add(objMap);
    });
    return students;
  }
}
