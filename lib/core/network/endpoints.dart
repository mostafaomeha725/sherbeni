class EndPoints {
  static const String apiSecret = 'kJ5kHX2vCfiy0zc2mWulKgZy0TFo6pTF';

  /// Auth endpoints
  static const String registerUser = 'Authentication/register-user';
  static const String registerOwner = 'Authentication/register-owner';

  static const String login = 'Authentication/login';
  static const String mobileLogin = 'api/v1/mobile/login';
  static const String mobileSubjects = 'api/v1/mobile/subjects';
  static const String mobileSessions = 'api/v1/mobile/sessions';
  static const String onlineScan = 'api/v1/mobile/attendance/scan';
  static String getSessionAttendances(String sessionId) => 'api/v1/mobile/sessions/$sessionId/attendances';
  static const String recordAttendance = 'mobile/attendance';
  static const String offlineBulkRecord = 'mobile/attendance/bulk';
  static const String logout = 'Authentication/logout';
  static const String refreshToken = 'Authentication/refresh-token';

  static const String googleLogin = 'Authentication/google';

  static const String sendOtp = 'send-otp';

  static const String verifyOtp = 'auth/verify-otp';

  static const String resendOtp = 'auth/receive-otp';

  static const String forgotPassword =
      'Authentication/send-reset-password-email';

  static const String validateResetPasswordCode =
      'Authentication/validate-reset-password-code';

  static const String resendConfirmationEmail =
      'Authentication/resend-confirmation-email';

  static const String confirmEmail = 'Authentication/confirm-email';

  static const String resetPassword = 'Authentication/reset-password';

  static const String changePassword = 'Authentication/change-password';

  /// Profile endpoints
  static const String profile = 'profile';
  static const String getCurrentUser = 'Users/me';
  static const String updateFcmToken = 'Notifications/register-token';
  static const String getInAppNotifications = 'InAppNotifications';
  static const String getUnreadNotificationCount =
      'InAppNotifications/unread-count';
  static String markNotificationAsRead(int id) => 'InAppNotifications/$id/read';

  /// Ecommerce endpoints
  static const String getEcommerceHome = 'Ecommerce/home';
  static String getProductDetails(int productId) =>
      'Ecommerce/products/$productId';

  /// Owner endpoints
  static const String createBranch = 'Owner/Branches';

  static String updateBranchWorkingHours(int branchId) =>
      'Owner/Branches/$branchId/working-hours';

  static String updateBranchLocationDetails(int branchId) =>
      'Owner/Branches/$branchId/location-details';

  static const String getBranches = 'Branches';

  static String getBranchDetails(int branchId) => 'Branches/$branchId';

  static String getBranchSetupDetails(int branchId) =>
      'Owner/Branches/$branchId/setup-details';

  static String createPackage(int branchId) =>
      'Owner/Branches/$branchId/packages';

  static String getBranchPackages(int branchId) =>
      'Owner/Branches/$branchId/packages';

  static String getPublicBranchPackages(int branchId) =>
      'Branches/$branchId/packages';

  static String updatePackage(int branchId, int packageId) =>
      'Owner/Branches/$branchId/packages/$packageId';

  static String updatePackageStatus(int branchId, int packageId) =>
      'Owner/Branches/$branchId/packages/$packageId/status';

  static String deletePackage(int branchId, int packageId) =>
      'Owner/Branches/$branchId/packages/$packageId';

  static String addBranchImage(int branchId) =>
      'Owner/Branches/$branchId/images';

  static String activateBranchImages(int branchId) =>
      'Owner/Branches/$branchId/images/activate';

  static String updateBranchImage(int branchId, int imageId) =>
      'Owner/Branches/$branchId/images/$imageId';

  static String updateBranchDetails(int branchId) =>
      'Owner/Branches/$branchId/bussiness-details';

  static String updateBranchStatus(int branchId) =>
      'Owner/Branches/$branchId/status';

  static String getBranchReviews(int branchId) => 'Branches/$branchId/reviews';

  static String addBranchReview(int branchId) => 'Branches/$branchId/reviews';

  static String updateBranchReview(int branchId, int reviewId) =>
      'Branches/$branchId/reviews/$reviewId';

  static String getBranchStatistics(int branchId) =>
      'Owner/Branches/$branchId/statistics';

  static const String getAllBranchesStatistics = 'Owner/Branches/statistics';

  static String addSubscription(int branchId) =>
      'Owner/branches/$branchId/subscriptions';

  static String addMember(int branchId) => 'Owner/branches/$branchId/members';

  static String getBranchSubscriptions(int branchId) =>
      'Owner/Branches/$branchId/subscriptions';

  static String cancelSubscription(int subscriptionId) =>
      'Owner/Subscriptions/$subscriptionId/cancel';

  static String freezeSubscription(int subscriptionId) =>
      'Subscriptions/$subscriptionId/freeze';

  static String unfreezeSubscription(int subscriptionId) =>
      'Subscriptions/$subscriptionId/Unfreeze';

  static String getSubscriptionDetails(int subscriptionId) =>
      'Subscriptions/$subscriptionId';

  static String getMySubscriptionDetails(int subscriptionId) =>
      'users/me/subscriptions/$subscriptionId';

  static String getSubscriptionAttendanceHistory(int subscriptionId) =>
      'Subscriptions/$subscriptionId/attendance-history';

  static const String getMySubscriptions = 'users/me/subscriptions';

  static const String getNearbyBranches = 'Branches/public';

  static const String getGovernorates = 'Governorates';

  static const String addCheckIn = 'CheckIns';

  static const String getRoles = 'employees/roles';

  static String getBranchEmployees(int branchId) =>
      'Owner/Branches/$branchId/employees';

  static const String addEmployee = 'Employees';
  static String updateEmployee(int employeeId) => 'Employees/$employeeId';

  /// Payment endpoints
  static const String initializePayment = 'payments/initialize';
  static String getPaymentTransactionStatus(int transactionId) =>
      'payments/$transactionId';
}
