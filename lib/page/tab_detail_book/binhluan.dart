import 'package:app_doc_sach/color/mycolor.dart';
import 'package:flutter/material.dart';

import '../../model/comment_model.dart';
import 'package:intl/intl.dart';

class CommentScreen extends StatefulWidget {
  @override
  _CommentScreenState createState() => _CommentScreenState();
}

late final Comment comment;
class _CommentScreenState extends State<CommentScreen> {
  final List<Comment> comments = [
    Comment(
      name: 'Phan Anh Dung',
      date: DateTime(2024, 11, 21),
      content: 'Thật thú vị',
      likes: 25,
      dislikes: 0,
    ),
    Comment(
      name: 'Tran Van Cuong',
      date: DateTime(2024, 2, 11),
      content: 'Truyện rất cuốn tôi đã hài',
      likes: 13,
      dislikes: 4,
    ),
  ];

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

          },
          child: Icon(Icons.add_comment_outlined,color: Colors.white,),
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
    String formattedDate = DateFormat('dd/MM/yyyy').format(comment.date);
    return Container(
      padding: EdgeInsets.all(13.0),
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromRGBO(232, 245, 233,10),
            borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color with opacity
              spreadRadius: 2, // How much the shadow spreads
              blurRadius: 10, // The blur radius of the shadow
              offset: Offset(0, 4), // Offset for the shadow (x, y)
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
                  height: 40,
                    width: 40,
                    child: CircleAvatar(backgroundImage: AssetImage('assets/book/matbiec.png'),
                    radius: 10,)),
                const SizedBox(width: 10,),
                Column(children: [
                  Text(
                    comment.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 25),
                      child: Text(formattedDate,style: TextStyle(fontSize: 11),)),
                ],)

              ],),
              SizedBox(height: 8.0),
              Text(comment.content),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Row(
                    children: [
                      IconButton(icon: Icon(Icons.thumb_up_outlined),
                        onPressed: () {

                        },),
                      Text('${comment.likes}'),
                    ],
                  ),
                  const SizedBox(width: 15,),
                  Row(
                    children: [
                      IconButton(icon: Icon(Icons.thumb_down_outlined),
                        onPressed: () {

                        },),
                      Text('${comment.dislikes}'),
                    ],
                  )

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}