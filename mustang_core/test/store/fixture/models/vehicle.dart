class Vehicle {
  final int year;
  final String make;
  final String model;
  final String trim;

  const Vehicle({
    required this.year,
    required this.make,
    required this.model,
    required this.trim,
  });

  Map<String, dynamic> toJson() => {
        'year': year,
        'make': make,
        'model': model,
        'trim': trim,
      };

  Vehicle.fromJson(Map<String, dynamic> json)
      : year = json['name'],
        make = json['make'],
        model = json['model'],
        trim = json['trim'];
}
