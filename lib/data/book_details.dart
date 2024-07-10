import 'package:app_doc_sach/const.dart';
import 'package:app_doc_sach/model/author_model.dart';
import 'package:app_doc_sach/model/book_model.dart';
import 'package:app_doc_sach/model/book_statistical_model.dart';
import 'package:app_doc_sach/model/category_model.dart';
import 'package:app_doc_sach/model/user_model.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookDetails {
  late List<BookStatisticalModel> bookData;
  List<Book> allBooks = [];
  List<Author> allAuthors = [];
  List<Users> allUsers = [];
  List<CategoryModel> allCategories = [];

  BookDetails() {
    // Initialize the statistics with current counts
    
    bookData = [
      BookStatisticalModel(icon: 'assets/icon/books.png', value: allBooks.length, title: "Books"),
      BookStatisticalModel(icon: 'assets/icon/author.png', value: allAuthors.length, title: "Authors"),
      BookStatisticalModel(icon: 'assets/icon/User_icon_2.svg.png', value: allUsers.length, title: "Users"),
      BookStatisticalModel(icon: 'assets/icon/category.png', value: allCategories.length, title: "Categories"),
    ];

    // Example of adding authors (you should replace this with your actual data fetching logic)
    // Update statistics after adding authors
    fetchBooksFromStrapi();
    fetchAuthorsFromStrapi();
    fetchUsersFromStrapi();
    fetchCategoriesFromStrapi();
  }

  Future<void> fetchBooksFromStrapi() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/books/'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> booksJson = jsonResponse['data']; // Adjust 'data' to your actual field name
        allBooks = booksJson.map((bookJson) => Book.fromJson(bookJson)).toList();
        print('Fetched books: ${allBooks.length}'); // Debug statement
        updateBookStatistics();
      } else {
        // Handle error
        print('Failed to load books');
      }
    } catch (e) {
      // Handle error
      print('Error fetching books: $e');
    }
  }

  Future<void> fetchAuthorsFromStrapi() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/authors/'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> authorsJson = jsonResponse['data']; // Adjust 'data' to your actual field name
        allAuthors = authorsJson.map((authorJson) => Author.fromJson(authorJson)).toList();
        print('Fetched authors: ${allAuthors.length}'); // Debug statement
        updateAuthorStatistics();
      } else {
        // Handle error
        print('Failed to load authors');
      }
    } catch (e) {
      // Handle error
      print('Error fetching authors: $e');
    }
  }

   Future<void> fetchUsersFromStrapi() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/profiles/'));
      if (response.statusCode == 200) {
        //Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> usersJson = jsonDecode(response.body); // Adjust 'data' to your actual field name
        allUsers = usersJson.map((userJson) => Users.fromJson(userJson)).toList();
        print('Fetched Users: ${allUsers.length}'); // Debug statement
        updateUsersStatistics();
      } else {
        // Handle error
        print('Failed to load users');
      }
    } catch (e) {
      // Handle error
      print('Error fetching users: $e');
    }
  }

  Future<void> fetchCategoriesFromStrapi() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/categories/'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> categoriesJson = jsonResponse['data']; // Adjust 'data' to your actual field name
        allCategories = categoriesJson.map((categoryJson) => CategoryModel.fromJson(categoryJson)).toList();
        print('Fetched Categories: ${allCategories.length}'); // Debug statement
        updateCategoriesStatistics();
      } else {
        // Handle error
        print('Failed to load Categories');
      }
    } catch (e) {
      // Handle error
      print('Error fetching Categories: $e');
    }
  }

  
  void updateAuthorStatistics() {
    int authorIndex = bookData.indexWhere((model) => model.title == "Authors");
    if (authorIndex != -1) {
      bookData[authorIndex].value = allAuthors.length;
      // print('Updated authors statistics: ${bookData[authorIndex].value}'); // Debug statement
    }
  }

  void updateBookStatistics() {
    int bookIndex = bookData.indexWhere((model) => model.title == "Books");
    if (bookIndex != -1) {
      bookData[bookIndex].value = allBooks.length;
    }
  }

   void updateUsersStatistics() {
    int userIndex = bookData.indexWhere((model) => model.title == "Users");
    if (userIndex != -1) {
      bookData[userIndex].value = allUsers.length;
    }
  }

  void updateCategoriesStatistics() {
    int categoryIndex = bookData.indexWhere((model) => model.title == "Categories");
    if (categoryIndex != -1) {
      bookData[categoryIndex].value = allCategories.length;
    }
  }

  

  void addBook(Book book) {
    allBooks.add(book);
    updateBookStatistics();
  }

  void removeBook(Book book) {
    allBooks.remove(book);
    updateBookStatistics();
  }

  void addAuthor(Author author) {
    allAuthors.add(author);
    updateAuthorStatistics();
  }

  void removeAuthor(Author author) {
    allAuthors.remove(author);
    updateAuthorStatistics();
  }

  // Method to get the total number of authors
  int getTotalAuthors() {

    return allAuthors.length;
  }
}
