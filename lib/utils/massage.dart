/// this class is used to represent a massage in a chat
class Massage {
  String? massage;
  MassageRole role;

  Massage({this.massage, required this.role});

  /// returns a map with the data of the massage
  Map<String, dynamic> getMassage() {
    return {"role": role.role, "content": massage};
  }
}

/// this enum is used to represent the role of a massage
enum MassageRole {
  system,
  user,
  assistant,
}

/// this extension is used to get the string representation of a massage role
extension MassageRoleExtension on MassageRole {
  String get role {
    switch (this) {
      case MassageRole.system:
        return "system";
      case MassageRole.user:
        return "user";
      case MassageRole.assistant:
        return "assistant";
    }
  }
}