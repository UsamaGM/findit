class User {
  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.password,
  });

  late String? id;
  late String? firstName;
  late String? lastName;
  late String? email;
  late String? phone;
  late String? password;

  Map toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
      };
}
