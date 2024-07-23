import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/const/constant.dart';
import 'package:app_doc_sach/model/author_model.dart';
import 'package:app_doc_sach/page/page_admin/author/author_details.dart';
import 'package:app_doc_sach/page/page_admin/author/create_author.dart';
import 'package:app_doc_sach/widgets/side_widget_menu.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DisplayAuthor extends StatefulWidget {
  const DisplayAuthor({Key? key}) : super(key: key);
  @override
  _DisplayAuthorState createState() => _DisplayAuthorState();
}

class _DisplayAuthorState extends State<DisplayAuthor> {
  List<Author> author = [];
  Future<List<Author>> getAll() async {
    // Thực hiện yêu cầu HTTP GET và đợi cho đến khi hoàn thành
    var response = await http.get(Uri.parse("$baseUrl/api/authors/"));

    // In ra mã trạng thái HTTP của phản hồi
    print('Response status: ${response.statusCode}');

    // In ra nội dung phản hồi
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      author.clear();  // Xóa danh sách tác giả hiện tại
    } else {
      print('Failed to fetch authors: ${response.statusCode}');
      return [];
    }

    // Phân tích cú pháp chuỗi JSON
    final decodedData = jsonDecode(response.body);

    // In ra dữ liệu sau khi phân tích cú pháp JSON
    print('Decoded data: $decodedData');

    for (var u in decodedData["data"]) {
      // Kiểm tra từng thuộc tính trước khi thêm vào danh sách
      print('Data item: $u');

      var id = u['id'];
      var authorName = u['attributes']["authorName"] ?? '';
      var birthDateStr = u['attributes']["birthDate"];
      var birthDate = DateTime.tryParse(birthDateStr ?? '') ?? DateTime.now();
      var born = u['attributes']["born"] ?? '';
      var telphone = u['attributes']["telephone"] ?? '';
      var nationality = u['attributes']["nationality"] ?? '';
      var bio = u['attributes']["bio"] ?? '';

      // In ra từng thuộc tính để kiểm tra giá trị
      print('id: $id');
      print('authorName: $authorName');
      print('birthDateStr: $birthDateStr');
      print('birthDate: $birthDate');
      print('born: $born');
      print('telphone: $telphone');
      print('nationality: $nationality');
      print('bio: $bio');

      author.add(Author(
        id: id,
        authorName: authorName,
        birthDate: birthDate,
        born: born,
        telphone: telphone,
        nationality: nationality,
        bio: bio,
      ));
    }

    // In ra danh sách tác giả sau khi thêm tất cả mục dữ liệu
    print('Author list: $author');

    return author;
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
        title: const Text('Quản lý tác giả'),
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
                    MaterialPageRoute(builder: (_) => CreateAuthor()));
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
        builder: (context, AsyncSnapshot<List<Author>> snapshot) {
          //kiểm tra xem trạng thái kết nối của snapshot có đang ở chế độ chờ đợi hay không.
          //ConnectionState.waiting nghĩa là đang chờ để nhận dữ liệu từ nguồn dữ liệu.
          //(snapshot là dự liệu sao lưu được lấy từ api)
          // Check if the connection is in waiting state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              //CircularProgressIndicator() là một biểu tượng vòng tròn quay,
              //thường được sử dụng để chỉ ra rằng ứng dụng đang chờ đợi một hoạt động nào đó hoàn thành.
              // CircularProgressIndicator is a loading spinner
              child: CircularProgressIndicator(),
            );
          }
          // Check if the snapshot has an error
          else if (snapshot.hasError) {
            return Center(
              child: Text('An error occurred: ${snapshot.error}'),
            );
          }
          // Check if the snapshot has data
          else if (snapshot.hasData) {
            // Check if the data is empty
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Không tìm thấy tác giả'),
              );
            } else {
              // Render your data if available
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, index) => InkWell(
                  child: ListTile(
                    title: Text(snapshot.data![index].authorName),
                    subtitle: Text(snapshot.data![index].bio),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AuthorDetails(
                            authors: snapshot.data![index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          }
          // If none of the above conditions match, return an empty container
          else {
            return const Center(
              child: Text('Không tìm thấy tác giả'),
            );
          }
        },
      ),
    );
  }
}
