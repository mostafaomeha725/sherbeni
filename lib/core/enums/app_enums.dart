enum RegisterType { customer, business }

enum OtpSource { customer, business }

enum OtpPurpose { resetPassword, confirmEmail }

enum GymType { menOnly, womenOnly, mixed }

enum SubscriptionTab { all, active, expired, frozen, cancelled, scheduled }

extension SubscriptionTabExtension on SubscriptionTab {
  int? get backendStatus {
    switch (this) {
      case SubscriptionTab.scheduled:
        return 0;
      case SubscriptionTab.active:
        return 1;
      case SubscriptionTab.frozen:
        return 2;
      case SubscriptionTab.expired:
        return 3;
      case SubscriptionTab.cancelled:
        return 4;
      case SubscriptionTab.all:
        return null;
    }
  }
}

enum RequestState { init, loading, success, error }

enum PreferencesKeys {
  currentLanguage,
  currentCurrency,
  fcmToken,
  uuid,
  name,
  picture,
  email,
  phone,
  userToken,
  refreshToken,
  userIsAdmin,
  userSecretKey,
  userId,
  userType,
  roleId,
  isEmailConfirmed,
  branchName,
  branchId,
  userProfile,
  hasSeenOnBoarding,
  needsLocationPrompt,
}

/// Roles:
/// - customer  → userType = 4
/// - owner     → userType = 2
/// - branchAdmin → userType = 3, roleId = 1
/// - gator     → userType = 3, roleId = 2
enum AppUserRole { customer, owner, branchAdmin, gator }
