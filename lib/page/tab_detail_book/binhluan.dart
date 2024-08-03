import 'dart:convert';

import 'package:app_doc_sach/color/mycolor.dart';
import 'package:app_doc_sach/const.dart';
import 'package:flutter/material.dart';

import '../../model/comment_model2.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
class CommentScreen extends StatefulWidget {

  final String bookId;
  const CommentScreen({super.key,required this.bookId});
  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final List<Comment> comments = [];
  @override
  void initState() {
    super.initState();
    fetchComments(widget.bookId.toString());
  }
  Future<void> fetchComments(String bookId) async {
    final url = '$baseUrl/api/comments?filters[book][id]=$bookId&populate[profile][publicationState]=preview&publicationState=preview&populate[book]=*';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data'); // In dữ liệu JSON để kiểm tra cấu trúc

        final commentData = data['data'] as List;
        setState(() {
          comments.addAll(commentData.map((json) => Comment.fromJson(json)).toList());
          print('Comments list: $comments');
        });
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return CommentTile(comments[index]);
              },
            ),
            SizedBox(height: 100), // Khoảng trống để đọc sách nút không bị che
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {
            // Thêm hành động cho nút cộng thêm
          },
          child: Icon(Icons.add_comment_outlined, color: Colors.white),
          backgroundColor: MyColor.primaryColor,
        ),
      ),
    );
  }
}


class CommentTile extends StatelessWidget {
  final Comment comment;

  const CommentTile(this.comment, {super.key});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(comment.dateComment);

    return Container(
      padding: EdgeInsets.all(13.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(232, 245, 233, 1),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  height: 45,
                  width: 45,
                  child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          comment.profile?.avatar != null ? baseUrl + comment.profile!.avatar! : 'assets/book/matbiec.png'
                      )

                  ),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    comment.profile!.fullName ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: Text(formattedDate, style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,)),
                  ),
                ]),
              ]),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.all(10),
                  child: Text(comment.text ?? '',style: const TextStyle(fontSize: 16),)),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up_outlined),
                        onPressed: () {
                          // Thêm hành động cho nút thích
                        },
                      ),
                     /* Text('${comment.likes ?? 0}'),*/
                    ],
                  ),
                  const SizedBox(width: 15),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.thumb_down_outlined),
                        onPressed: () {
                          // Thêm hành động cho nút không thích
                        },
                      ),
                      /*Text('${comment.dislikes ?? 0}'),*/
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
