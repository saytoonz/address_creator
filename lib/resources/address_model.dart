class Address {
  String? address;
  String? lat;
  String? lng;

  Address({
    this.address,
    this.lat,
    this.lng,
  });

  Address.fromMap(dynamic map) {
    address = map["address"];
    lat = map["lat"];
    lng = map["lng"];
  }
}
