import 'package:flutter/material.dart';
import 'package:qrattendance/core/utils/easy_loading.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/homework_grades/homework_grades_card_badge_editing.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/homework_grades/homework_grades_card_badge_normal.dart';

class HomeworkGradesCardBadge extends StatefulWidget {
  final num? currentGrade;
  final num? homeworkMaxGrade;
  final void Function(num) onGradeEntered;

  const HomeworkGradesCardBadge({
    super.key,
    required this.currentGrade,
    this.homeworkMaxGrade,
    required this.onGradeEntered,
  });

  @override
  State<HomeworkGradesCardBadge> createState() => _HomeworkGradesCardBadgeState();
}

class _HomeworkGradesCardBadgeState extends State<HomeworkGradesCardBadge> {
  bool _isEditing = false;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentGrade?.toString() ?? '',
    );
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant HomeworkGradesCardBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentGrade != oldWidget.currentGrade) {
      _controller.text = widget.currentGrade?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveGrade() {
    if (_controller.text.isNotEmpty) {
      final grade = num.tryParse(_controller.text);
      if (grade != null) {
        if (widget.homeworkMaxGrade != null && grade > widget.homeworkMaxGrade!) {
          showError('لا يمكن إدخال درجة أكبر من ${widget.homeworkMaxGrade}');
          _controller.text = widget.homeworkMaxGrade.toString();
          return;
        }
        widget.onGradeEntered(grade);
      }
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return HomeworkGradesCardBadgeEditing(
        controller: _controller,
        focusNode: _focusNode,
        homeworkMaxGrade: widget.homeworkMaxGrade,
        onSave: _saveGrade,
      );
    }

    return HomeworkGradesCardBadgeNormal(
      currentGrade: widget.currentGrade,
      onTap: () {
        setState(() {
          _isEditing = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNode.requestFocus();
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
        });
      },
    );
  }
}
