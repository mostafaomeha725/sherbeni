import 'package:intl/intl.dart';

class AppDateTime {
  static String utcToLocalTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);

    final localTime = dateTime.toUtc().toLocal();

    return DateFormat("yyyy-MM-dd HH:mm a", "en").format(localTime);
  }

  static String utcToLocalDateOnly(String timestamp) {
    final dateTime = DateTime.parse(timestamp);

    final localTime = dateTime.toUtc().toLocal();

    return DateFormat("yyyy-MM-dd", "en").format(localTime);
  }

  static String timestampToFormatted(String timestamp) {
    return DateFormat(
      "yyyy-MM-dd HH:mm a",
      "en",
    ).format(DateTime.parse(timestamp));
  }

  static String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String twoDigitMinutes = '${duration.inMinutes.remainder(60)}'.padLeft(
      2,
      '0',
    );
    String twoDigitSeconds = '${duration.inSeconds.remainder(60)}'.padLeft(
      2,
      '0',
    );
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}
