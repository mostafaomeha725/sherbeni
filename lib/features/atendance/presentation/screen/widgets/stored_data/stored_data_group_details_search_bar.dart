import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';

class StoredDataGroupDetailsSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String type;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const StoredDataGroupDetailsSearchBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.type,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: TextField(
        controller: searchController,
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: type == 'attendance'
              ? 'ابحث باسم الطالب أو الكود...'
              : 'ابحث باسم الطالب، الكود، أو الكويز...',
          hintStyle: font12w500.copyWith(color: const Color(0xFF999999)),
          hintTextDirection: TextDirection.rtl,
          prefixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: onClear,
                )
              : null,
          suffixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppLightColors.primary),
          ),
        ),
      ),
    );
  }
}
