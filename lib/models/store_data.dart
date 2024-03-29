class StoreData {
  String storeName;
  String address;
  String description;
  List<String>? storeTags;
  String? picture;
  String ownerName;
  
  StoreData(this.storeName, this.address, this.description, this.storeTags, this.picture, this.ownerName);

  String get name {
    return this.storeName;
  }
  String? get add {
    return address;
  }
  String? get desc{
    return description;
  }
  List<String>? get tags {
    return storeTags;
  }
  String get owner {
    return this.ownerName;
  }
}