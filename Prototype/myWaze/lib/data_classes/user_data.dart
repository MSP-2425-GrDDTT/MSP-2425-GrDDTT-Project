// lib/data_classes/user_data.dart
class UserData {
  String? email;
  String name;
  String password;
  bool isLoggedIn;

  // Private constructor to prevent direct instantiation
  UserData._privateConstructor({
    required this.email,
    required this.name,
    required this.password,
    required this.isLoggedIn,
  });

  // TODO warning: the user class will only be a singleton for now

  // Static instance for the singleton
  static UserData? _instance;

  // Public getter for the singleton instance
  static UserData get instance {
    _instance ??= UserData._privateConstructor(
      email: null,
      name: '',
      password: '',
      isLoggedIn: false,
    );
    return _instance!;
  }

  // Method to initialize UserData
  void initialize({
    required String email,
    required String name,
    required String password,
  }) {
    _instance = UserData._privateConstructor(
      email: email,
      name: name,
      password: password,
      isLoggedIn: true
    );
  }

  // Method to reset the UserData
  void clear() {
    _instance = null;
  }

  String getUserInfo() {
    return 'Email: $email, Name: $name';
  }
}
