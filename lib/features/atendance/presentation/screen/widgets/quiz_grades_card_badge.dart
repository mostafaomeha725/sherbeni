import 'package:flutter/material.dart';
import 'package:qrattendance/core/utils/easy_loading.dart';
import 'quiz_grades_card_badge_editing.dart';
import 'quiz_grades_card_badge_normal.dart';

class QuizGradesCardBadge extends StatefulWidget {
  final num? currentGrade;
  final num? quizMaxGrade;
  final void Function(num) onGradeEntered;

  const QuizGradesCardBadge({
    super.key,
    required this.currentGrade,
    this.quizMaxGrade,
    required this.onGradeEntered,
  });

  @override
  State<QuizGradesCardBadge> createState() => _QuizGradesCardBadgeState();
}

class _QuizGradesCardBadgeState extends State<QuizGradesCardBadge> {
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
  void didUpdateWidget(covariant QuizGradesCardBadge oldWidget) {
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
        if (widget.quizMaxGrade != null && grade > widget.quizMaxGrade!) {
          showError('لا يمكن إدخال درجة أكبر من ${widget.quizMaxGrade}');
          _controller.text = widget.quizMaxGrade.toString();
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
      return QuizGradesCardBadgeEditing(
        controller: _controller,
        focusNode: _focusNode,
        quizMaxGrade: widget.quizMaxGrade,
        onSave: _saveGrade,
      );
    }

    return QuizGradesCardBadgeNormal(
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
