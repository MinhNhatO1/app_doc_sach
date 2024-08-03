import 'dart:async';
import 'dart:convert';
import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/page/page_admin/book/slideleftroutes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../model/author_model.dart';
import '../../../widgets/side_widget_menu.dart';
import 'author_details.dart';
import 'create_author.dart';


class DisplayAuthor extends StatefulWidget {
  const DisplayAuthor({Key? key}) : super(key: key);

  @override
  _DisplayAuthorState createState() => _DisplayAuthorState();
}

class _DisplayAuthorState extends State<DisplayAuthor> {
  List<Author> _authors = [];
  Future<List<Author>>? _authorsFuture;
  final TextEditingController _searchController = TextEditingController();
  late Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadAuthors();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadAuthors();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthors() async {
    try {
      final authors = await getAll();
      if (!mounted) return;
      setState(() {
        _authors = authors;
      });
    } catch (e) {
      print('Error loading authors: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải tác giả. Vui lòng thử lại sau.')),
      );
    }
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<Author> get filteredAuthors {
    return _searchController.text.isEmpty
        ? _authors
        : _authors
            .where((author) => author.authorName
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
  }

  Future<List<Author>> getAll() async {
    var response = await http.get(Uri.parse("$baseUrl/api/authors/"));
    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      _authors.clear();
      for (var u in decodedData["data"]) {
        var id = u['id'];
        var authorName = u['attributes']["authorName"] ?? '';
        var birthDateStr = u['attributes']["birthDate"];
        var birthDate = DateTime.tryParse(birthDateStr ?? '') ?? DateTime.now();
        var born = u['attributes']["born"] ?? '';
        var telphone = u['attributes']["telephone"] ?? '';
        var nationality = u['attributes']["nationality"] ?? '';
        var bio = u['attributes']["bio"] ?? '';

        _authors.add(Author(
          id: id,
          authorName: authorName,
          birthDate: birthDate,
          born: born,
          telphone: telphone,
          nationality: nationality,
          bio: bio,
        ));
      }
    } else {
      print('Failed to fetch authors: ${response.statusCode}');
      return [];
    }
    return _authors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tác giả'),
        elevation: 0.0,
        backgroundColor: backgroundColor,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(SlideLeftRoute(page: const CreateAuthor()));
              },
              child: const Text(
                'Tạo mới',
                style: TextStyle(fontSize: 16),
              ),
            ),
          )

        ],
      ),
      drawer: const SideWidgetMenu(),
      body: Padding(
        padding: const EdgeInsets.only(right: 13, left: 13, bottom: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tác giả',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _authorsFuture ??= getAll(),
                builder: (context, AsyncSnapshot<List<Author>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('An error occurred: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không tìm thấy tác giả'));
                    } else {
                      return ListView.separated(
                        itemCount: filteredAuthors.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (BuildContext context, index) {
                          final author = filteredAuthors[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AuthorDetails(authors: author),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        author.authorName.isNotEmpty ? author.id.toString() : '?',
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            author.authorName,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                'Quốc tịch: ', // Nhãn cho quốc tịch
                                                style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.bold,fontSize: 16),
                                              ),
                                              Text(
                                                author.nationality,
                                                style: TextStyle(color: Colors.grey.shade300, fontSize: 15),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Mô tả: ', // Nhãn cho mô tả
                                                style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.bold,fontSize: 16),
                                              ),
                                              Text(
                                                author.bio,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: Colors.grey.shade300,fontSize: 15),
                                              ),
                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  } else {
                    return const Center(child: Text('Không tìm thấy tác giả'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
