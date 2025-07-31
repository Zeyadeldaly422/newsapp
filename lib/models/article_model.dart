import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String? id;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final String? sourceName;

  const Article({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.sourceName,
  });

  @override
  List<Object?> get props => [id, title, description, url];

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? '',
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
      'sourceName': sourceName,
    };
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? json['url']?.hashCode.toString() ?? '',
      author: json['author'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
      content: json['content'],
      sourceName: json['source']['name'] ?? json['sourceName'],
    );
  }

  Article copyWith({
    String? id,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
    String? sourceName,
  }) {
    return Article(
      id: id ?? this.id,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      sourceName: sourceName ?? this.sourceName,
    );
  }

  @override
  String toString() {
    return 'Article{id: $id, title: $title, sourceName: $sourceName}';
  }
}

