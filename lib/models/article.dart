class Article {
  final String title;
  final String? description;
  final String? urlToImage;
  final String sourceName;

  Article({
    required this.title,
    this.description,
    this.urlToImage,
    required this.sourceName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'],
      urlToImage: json['urlToImage'],
      sourceName: json['source'] != null ? json['source']['name'] : 'Unknown Source',
    );
  }
}