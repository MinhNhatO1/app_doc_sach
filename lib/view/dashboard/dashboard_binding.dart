import 'package:app_doc_sach/controller/auth_controller.dart';
import 'package:app_doc_sach/controller/author_controller.dart';
import 'package:app_doc_sach/controller/book_controller.dart';
import 'package:app_doc_sach/controller/category_controller.dart';
import 'package:app_doc_sach/controller/chapter_controller.dart';

import 'package:get/get.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(BookController());
    Get.put(AuthorController());
    Get.put(CategoryController());
    Get.put(ChapterController());
  }

}