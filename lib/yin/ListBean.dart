class ListBean {
  String name;
  String tagIndex;
  bool isHeader;

  ListBean({
    this.name,
    this.tagIndex,
    this.isHeader = false,
  });

  ListBean.fromJson(Map<String, dynamic> json) : name = json['name'] == null ? "" : json['name'];

  Map<String, dynamic> toJson() => {'name': name, 'tagIndex': tagIndex};

  @override
  String toString() => "ListBean {" + " \"name\":\"" + name + "\"" + '}';
}
