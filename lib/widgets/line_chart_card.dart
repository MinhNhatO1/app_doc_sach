import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/controller/book_controller.dart';
import 'package:app_doc_sach/model/book_model.dart';
import 'package:app_doc_sach/service/BookService.dart';
import 'package:flutter/material.dart';

class TopFavoriteBooksScreen extends StatefulWidget {
  const TopFavoriteBooksScreen({super.key});

  @override
  _TopFavoriteBooksScreenState createState() => _TopFavoriteBooksScreenState();
}

class _TopFavoriteBooksScreenState extends State<TopFavoriteBooksScreen> {
  late Future<List<Book>> _futureBooks;
  final BookController _bookService = BookController();
  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _futureBooks = _bookService.getBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bookService.getBooks();
      if (!mounted) return;
      setState(() {
        _books = books;
      });
    } catch (e) {
      print('Error loading books: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot load books. Please try again later.')),
      );
    }
  }

  List<Book> _getTopBooks(List<Book> books) {
    books.sort((a, b) => (b.likes ?? 0).compareTo(a.likes ?? 0));
    return books.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: MediaQuery.of(context).size.width * 0.9, // Adjust width as needed
      margin: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top 10 Favorite Books',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              FutureBuilder<List<Book>>(
                future: _futureBooks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No books available');
                  } else {
                    final topBooks = _getTopBooks(snapshot.data!);
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topBooks.length,
                      itemBuilder: (context, index) {
                        final book = topBooks[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          title: Text(book.title ?? 'No title'),
                          subtitle: Text('Likes: ${book.likes ?? 0}'),
                          trailing: book.coverImage != null && book.coverImage!.url.isNotEmpty
                              ? Image.network(
                                  baseUrl + book.coverImage!.url,
                                  width: 40,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.book),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
