import 'package:flutter/material.dart';

class ManualAttendanceSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const ManualAttendanceSearchBar({
    super.key,
    required this.searchController,
    required this.focusNode,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: TextField(
          controller: searchController,
          focusNode: focusNode,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => onSearch(),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Full Name, Code, Phone, or Email',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
            suffixIcon: ListenableBuilder(
              listenable: searchController,
              builder: (context, _) {
                if (searchController.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: Icon(Icons.cancel_rounded, color: Colors.grey.shade400),
                  onPressed: onClear,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
