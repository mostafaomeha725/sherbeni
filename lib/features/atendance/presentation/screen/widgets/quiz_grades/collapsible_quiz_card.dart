import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/features/atendance/data/model/quiz_grade_history_model.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/quiz_grades/collapsible_quiz_card_header.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/quiz_grades/collapsible_quiz_card_details.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/quiz_grades/collapsible_quiz_card_actions.dart';

class CollapsibleQuizCard extends StatefulWidget {
  final QuizGradeHistoryModel item;
  final String sessionName;
  final String quizName;
  final Widget statusBadge;
  final VoidCallback? onRetry;
  final VoidCallback onDelete;

  const CollapsibleQuizCard({
    super.key,
    required this.item,
    required this.sessionName,
    required this.quizName,
    required this.statusBadge,
    this.onRetry,
    required this.onDelete,
  });

  @override
  State<CollapsibleQuizCard> createState() => CollapsibleQuizCardState();
}

class CollapsibleQuizCardState extends State<CollapsibleQuizCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          CollapsibleQuizCardHeader(
            item: widget.item,
            statusBadge: widget.statusBadge,
            isExpanded: _isExpanded,
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Color(0xFFEEEEEE), height: 1),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CollapsibleQuizCardDetails(
                        item: widget.item,
                        sessionName: widget.sessionName,
                        quizName: widget.quizName,
                      ),
                      SizedBox(height: 16.h),
                      CollapsibleQuizCardActions(
                        onRetry: widget.onRetry,
                        onDelete: widget.onDelete,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}
