class EmployeeDetails {
  final String empID;
  final String name;
  final String? profilePhoto;  // Changed from profilePicUrl to profilePhoto

  EmployeeDetails({
    required this.empID,
    required this.name,
    this.profilePhoto,  // Changed here
  });

  factory EmployeeDetails.fromMap(Map<String, dynamic> map) {
    return EmployeeDetails(
      empID: map['empID'] as String,
      name: map['name'] as String,
      profilePhoto: map['profilePhoto'] as String?,  // Changed here
    );
  }
}