class Category {
  String categoryName;
  int categoryID;

  Category({this.categoryID, this.categoryName});

  Category.fromJson(Map<String, dynamic> json)
      : this(
            categoryID: json['categoryID'], categoryName: json['categoryName']);

  Map<String, dynamic> toJson() =>
      {'categoryID': categoryID, 'categoryName': categoryName};
}