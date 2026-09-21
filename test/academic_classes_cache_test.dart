import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:qrattendance/features/atendance/data/model/academic_class_model.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';

void main() {
  group('AcademicClasses Cache Tests', () {
    late AttendanceLocalDataSourceImpl dataSource;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_test');
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(AcademicClassModelAdapter());
      }
      await Hive.openBox<AcademicClassModel>('academicClasses');
      dataSource = AttendanceLocalDataSourceImpl();
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'saveAcademicClasses stores models properly preserving fields',
      () async {
        final classes = [
          AcademicClassModel(
            id: 'class_1',
            name: 'First Year',
            certificate: true,
            educationSystem: 'General',
            sortOrder: 1,
          ),
        ];

        await dataSource.saveAcademicClasses(classes);

        final cachedClasses = await dataSource.getOfflineAcademicClasses();

        expect(cachedClasses.length, 1);
        expect(cachedClasses.first.id, 'class_1');
        expect(cachedClasses.first.name, 'First Year');
        expect(cachedClasses.first.certificate, true);
        expect(cachedClasses.first.educationSystem, 'General');
        expect(cachedClasses.first.sortOrder, 1);
      },
    );

    test(
      'saveAcademicClasses clears old data and adds new data (no duplicates)',
      () async {
        final classes1 = [
          AcademicClassModel(
            id: 'class_1',
            name: 'First Year',
            certificate: true,
            educationSystem: 'General',
            sortOrder: 1,
          ),
        ];
        await dataSource.saveAcademicClasses(classes1);

        final classes2 = [
          AcademicClassModel(
            id: 'class_2',
            name: 'Second Year',
            certificate: false,
            educationSystem: 'IGCSE',
            sortOrder: 2,
          ),
        ];
        await dataSource.saveAcademicClasses(classes2);

        final cachedClasses = await dataSource.getOfflineAcademicClasses();

        expect(cachedClasses.length, 1);
        expect(cachedClasses.first.id, 'class_2');
      },
    );

    test('fromJson properly parses bool certificate', () {
      final json = {
        'id': 100,
        'name': 'Grade 10',
        'certificate': true,
        'educationSystem': 'American',
        'sortOrder': '3',
      };

      final model = AcademicClassModel.fromJson(json);

      expect(model.id, '100');
      expect(model.certificate, true);
      expect(model.sortOrder, 3);
    });
  });
}
