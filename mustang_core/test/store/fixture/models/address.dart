class Address {
  final String country;
  final String state;
  final String street;

  const Address({
    required this.country,
    required this.state,
    required this.street,
  });

  Map<String, dynamic> toJson() => {
        'country': country,
        'state': state,
        'street': street,
      };

  Address.fromJson(Map<String, dynamic> json)
      : country = json['country'],
        state = json['state'],
        street = json['street'];
}
