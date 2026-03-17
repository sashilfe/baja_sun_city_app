class WikiCategory {
  final String id;
  final String title;
  final List<WikiPage> pages;

  WikiCategory({required this.id, required this.title, required this.pages});
}

class WikiPage {
  final String id;
  final String title;
  final String content;

  WikiPage({required this.id, required this.title, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
    };
  }
}
