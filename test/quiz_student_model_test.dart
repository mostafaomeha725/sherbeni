import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/features/atendance/data/model/quiz_student_model.dart';

void main() {
  group('QuizStudentModel Tests', () {
    test(
      'يتم استخراج parent_phone_number بنجاح من استجابة API درجات الكويز',
      () {
        final json = {
          "student_id": "d0f6746f-f5b1-428f-91cd-af4694c3c9bf",
          "name": "adsa as ad n",
          "email": "masdnsad@gmail.com",
          "student_code": "49051426",
          "phone_number": "01122453221",
          "parent_phone_number": "01122453227",
          "picture": null,
          "grade": 58,
          "approved_by": null,
          "approved_at": "2026-10-11T03:17:03.000+03:00",
        };

        final model = QuizStudentModel.fromJson(json);

        expect(model.studentId, "d0f6746f-f5b1-428f-91cd-af4694c3c9bf");
        expect(model.name, "adsa as ad n");
        expect(model.phoneNumber, "01122453221");
        expect(model.parentPhoneNumber, "01122453227");
        expect(model.grade, 58);

        final outputJson = model.toJson();
        expect(outputJson['parent_phone_number'], "01122453227");
      },
    );

    test('يعمل بشكل طبيعي إذا كان parent_phone_number غير موجود أو null', () {
      final json = {
        "student_id": "fb2fa876-7b33-4bc2-92fe-a8a0e345be98",
        "name": "sda dsa dsa das",
        "email": "osad@gmail.com",
        "student_code": "38241485",
        "phone_number": "01234567811",
        "parent_phone_number": null,
        "picture": null,
        "grade": null,
      };

      final model = QuizStudentModel.fromJson(json);

      expect(model.studentId, "fb2fa876-7b33-4bc2-92fe-a8a0e345be98");
      expect(model.parentPhoneNumber, isNull);
    });
  });
}
