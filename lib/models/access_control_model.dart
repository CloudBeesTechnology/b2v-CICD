class AccessControl {
  final String empID;
  final String email;
  final String role;
  final Map<String, dynamic> setPermission;

  AccessControl({
    required this.empID,
    required this.email,
    required this.role,
    required this.setPermission,
  });

  factory AccessControl.fromMap(Map<String, dynamic> map) {
    return AccessControl(
      empID: map['empID'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      setPermission: map['setPermission'] as Map<String, dynamic>,
    );
  }
}