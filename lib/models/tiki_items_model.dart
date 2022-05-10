
// factory TikiQuickItem.fromJson(Map<String, dynamic> data){
//   return TikiQuickItem(data['title'], data['content'], data['image_url'],);
// }

class TikiQuickItem {
  late final String title;
  late final String content;
  late final String image_url;

  TikiQuickItem(this.title, this.content, this.image_url);
  factory TikiQuickItem.fromMap(Map<String, dynamic> json) {
    return TikiQuickItem(
      json['title'],
      json['content'],
      json['image_url'],
    );
  }
}

