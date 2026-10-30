part of 'stored_data_cubit.dart';

extension StoredDataExport on StoredDataCubit {
  Future<void> exportToExcel() async {
    if (state is! StoredDataLoaded) return;
    final currentState = state as StoredDataLoaded;

    try {
      EasyLoading.show(status: 'جاري تصدير البيانات...');

      var excel = Excel.createExcel();

      // ============== Attendance Sheet ==============
      var sheet1 = excel['حضور أوفلاين'];
      sheet1.setColumnWidth(0, 40.0); // Student ID
      sheet1.setColumnWidth(1, 40.0); // Session
      sheet1.setColumnWidth(2, 18.0); // Scan Time
      sheet1.setColumnWidth(3, 25.0); // Created At
      sheet1.setColumnWidth(4, 25.0); // Synced At
      sheet1.setColumnWidth(5, 18.0); // Status
      sheet1.setColumnWidth(6, 30.0); // Reason
      sheet1.setColumnWidth(7, 35.0); // Session Name

      try {
        sheet1.isRTL = false; // LTR for English
      } catch (_) {}

      // Title Section (Merged A1:M2 for a big professional header)
      sheet1.merge(
        CellIndex.indexByString("A1"),
        CellIndex.indexByString("H2"),
      );
      var titleCell1 = sheet1.cell(CellIndex.indexByString("A1"));
      titleCell1.value = TextCellValue('OFFLINE ATTENDANCE REPORT');
      titleCell1.cellStyle = CellStyle(
        bold: true,
        fontSize: 20,
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('#0F172A'), // Slate 900
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        leftBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
        rightBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
        topBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
        bottomBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
      );

      sheet1.merge(
        CellIndex.indexByString("A3"),
        CellIndex.indexByString("H3"),
      );
      var dateCell1 = sheet1.cell(CellIndex.indexByString("A3"));
      dateCell1.value = TextCellValue(
        'Generated on: ${DateTime.now().toString().substring(0, 16)}',
      );
      dateCell1.cellStyle = CellStyle(
        bold: true,
        fontSize: 11,
        fontColorHex: ExcelColor.fromHexString('#334155'), // Slate 700
        backgroundColorHex: ExcelColor.fromHexString('#F1F5F9'), // Slate 100
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        leftBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
        rightBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
        bottomBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
      );

      final headers1 = [
        'STUDENT ID',
        'SESSION ID',
        'SCAN TIME',
        'CREATED AT',
        'SYNCED AT',
        'STATUS',
        'REASON',
        'SESSION NAME',
      ];

      for (var i = 0; i < headers1.length; i++) {
        var cell = sheet1.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 5),
        );
        cell.value = TextCellValue(headers1[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          fontSize: 12,
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
          backgroundColorHex: ExcelColor.fromHexString('#475569'), // Slate 600
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          leftBorder: Border(
            borderStyle: BorderStyle.Thin,
            borderColorHex: ExcelColor.fromHexString('#000000'),
          ),
          rightBorder: Border(
            borderStyle: BorderStyle.Thin,
            borderColorHex: ExcelColor.fromHexString('#000000'),
          ),
          topBorder: Border(
            borderStyle: BorderStyle.Thin,
            borderColorHex: ExcelColor.fromHexString('#000000'),
          ),
          bottomBorder: Border(
            borderStyle: BorderStyle.Thin,
            borderColorHex: ExcelColor.fromHexString('#000000'),
          ),
        );
      }

      int currentRow1 = 6;
      if (currentState.attendanceHistory.isEmpty) {
        sheet1.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow1),
          CellIndex.indexByColumnRow(
            columnIndex: headers1.length - 1,
            rowIndex: currentRow1,
          ),
        );
        var emptyCell = sheet1.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow1),
        );
        emptyCell.value = TextCellValue('NO ATTENDANCE DATA FOUND');
        emptyCell.cellStyle = CellStyle(
          bold: true,
          fontSize: 14,
          fontColorHex: ExcelColor.fromHexString('#64748B'),
          backgroundColorHex: ExcelColor.fromHexString('#F8FAFC'),
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );
      } else {
        for (var record in currentState.attendanceHistory) {
          final values = [
            record.uid,
            record.sessionId,
            record.scanTime,
            record.createdAt.toString().length >= 16
                ? record.createdAt.toString().substring(0, 16)
                : record.createdAt.toString(),
            record.syncedAt != null && record.syncedAt.toString().length >= 16
                ? record.syncedAt.toString().substring(0, 16)
                : (record.syncedAt?.toString() ?? '-'),
            _getStatusText(record.syncStatus, record.createdAt),
            record.error ?? '-',
            record.sessionName ?? '-',
          ];
          for (var i = 0; i < values.length; i++) {
            var cell = sheet1.cell(
              CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow1),
            );
            cell.value = TextCellValue(values[i]);
            cell.cellStyle = CellStyle(
              horizontalAlign: HorizontalAlign.Left,
              leftBorder: Border(
                borderStyle: BorderStyle.Thin,
                borderColorHex: ExcelColor.fromHexString('#000000'),
              ),
              rightBorder: Border(
                borderStyle: BorderStyle.Thin,
                borderColorHex: ExcelColor.fromHexString('#000000'),
              ),
              bottomBorder: Border(
                borderStyle: BorderStyle.Thin,
                borderColorHex: ExcelColor.fromHexString('#000000'),
              ),
            );
          }
          currentRow1++;
        }
      }

      // ============== Quiz Grades Sheet ==============
      var sheet2 = excel['درجات الكويز'];
      sheet2.setColumnWidth(0, 35.0); // Student Name
      sheet2.setColumnWidth(1, 40.0); // Student ID
      sheet2.setColumnWidth(2, 25.0); // Quiz Name
      sheet2.setColumnWidth(3, 15.0); // Grade
      sheet2.setColumnWidth(4, 15.0); // Max Score
      sheet2.setColumnWidth(5, 40.0); // Session ID
      sheet2.setColumnWidth(6, 25.0); // Created At
      sheet2.setColumnWidth(7, 25.0); // Synced At
      sheet2.setColumnWidth(8, 18.0); // Status
      sheet2.setColumnWidth(9, 30.0); // Reason

      try {
        sheet2.isRTL = false; // LTR for English
      } catch (_) {}

      // Title Section (Merged A1:J2 for a big professional header)
      sheet2.merge(
        CellIndex.indexByString("A1"),
        CellIndex.indexByString("J2"),
      );
      var titleCell2 = sheet2.cell(CellIndex.indexByString("A1"));
      titleCell2.value = TextCellValue('OFFLINE QUIZ GRADES REPORT');
      titleCell2.cellStyle = CellStyle(
        bold: true,
        fontSize: 20,
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('#0F172A'), // Slate 900
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        leftBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
        rightBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
        topBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
        bottomBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
      );

      sheet2.merge(
        CellIndex.indexByString("A3"),
        CellIndex.indexByString("J3"),
      );
      var dateCell2 = sheet2.cell(CellIndex.indexByString("A3"));
      dateCell2.value = TextCellValue(
        'Generated on: ${DateTime.now().toString().substring(0, 16)}',
      );
      dateCell2.cellStyle = CellStyle(
        bold: true,
        fontSize: 11,
        fontColorHex: ExcelColor.fromHexString('#334155'), // Slate 700
        backgroundColorHex: ExcelColor.fromHexString('#F1F5F9'), // Slate 100
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        leftBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
        rightBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
        bottomBorder: Border(
          borderStyle: BorderStyle.Thin,
          borderColorHex: ExcelColor.fromHexString('#000000'),
        ),
      );

      final headers2 = [
        'STUDENT NAME',
        'STUDENT ID',
        'QUIZ NAME',
        'GRADE',
        'MAX SCORE',
        'SESSION ID',
        'CREATED AT',
        'SYNCED AT',
        'STATUS',
        'REASON',
      ];

      for (var i = 0; i < headers2.length; i++) {
        var cell = sheet2.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 5),
        );
        cell.value = TextCellValue(headers2[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          fontSize: 12,
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
          backgroundColorHex: ExcelColor.fromHexString('#475569'), // Slate 600
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          leftBorder: Border(
            borderStyle: BorderStyle.Thin,
            borderColorHex: ExcelColor.fromHexString('#000000'),
          ),
          rightBorder: Border(
            borderStyle: BorderStyle.Thin,
            borderColorHex: ExcelColor.fromHexString('#000000'),
          ),
          topBorder: Border(
            borderStyle: BorderStyle.Thin,
            borderColorHex: ExcelColor.fromHexString('#000000'),
          ),
          bottomBorder: Border(
            borderStyle: BorderStyle.Thin,
            borderColorHex: ExcelColor.fromHexString('#000000'),
          ),
        );
      }

      int currentRow2 = 6;
      if (currentState.quizGradeHistory.isEmpty) {
        sheet2.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow2),
          CellIndex.indexByColumnRow(
            columnIndex: headers2.length - 1,
            rowIndex: currentRow2,
          ),
        );
        var emptyCell = sheet2.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow2),
        );
        emptyCell.value = TextCellValue('NO QUIZ GRADES DATA FOUND');
        emptyCell.cellStyle = CellStyle(
          bold: true,
          fontSize: 14,
          fontColorHex: ExcelColor.fromHexString('#64748B'),
          backgroundColorHex: ExcelColor.fromHexString('#F8FAFC'),
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );
      } else {
        for (var record in currentState.quizGradeHistory) {
          final values = [
            record.studentName,
            record.studentId,
            record.quizName ?? '-',
            record.grade.toString(),
            record.maxScore?.toString() ?? '-',
            record.sessionId,
            record.createdAt.toString().length >= 16
                ? record.createdAt.toString().substring(0, 16)
                : record.createdAt.toString(),
            record.syncedAt != null && record.syncedAt.toString().length >= 16
                ? record.syncedAt.toString().substring(0, 16)
                : (record.syncedAt?.toString() ?? '-'),
            _getStatusText(record.syncStatus, record.createdAt),
            record.error ?? '-',
          ];
          for (var i = 0; i < values.length; i++) {
            var cell = sheet2.cell(
              CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow2),
            );
            cell.value = TextCellValue(values[i]);
            cell.cellStyle = CellStyle(
              horizontalAlign: HorizontalAlign.Left,
              leftBorder: Border(
                borderStyle: BorderStyle.Thin,
                borderColorHex: ExcelColor.fromHexString('#000000'),
              ),
              rightBorder: Border(
                borderStyle: BorderStyle.Thin,
                borderColorHex: ExcelColor.fromHexString('#000000'),
              ),
              bottomBorder: Border(
                borderStyle: BorderStyle.Thin,
                borderColorHex: ExcelColor.fromHexString('#000000'),
              ),
            );
          }
          currentRow2++;
        }
      }

      if (excel.getDefaultSheet() == 'Sheet1') {
        excel.delete('Sheet1');
      }

      var fileBytes = excel.encode();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/البيانات_المخزنة.xlsx';
        final file = File(path);
        await file.writeAsBytes(fileBytes);

        EasyLoading.dismiss();

        final xFile = XFile(path);
        await Share.shareXFiles([xFile], text: 'البيانات المخزنة أوفلاين');
      }
    } catch (e) {
      EasyLoading.showError('فشل التصدير: ${e.toString()}');
    }
  }

  String _getStatusText(String status, DateTime createdAt) {
    if (status == 'success') return 'نجح';
    if (DateTime.now().difference(createdAt).inHours > 24) {
      return 'انتهت مدة الاحتفاظ';
    }
    if (status == 'failed') return 'فشل';
    return 'في انتظار المزامنة';
  }
}
