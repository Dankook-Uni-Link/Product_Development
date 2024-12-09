// user_model.dart
class User {
  final int id;
  final String email;
  final String name;
  final DateTime birthDate;
  final String gender;
  final String location;
  final DateTime createdAt;
  final String occupation;

  int getAgeGroup() {
    int age = DateTime.now().year - birthDate.year;
    return (age ~/ 10) * 10;
  }
}
