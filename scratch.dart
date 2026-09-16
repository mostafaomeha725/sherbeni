import 'package:excel/excel.dart';

void main() {
  var style = CellStyle(
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    backgroundColorHex: ExcelColor.blue,
  );
  print(style.isBold);
}
