class MainServiceModel {
  String? image;
  String? mainServiceID;
  String? serviceName;

  MainServiceModel({this.image, this.mainServiceID, this.serviceName});

  MainServiceModel.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    mainServiceID = json['mainServiceID'];
    serviceName = json['serviceName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['mainServiceID'] = mainServiceID;
    data['serviceName'] = serviceName;
    return data;
  }
}
