import 'package:findit/model/models.dart';

class Seller extends User {
  late String cnic;
  late int categoryId;

  Seller({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.password,
    required this.cnic,
    required this.categoryId,
  });

  @override
  Map toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'cnic': cnic,
        'categoryId': categoryId,
        'password': password,
      };
}
