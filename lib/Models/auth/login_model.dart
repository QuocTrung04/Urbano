class LoginModels {
  final String phoneNumber;
  final String password;

  LoginModels({required this.phoneNumber, required this.password});

  Map<String, dynamic> toJson() {
    return {'phone_number': phoneNumber, 'password': password};
  }
}
