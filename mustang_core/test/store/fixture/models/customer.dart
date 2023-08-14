class Customer {
  final String name;
  final int age;

  const Customer({
    required this.name,
    required this.age,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
      };

  Customer.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        age = json['age'];
}
