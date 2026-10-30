import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/features/atendance/data/model/session_attendance_model.dart';

void main() {
  group('SessionAttendanceModel Tests', () {
    test(
      'يتم استخراج parent_phone_number بنجاح من الـ JSON كما في استجابة الـ API',
      () {
        final json = {
          "attendance_id": "f5553051-5545-4068-8057-206f56291799",
          "student_id": "d0f6746f-f5b1-428f-91cd-af4694c3c9bf",
          "name": "adsa as ad n",
          "picture": null,
          "phone_number": "01122453221",
          "parent_phone_number": "01122453227",
          "date": "2026-10-03",
          "time": "22:05:46",
          "session_date": "2026-10-03",
          "session_time": "21:27:00",
          "is_late": false,
        };

        final model = SessionAttendanceModel.fromJson(json);

        expect(model.attendanceId, "f5553051-5545-4068-8057-206f56291799");
        expect(model.studentId, "d0f6746f-f5b1-428f-91cd-af4694c3c9bf");
        expect(model.name, "adsa as ad n");
        expect(model.phoneNumber, "01122453221");
        expect(model.parentPhoneNumber, "01122453227");
        expect(model.isLate, false);

        final outputJson = model.toJson();
        expect(outputJson['parent_phone_number'], "01122453227");
      },
    );

    test('يعمل بشكل طبيعي إذا كان parent_phone_number غير موجود أو null', () {
      final json = {
        "attendance_id": "1",
        "student_id": "2",
        "name": "Test",
        "parent_phone_number": null,
      };

      final model = SessionAttendanceModel.fromJson(json);

      expect(model.parentPhoneNumber, isNull);
    });
  });
}
