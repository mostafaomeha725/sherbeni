// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gymbook/core/routes/app_routes.dart';
// import 'package:gymbook/features/notifications/domain/entities/notification_entity.dart';
// import 'dart:async';

// import 'notification_card.dart';

// class InAppNotificationPopup extends StatefulWidget {
//   final NotificationEntity notification;
//   final VoidCallback onDismiss;

//   const InAppNotificationPopup({
//     super.key,
//     required this.notification,
//     required this.onDismiss,
//   });

//   static void show(NotificationEntity notification) {
//     final overlayState = navigatorKey.currentState?.overlay;
//     if (overlayState == null) return;

//     late OverlayEntry overlayEntry;
//     overlayEntry = OverlayEntry(
//       builder: (context) {
//         return Positioned(
//           top: MediaQuery.of(context).padding.top + 10.h,
//           left: 16.w,
//           right: 16.w,
//           child: Material(
//             color: Colors.transparent,
//             child: InAppNotificationPopup(
//               notification: notification,
//               onDismiss: () {
//                 overlayEntry.remove();
//               },
//             ),
//           ),
//         );
//       },
//     );

//     overlayState.insert(overlayEntry);
//   }

//   @override
//   State<InAppNotificationPopup> createState() => _InAppNotificationPopupState();
// }

// class _InAppNotificationPopupState extends State<InAppNotificationPopup>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late AnimationController _progressController;
//   late Animation<Offset> _offsetAnimation;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );

//     _progressController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 4),
//     );

//     _offsetAnimation = Tween<Offset>(
//       begin: const Offset(0, -1.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

//     _controller.forward();
//     _progressController.forward();

//     _timer = Timer(const Duration(seconds: 4), _dismiss);
//   }

//   void _dismiss() {
//     _timer?.cancel();
//     _controller.reverse().then((value) {
//       widget.onDismiss();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _progressController.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SlideTransition(
//       position: _offsetAnimation,
//       child: GestureDetector(
//         onVerticalDragUpdate: (details) {
//           if (details.primaryDelta! < -5) {
//             _dismiss();
//           }
//         },
//         onTap: () {
//           // You could navigate to notifications screen here
//           _dismiss();
//         },
//         child: NotificationCard(
//           notification: widget.notification,
//           progressController: _progressController,
//         ),
//       ),
//     );
//   }
// }
