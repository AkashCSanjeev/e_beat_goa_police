class ExistingRoute {
  String routeName, routeDescription;
  List<Area> area;
  String id, city;

  ExistingRoute(
      this.routeName, this.routeDescription, this.area, this.id, this.city);
}

class Area {
  String name, city, id;
  Area(this.name, this.city, this.id);

  static Area fromjson(Map<String, dynamic> json) =>
      Area(json['name'], json['city'], json['_id']);
}

class City {
  List<Area> cityList = [];
  City() {
    cityList.add(Area("ponda pity", "ponda", "0"));
    cityList.add(Area("farmagudi", "ponda", "1"));
    cityList.add(Area("durbhat", "ponda", "2"));
    cityList.add(Area("market", "ponda", "3"));
    cityList.add(Area("madgao City", "madgao", "4"));
    cityList.add(Area("arlem Circle", "madgao", "5"));
  }
}
