// // models/user_model.dart
// class User {
//   final int id;
//   final String email;
//   final String name;
//   final DateTime birthDate;
//   final String gender;
//   final String location;
//   final String occupation;
//   final DateTime createdAt;

//   User({
//     required this.id,
//     required this.email,
//     required this.name,
//     required this.birthDate,
//     required this.gender,
//     required this.location,
//     required this.occupation,
//     required this.createdAt,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       email: json['email'],
//       name: json['name'],
//       birthDate: DateTime.parse(json['birthDate']),
//       gender: json['gender'],
//       location: json['location'],
//       occupation: json['occupation'],
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'email': email,
//         'name': name,
//         'birthDate': birthDate.toIso8601String(),
//         'gender': gender,
//         'location': location,
//         'occupation': occupation,
//         'createdAt': createdAt.toIso8601String(),
//       };
// }

class User {
  final int id;
  final String email;
  final String name;
  final DateTime birthDate;
  final String gender;
  final String location;
  final String occupation;
  final DateTime createdAt;
  final int currentPoints;
  final Map<String, dynamic> activities;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.location,
    required this.occupation,
    required this.createdAt,
    required this.currentPoints,
    required this.activities,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      birthDate: DateTime.parse(json['birth_date']),
      gender: json['gender'],
      location: json['location'],
      occupation: json['occupation'],
      createdAt: DateTime.parse(json['created_at']),
      currentPoints: json['current_points'] ?? 0,
      activities: json['activities'] ?? {'participated_surveys': []},
    );
  }
}
