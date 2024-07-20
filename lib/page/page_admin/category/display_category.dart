import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/model/category_model.dart';
import 'package:app_doc_sach/page/page_admin/book/slideleftroutes.dart';
import 'package:app_doc_sach/page/page_admin/category/category_details.dart';
import 'package:app_doc_sach/page/page_admin/category/create_category.dart';
import 'package:app_doc_sach/widgets/side_widget_menu.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../const.dart';

class DisplayCategory extends StatefulWidget {
  const DisplayCategory({Key? key}) : super(key: key);

  @override
  _DisplayCategoryState createState() => _DisplayCategoryState();
}

class _DisplayCategoryState extends State<DisplayCategory> {
  List<CategoryModel> category = [];
  final TextEditingController _searchController = TextEditingController();
  List<CategoryModel> _filteredCategories = [];

  Future<List<CategoryModel>> getAll() async {
    var response = await http.get(Uri.parse("$baseUrl/api/categories?pagination[pageSize]=100"));
    if (response.statusCode == 200) {
      category.clear();
    }
    final decodedData = jsonDecode(response.body);
    for (var u in decodedData["data"]) {
      category.add(CategoryModel(
        id: u['id'],
        nameCategory: u['attributes']["name"],
        desCategory: u['attributes']["Description"],
      ));
    }
    return category;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredCategories = category
          .where((cat) => cat.nameCategory.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thể loại'),
        elevation: 0.0, // Controls the shadow below the app bar
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(SlideLeftRoute(page: const CreateCategory()));
              },
              child: const Text('Tạo mới'),
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
                  hintText: 'Tìm kiếm thể loại',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: getAll(),
                builder: (context, AsyncSnapshot<List<CategoryModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('An error occurred: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Không tìm thấy thể loại'),
                      );
                    } else {
                      if (_searchController.text.isEmpty) {
                        _filteredCategories = snapshot.data!;
                      }
                      return ListView.builder(
                        itemCount: _filteredCategories.length,
                        itemBuilder: (BuildContext context, index) => InkWell(
                          child: ListTile(
                            title: Text(_filteredCategories[index].nameCategory),
                            subtitle: Text(_filteredCategories[index].desCategory),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MyDetails(
                                    categories: _filteredCategories[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  } else {
                    return const Center(
                      child: Text('Không tìm thấy thể loại'),
                    );
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
