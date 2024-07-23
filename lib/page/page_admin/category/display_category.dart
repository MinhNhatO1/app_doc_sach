import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/model/category_model.dart';
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
  _DisplayCategorysState createState() => _DisplayCategorysState();
}

class _DisplayCategorysState extends State<DisplayCategory> {
  List<CategoryModel> category = [];
  Future<List<CategoryModel>> getAll() async {
    // The await keyword pauses the execution of the function until the HTTP request completes.
    var response =
        await http.get(Uri.parse("$baseUrl/api/categories?pagination[pageSize]=100"));
    if (response.statusCode == 200) {
      category.clear();
    }
    //dùng để ptich chuỗi trong json
    final decodedData = jsonDecode(response.body);
    for (var u in decodedData["data"]) {
      category.add(CategoryModel(
         id:  u['id'],nameCategory:  u['attributes']["name"],desCategory:  u['attributes']["Description"]));
    }
    return category;
  }

  //nó sẽ ghi đè lên phương thức state
  @override
  Widget build(BuildContext context) {
    //Gọi hàm getAll để tìm nạp danh sách các danh mục từ máy chủ. Tuy nhiên,
    //nên tránh dòng này vì nó khiến dữ liệu được tìm nạp mỗi khi tiện ích được xây dựng lại,
    // điều này có thể dẫn đến hoạt động kém hiệu quả và hành vi không mong muốn.
    // getAll();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thể loại'),
        elevation: 0.0, // Controls the shadow below the app bar
        backgroundColor: backgroundColor,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: secondaryColor,
                backgroundColor:
                    primaryColor, // Using the custom secondaryColor
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CreateCategory()));
              },
              child: const Text('Create'),
            ),
          )
        ],
      ),
      drawer: const SideWidgetMenu(),
      //xây dựng bản sao dữ liệu mới dựa vào future
      body: FutureBuilder(
          future: getAll(),
          builder: (context, AsyncSnapshot<List<CategoryModel>> snapshot) {
            //kiểm tra xem trạng thái kết nối của snapshot có đang ở chế độ chờ đợi hay không.
            //ConnectionState.waiting nghĩa là đang chờ để nhận dữ liệu từ nguồn dữ liệu.
            //(snapshot là dự liệu sao lưu được lấy từ api)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                //CircularProgressIndicator() là một biểu tượng vòng tròn quay,
                //thường được sử dụng để chỉ ra rằng ứng dụng đang chờ đợi một hoạt động nào đó hoàn thành.
                child: CircularProgressIndicator(),
              );
            }
            // Check if the snapshot has an error
            else if (snapshot.hasError) {
              return Center(
                child: Text('An error occurred: ${snapshot.error}'),
              );
            }// Check if the snapshot has data
              else if (snapshot.hasData) {
              // Check if the data is empty
              if (snapshot.data!.isEmpty) {
              return Center(
              child: Text('Khong tim thay tac gia'),
              );
              }

    //Đoạn mã else này sẽ được thực thi nếu điều kiện snapshot.connectionState == ConnectionState.waiting
            //trong if trước đó là sai, nghĩa là dữ liệu đã sẵn sàng và đã được tải về thành công.
            else {
              return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext context, index) => InkWell(
                        child: ListTile(
                          title: Text(snapshot.data![index].nameCategory),
                          subtitle: Text(snapshot.data![index].desCategory),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => MyDetails(
                                          categories: snapshot.data![index],
                                        )));
                          },
                        ),
                      ));
            }
          }// If none of the above conditions match, return an empty container
    else {
    return const Center(
    child: Text('Khong tim thay tac gia'),
    );
    }})
    );
  }
}
