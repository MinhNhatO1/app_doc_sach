import 'dart:convert';
import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/model/book_model.dart';
import 'package:http/http.dart' as http;

class BookService {
  Future<List<Book>> fetchTopBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/api/books/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) {
        try {
          return Book.fromJson({
            'id': json['id'],
            ...json['attributes'] ?? {},
            'coverImage': json['attributes']['coverImage'] != null
                ? {
                    'url': json['attributes']['coverImage']['data']['attributes']['url']
                  }
                : null,
          });
        } catch (e, stackTrace) {
          print('Error parsing book: $e');
          print('Stack trace: $stackTrace');
          print('Problematic JSON: $json');
          return null;
        }
      }).whereType<Book>().toList();
    } else {
      throw Exception('Failed to load books');
    }
  }
}
