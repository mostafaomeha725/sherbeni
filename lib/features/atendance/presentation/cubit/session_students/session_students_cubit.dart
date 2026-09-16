import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:qrattendance/core/models/pagination_model.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'package:qrattendance/features/atendance/data/model/session_attendance_model.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_session_attendances_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_offline_session_attendances_use_case.dart';

part 'session_students_state.dart';

class SessionStudentsCubit extends Cubit<SessionStudentsState> {
  final GetSessionAttendancesUseCase getSessionAttendancesUseCase;
  final GetOfflineSessionAttendancesUseCase getOfflineSessionAttendancesUseCase;
  final Connectivity connectivity;

  int _currentPage = 1;
  final int _limit = 10;

  SessionStudentsCubit(
    this.getSessionAttendancesUseCase,
    this.getOfflineSessionAttendancesUseCase,
    this.connectivity,
  ) : super(SessionStudentsInitial());

  Future<void> fetchStudents(String sessionId, {bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    if (_currentPage == 1) {
      emit(SessionStudentsLoading());
    } else {
      if (state is SessionStudentsLoaded) {
        emit((state as SessionStudentsLoaded).copyWith(isFetchingMore: true));
      }
    }

    final connectivityResult = await connectivity.checkConnectivity();
    final isOffline = connectivityResult.contains(ConnectivityResult.none);

    if (isOffline) {
      // Offline mode
      final result = await getOfflineSessionAttendancesUseCase.call(sessionId);
      result.fold((failure) => emit(SessionStudentsFailure(failure.message)), (
        attendances,
      ) {
        emit(
          SessionStudentsLoaded(
            attendances: attendances,
            pagination: null, // No pagination offline
            isOffline: true,
          ),
        );
      });
    } else {
      // Online mode
      final result = await getSessionAttendancesUseCase.call(
        sessionId,
        _currentPage,
        _limit,
      );
      result.fold((failure) => emit(SessionStudentsFailure(failure.message)), (
        data,
      ) {
        final List dynamicList = data['data']['attendances'] ?? [];
        final newAttendances = dynamicList
            .map((e) => SessionAttendanceModel.fromJson(e))
            .toList();

        PaginationModel? pagination;
        if (data['pagination'] != null) {
          pagination = PaginationModel.fromJson(data['pagination']);
        }

        if (_currentPage == 1) {
          emit(
            SessionStudentsLoaded(
              attendances: newAttendances,
              pagination: pagination,
            ),
          );
        } else {
          if (state is SessionStudentsLoaded) {
            final currentList = (state as SessionStudentsLoaded).attendances;
            emit(
              SessionStudentsLoaded(
                attendances: [...currentList, ...newAttendances],
                pagination: pagination,
              ),
            );
          }
        }
      });
    }
  }

  void fetchNextPage(String sessionId) {
    if (state is SessionStudentsLoaded) {
      final currentState = state as SessionStudentsLoaded;
      if (currentState.isFetchingMore) return;

      final pagination = currentState.pagination;
      if (pagination != null && pagination.hasNextPage) {
        _currentPage++;
        fetchStudents(sessionId);
      }
    }
  }

  Future<void> exportToExcel(String sessionName, String sessionId) async {
    if (state is! SessionStudentsLoaded) return;
    final currentState = state as SessionStudentsLoaded;

    try {
      EasyLoading.show(status: 'جاري جمع بيانات الطلبة بالكامل...');

      List<SessionAttendanceEntity> allAttendances = [];

      final isOfflineResult = await connectivity.checkConnectivity();
      final isOffline = isOfflineResult.contains(ConnectivityResult.none);

      if (isOffline) {
        final result = await getOfflineSessionAttendancesUseCase.call(
          sessionId,
        );
        result.fold(
          (failure) => allAttendances = currentState.attendances,
          (data) => allAttendances = data,
        );
      } else {
        // Fetch all data from API using a large limit
        final result = await getSessionAttendancesUseCase.call(
          sessionId,
          1,
          100000,
        );
        result.fold((failure) => allAttendances = currentState.attendances, (
          data,
        ) {
          final List dynamicList = data['data']['attendances'] ?? [];
          allAttendances = dynamicList
              .map((e) => SessionAttendanceModel.fromJson(e))
              .toList();
        });
      }

      if (allAttendances.isEmpty) {
        allAttendances = currentState.attendances;
      }

      if (allAttendances.isEmpty) {
        EasyLoading.dismiss();
        EasyLoading.showInfo('لا يوجد طلبة لاستخراجهم');
        return;
      }

      EasyLoading.show(status: 'جاري إنشاء الملف...');

      var excel = Excel.createExcel();
      var sheet = excel['Students'];

      // Column Widths
      sheet.setColumnWidth(0, 35.0); // Name
      sheet.setColumnWidth(1, 20.0); // Phone
      sheet.setColumnWidth(2, 18.0); // Scan Date
      sheet.setColumnWidth(3, 18.0); // Scan Time
      sheet.setColumnWidth(4, 22.0); // Session Date
      sheet.setColumnWidth(5, 22.0); // Session Time
      sheet.setColumnWidth(6, 18.0); // Status

      try {
        sheet.isRTL = false; // LTR for English
      } catch (_) {}

      // Title Section (Merged A1:G2 for a big professional header)
      sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("G2"));
      var titleCell = sheet.cell(CellIndex.indexByString("A1"));
      titleCell.value = TextCellValue('ATTENDANCE REPORT: $sessionName');
      titleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 20,
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('#0F172A'), // Slate 900
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
        rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
        topBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
        bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
      );
      
      sheet.merge(CellIndex.indexByString("A3"), CellIndex.indexByString("G3"));
      var dateCell = sheet.cell(CellIndex.indexByString("A3"));
      dateCell.value = TextCellValue('Generated on: ${DateTime.now().toString().substring(0, 16)}');
      dateCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 11,
        fontColorHex: ExcelColor.fromHexString('#334155'), // Slate 700
        backgroundColorHex: ExcelColor.fromHexString('#F1F5F9'), // Slate 100
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
        rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
        bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
      );

      // Statistics Grid
      int onTimeCount = allAttendances.where((e) => !e.isLate).length;
      int lateCount = allAttendances.where((e) => e.isLate).length;

      void setStatBox(String col1, String col2, String label, String value, String colorHex) {
        sheet.merge(CellIndex.indexByString(col1), CellIndex.indexByString(col2));
        var cell = sheet.cell(CellIndex.indexByString(col1));
        cell.value = TextCellValue('$label: $value');
        cell.cellStyle = CellStyle(
          bold: true,
          fontSize: 12,
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
          backgroundColorHex: ExcelColor.fromHexString(colorHex),
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
          rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
          topBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
          bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
        );
      }

      setStatBox('A5', 'C5', 'TOTAL STUDENTS', '${allAttendances.length}', '#334155'); // Slate 700
      setStatBox('D5', 'E5', 'ON TIME', '$onTimeCount', '#16A34A'); // Emerald 600
      setStatBox('F5', 'G5', 'LATE', '$lateCount', '#DC2626'); // Red 600

      // Table Headers (Row 7)
      final headers = [
        'NAME',
        'PHONE',
        'SCAN DATE',
        'SCAN TIME',
        'SESSION DATE',
        'SESSION TIME',
        'STATUS'
      ];

      for (var i = 0; i < headers.length; i++) {
        var cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 6),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          fontSize: 12,
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
          backgroundColorHex: ExcelColor.fromHexString('#475569'), // Slate 600
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
          rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
          topBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
          bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
        );
      }

      // Data Rows
      for (var row = 0; row < allAttendances.length; row++) {
        var student = allAttendances[row];
        var dataRow = row + 7;
        
        final statusText = student.isLate ? 'LATE' : 'ON TIME';
        final statusColor = student.isLate 
            ? ExcelColor.fromHexString('#FEF2F2') 
            : ExcelColor.fromHexString('#F0FDF4');
        final fontColor = student.isLate
            ? ExcelColor.fromHexString('#DC2626') 
            : ExcelColor.fromHexString('#16A34A');

        final rowData = [
          student.name,
          (student.phoneNumber != null && student.phoneNumber!.isNotEmpty) ? student.phoneNumber! : 'غير متوفر',
          student.date,
          student.time,
          student.sessionDate ?? '-',
          student.sessionTime ?? '-',
          statusText,
        ];

        for (var col = 0; col < rowData.length; col++) {
          var cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: dataRow),
          );
          cell.value = TextCellValue(rowData[col]);
          
          bool isStatusCol = col == 6;

          cell.cellStyle = CellStyle(
            horizontalAlign: col == 0 ? HorizontalAlign.Left : HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
            bold: isStatusCol,
            fontColorHex: isStatusCol ? fontColor : ExcelColor.fromHexString('#000000'),
            backgroundColorHex: isStatusCol ? statusColor : ExcelColor.fromHexString('#FFFFFF'),
            leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
            rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
            topBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
            bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString('#000000')),
          );
        }
      }

      // Remove default sheet
      if (excel.getDefaultSheet() != 'Students') {
        excel.delete(excel.getDefaultSheet()!);
      }

      var fileBytes = excel.encode();

      final directory = await getTemporaryDirectory();
      final sanitizedSessionName = sessionName.replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '',
      );
      final fileName = 'Students_$sanitizedSessionName.xlsx';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(fileBytes!);

      EasyLoading.dismiss();

      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: 'قائمة حضور الجلسة: $sessionName');
    } catch (e) {
      EasyLoading.showError('فشل في استخراج الملف: $e');
    }
  }
}
