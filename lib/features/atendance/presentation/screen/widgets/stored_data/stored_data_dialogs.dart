import 'package:flutter/material.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_state.dart';

import 'package:qrattendance/features/atendance/presentation/screen/widgets/dialogs/bulk_sync_result_dialog.dart' as bulk;
import 'package:qrattendance/features/atendance/presentation/screen/widgets/dialogs/delete_bottom_sheet.dart' as del;
import 'package:qrattendance/features/atendance/presentation/screen/widgets/dialogs/delete_all_bottom_sheet.dart' as del_all;

class StoredDataDialogs {
  static void showBulkSyncResultDialog(
    BuildContext context,
    StoredDataBulkSyncResult state,
  ) {
    bulk.showBulkSyncResultDialog(context, state);
  }

  static void showDeleteBottomSheet(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    del.showDeleteBottomSheet(context, title, message, onConfirm);
  }

  static void showDeleteAllBottomSheet(BuildContext context) {
    del_all.showDeleteAllBottomSheet(context);
  }
}
