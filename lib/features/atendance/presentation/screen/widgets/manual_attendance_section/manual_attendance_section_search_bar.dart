import 'package:flutter/material.dart';
import 'package:qrattendance/core/theme/light_colors.dart';

class ManualAttendanceSectionSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const ManualAttendanceSectionSearchBar({
    super.key,
    required this.searchController,
    required this.focusNode,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search by full name, code, phone or email',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[400],
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppLightColors.primary,
                  size: 20,
                ),
                suffixIcon: ListenableBuilder(
                  listenable: searchController,
                  builder: (context, _) {
                    if (searchController.text.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: onClear,
                      color: Colors.grey[500],
                    );
                  },
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppLightColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ManualAttendanceSectionSearchButton(onPressed: onSearch),
        ],
      ),
    );
  }
}

class ManualAttendanceSectionSearchButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const ManualAttendanceSectionSearchButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppLightColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.search_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
