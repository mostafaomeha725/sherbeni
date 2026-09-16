// import 'package:gymbook/core/cache/preferences_storage.dart';
// import 'package:gymbook/core/enums/app_enums.dart';

// class UserRoleService {
//   final PreferencesStorage _storage;

//   UserRoleService(this._storage);

//   AppUserRole getCurrentRole() {
//     final int userType = _storage.getUserType() ?? 4;
//     final int? roleId = _storage.getRoleId();

//     switch (userType) {
//       case 2:
//         return AppUserRole.owner;
//       case 3:
//         if (roleId == 2) return AppUserRole.gator;
//         return AppUserRole.branchAdmin;
//       case 4:
//       default:
//         return AppUserRole.customer;
//     }
//   }

//   bool get isCustomer => getCurrentRole() == AppUserRole.customer;
//   bool get isOwner => getCurrentRole() == AppUserRole.owner;
//   bool get isBranchAdmin => getCurrentRole() == AppUserRole.branchAdmin;
//   bool get isGator => getCurrentRole() == AppUserRole.gator;

//   int? getBranchId() => _storage.getBranchId();
//   String? getBranchName() => _storage.getBranchName();
// }
