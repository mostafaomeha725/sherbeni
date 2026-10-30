import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_state.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_actions_bar.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_app_bar.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_attendance_tab.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_dialogs.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_quiz_tab.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_search_bar.dart';

class StoredDataView extends StatefulWidget {
  const StoredDataView({super.key});

  @override
  State<StoredDataView> createState() => _StoredDataViewState();
}

class _StoredDataViewState extends State<StoredDataView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  void _onSearchCleared() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppLightColors.defaultBackground,
        appBar: const StoredDataAppBar(),
        body: Column(
          children: [
            const StoredDataActionsBar(),
            StoredDataSearchBar(
              searchController: _searchController,
              searchQuery: _searchQuery,
              onChanged: _onSearchChanged,
              onClear: _onSearchCleared,
            ),
            Expanded(
              child: BlocConsumer<StoredDataCubit, StoredDataState>(
                listener: (context, state) {
                  if (state is StoredDataBulkSyncResult) {
                    StoredDataDialogs.showBulkSyncResultDialog(context, state);
                  }
                },
                builder: (context, state) {
                  if (state is StoredDataLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is StoredDataError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is StoredDataLoaded) {
                    return TabBarView(
                      children: [
                        StoredDataAttendanceTab(
                          attendanceList: state.attendanceHistory,
                          searchQuery: _searchQuery,
                        ),
                        StoredDataQuizTab(
                          gradesList: state.quizGradeHistory,
                          searchQuery: _searchQuery,
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
