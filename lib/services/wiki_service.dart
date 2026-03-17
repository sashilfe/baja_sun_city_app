import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/models/Wiki.dart';
import 'dart:async';

class WikiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches a stream of wiki categories and their pages from Firestore.
  ///
  /// This method assumes you have a Firestore structure like this:
  ///
  /// - A collection named `wiki_categories`
  ///   - Each document has a `title` field (String).
  /// - A collection named `wiki_pages`
  ///   - Each document has:
  ///     - a `title` field (String)
  ///     - a `content` field (String)
  ///     - a `categoryId` field (String) which is the ID of the category it belongs to.
  Stream<List<WikiCategory>> getCategories() {
    return _db
        .collection('wiki_categories')
        .snapshots()
        .asyncMap((categorySnapshot) async {
      final categories =
          await Future.wait(categorySnapshot.docs.map((categoryDoc) async {
        final categoryData = categoryDoc.data();
        final pagesSnapshot = await _db
            .collection('wiki_pages')
            .where('categoryId', isEqualTo: categoryDoc.id)
            .get();

        final pages = pagesSnapshot.docs.map((pageDoc) {
          final pageData = pageDoc.data();
          return WikiPage(
            id: pageDoc.id,
            title: pageData['title'] ?? '',
            content: pageData['content'] ?? '',
          );
        }).toList();

        return WikiCategory(
          id: categoryDoc.id,
          title: categoryData['title'] ?? '',
          pages: pages,
        );
      }).toList());

      return categories;
    });
  }

  Future<void> addCategory(String title) {
    return _db.collection('wiki_categories').add({'title': title});
  }

  Future<void> addPage(String title, String content, String categoryId) {
    return _db.collection('wiki_pages').add({
      'title': title,
      'content': content,
      'categoryId': categoryId,
    });
  }

  Future<void> updatePage(String pageId, String title, String content) {
    return _db.collection('wiki_pages').doc(pageId).update({
      'title': title,
      'content': content,
    });
  }

  Future<void> deletePage(String pageId) {
    return _db.collection('wiki_pages').doc(pageId).delete();
  }
}
