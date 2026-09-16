// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gymbook/core/theme/styles.dart';
// import 'package:gymbook/core/widgets/custom_text.dart';
// import 'package:gymbook/features/notifications/domain/entities/notification_entity.dart';
// import 'notification_style.dart';

// class NotificationCard extends StatelessWidget {
//   final NotificationEntity notification;
//   final AnimationController progressController;

//   const NotificationCard({
//     super.key,
//     required this.notification,
//     required this.progressController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final style = NotificationStyle.getStyleForType(
//       notification.notificationType,
//     );

//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF161B19),
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16.r),
//         child: Stack(
//           children: [
//             Padding(
//               padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Icon with Badge
//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Container(
//                         width: 44.w,
//                         height: 44.w,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         child: Icon(style.icon, color: style.color, size: 24.w),
//                       ),
//                       Positioned(
//                         top: -4.w,
//                         right: -4.w,
//                         child: Container(
//                           width: 14.w,
//                           height: 14.w,
//                           decoration: BoxDecoration(
//                             color: style.color,
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: const Color(0xFF161B19),
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(width: 16.w),
//                   // Texts
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: AppText(
//                                 notification.title,
//                                 style: font14w700.copyWith(color: Colors.white),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             AppText(
//                               "now",
//                               style: font12w400.copyWith(
//                                 color: Colors.grey.shade400,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 6.h),
//                         AppText(
//                           notification.message,
//                           style: font12w400.copyWith(
//                             color: Colors.grey.shade300,
//                             height: 1.4,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Bottom Progress Bar
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: AnimatedBuilder(
//                 animation: progressController,
//                 builder: (context, child) {
//                   return FractionallySizedBox(
//                     alignment: Alignment.centerLeft,
//                     widthFactor: 1.0 - progressController.value,
//                     child: Container(
//                       height: 4.h,
//                       decoration: BoxDecoration(
//                         color: style.color,
//                         borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(16.r),
//                           bottomRight: Radius.circular(16.r),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
