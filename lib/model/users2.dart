final String tableUsers = 'users';

class UserFields {
  static final List<String> values = [
    /// Add all fields
    userId, userName, userPassword
  ];

  static final String userId = '_id';
  static final String userName = 'userName';
  static final String userPassword = 'userPassword';
}

class User {
  final int? userId;
  final String userName;
  final String userPassword;


  const User({
    this.userId,
    required this.userName,
    required this.userPassword,
  });

  User copy({
    int? userId,
    String? userName,
    String? userPassword,
  }) =>
      User(
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        userPassword: userPassword ?? this.userPassword,
      );

  static User fromJson(Map<String, Object?> json) => User(
        userId: json[UserFields.userId] as int?,
        userName: json[UserFields.userName] as String,
        userPassword: json[UserFields.userPassword] as String,
      );

  Map<String, Object?> toJson() => {
        UserFields.userId: userId,
        UserFields.userName: userName,
        UserFields.userPassword: userPassword,
   };
}
