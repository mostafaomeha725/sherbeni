class StudentData {
  final String studentId;
  final String name;
  final String username;
  final String? subjectId;
  final String? subjectName;
  final String token;

  StudentData({
    required this.studentId,
    required this.name,
    required this.username,
    this.subjectId,
    this.subjectName,
    required this.token,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      studentId: json['student_id'].toString(),
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      subjectId: json['subject_id']?.toString(),
      subjectName: json['subject_name'],
      token: json['token'] ?? '',
    );
  }
}
