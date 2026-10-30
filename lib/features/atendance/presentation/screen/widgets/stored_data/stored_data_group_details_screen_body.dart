import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_state.dart';
import 'stored_data_group_details_search_bar.dart';

class StoredDataGroupDetailsScreenBody extends StatefulWidget {
  final String sessionName;
  final String type; // 'attendance' or 'quiz'
  final List<dynamic> items;
  final Widget Function(BuildContext, dynamic) itemBuilder;

  const StoredDataGroupDetailsScreenBody({
    super.key,
    required this.sessionName,
    required this.type,
    required this.items,
    required this.itemBuilder,
  });

  @override
  State<StoredDataGroupDetailsScreenBody> createState() =>
      _StoredDataGroupDetailsScreenBodyState();
}

class _StoredDataGroupDetailsScreenBodyState
    extends State<StoredDataGroupDetailsScreenBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StoredDataGroupDetailsSearchBar(
          searchController: _searchController,
          searchQuery: _searchQuery,
          type: widget.type,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
          onClear: () {
            _searchController.clear();
            setState(() {
              _searchQuery = '';
            });
          },
        ),
        Expanded(
          child: BlocBuilder<StoredDataCubit, StoredDataState>(
            builder: (context, state) {
              // Keep items up to date if they are deleted/changed
              List<dynamic> currentItems = [];
              if (widget.type == 'attendance' && state is StoredDataLoaded) {
                currentItems = state.attendanceHistory.where((i) {
                  final sName = i.sessionName;
                  return sName == widget.sessionName ||
                      (sName == null && widget.sessionName == 'غير معروف');
                }).toList();
              } else if (widget.type == 'quiz' && state is StoredDataLoaded) {
                currentItems = state.quizGradeHistory.where((i) {
                  final sName = i.sessionName;
                  return sName == widget.sessionName ||
                      (sName == null && widget.sessionName == 'غير معروف');
                }).toList();
              } else {
                currentItems = widget.items;
              }

              // Filter by local search query
              if (_searchQuery.isNotEmpty) {
                currentItems = currentItems.where((item) {
                  if (widget.type == 'attendance') {
                    final uid = (item.uid as String).toLowerCase();
                    final sName = (item.studentName as String).toLowerCase();
                    return uid.contains(_searchQuery) ||
                        sName.contains(_searchQuery);
                  } else {
                    final uid = (item.studentId as String).toLowerCase();
                    final sName = (item.studentName as String).toLowerCase();
                    final qName = ((item.quizName as String?) ?? '')
                        .toLowerCase();
                    return uid.contains(_searchQuery) ||
                        sName.contains(_searchQuery) ||
                        qName.contains(_searchQuery);
                  }
                }).toList();
              }

              if (currentItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off_rounded
                              : (widget.type == 'attendance'
                                    ? Icons.group_off_outlined
                                    : Icons.quiz_outlined),
                          size: 50.sp,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      AppText(
                        _searchQuery.isNotEmpty
                            ? 'لا توجد نتائج مطابقة لبحثك'
                            : 'لا يوجد سجلات في هذا السيشن',
                        style: font16w500.copyWith(
                          color: const Color(0xFF777777),
                        ),
                        alignment: AlignmentDirectional.center,
                      ),
                      if (_searchQuery.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        AppText(
                          'حاول البحث بكلمة أخرى',
                          style: font12w500.copyWith(
                            color: const Color(0xFF999999),
                          ),
                          alignment: AlignmentDirectional.center,
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount: currentItems.length,
                itemBuilder: (context, index) {
                  return widget.itemBuilder(context, currentItems[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
