import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ApiService {
  static const String _baseUrl = "https://66ed1eda380821644cdb715a.mockapi.io/Matrimony";
  ProgressDialog? pd;

  void showProgressDialog(context) {
    if (pd == null) {
      pd = ProgressDialog(context);
      pd!.style(
        message: 'Please Wait',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: SpinKitHourGlass(
          color: Colors.pink,
          size: 60,
        ),
        elevation: 10.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
      );
    }
    pd!.show();
  }

  void dismissProgress() {
    if (pd != null && pd!.isShowing()) {
      pd!.hide();
    }
  }


  Future<List<Map<String, dynamic>>> fetchUsers(context) async {
    showProgressDialog(context);
    final response = await http.get(Uri.parse(_baseUrl));
    dismissProgress();
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  Future<List<Map<String, dynamic>>> fetchUsersc(context) async {
    showProgressDialog(context);
    final response = await http.get(Uri.parse(_baseUrl));
    dismissProgress();
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }


  Future<Map<String, dynamic>> fetchUserById(context,String id) async {
    showProgressDialog(context);
    final response = await http.get(Uri.parse("$_baseUrl/$id"));
    dismissProgress();
    return jsonDecode(response.body);

  }


  Future<bool> isUsernameExists(context,String username) async {
    showProgressDialog(context);
    final response = await http.get(Uri.parse("$_baseUrl?user_Name=$username"));
    dismissProgress();
    final List<dynamic> users = jsonDecode(response.body);
    return users.isNotEmpty;

  }


  Future<bool> addUser(context,Map<String, dynamic> user) async {
    showProgressDialog(context);
    final response = await http.post(
      Uri.parse(_baseUrl),
      body: jsonEncode(user),
      headers: {"Content-Type": "application/json"},
    );
    dismissProgress();
      return response.statusCode == 201;
  }


  Future<bool> updateUser(context,String id, Map<String, dynamic> user) async {
    showProgressDialog(context);

    final response = await http.put(
      Uri.parse("$_baseUrl/$id"),
      body: jsonEncode(user),
      headers: {"Content-Type": "application/json"},
    );
    dismissProgress();
    print("Update Response: ${response.statusCode} - ${response.body}");
    return response.statusCode == 200;

  }


  Future<bool> deleteUser(context,String id) async {
    showProgressDialog(context);
      final response = await http.delete(Uri.parse("$_baseUrl/$id"));
      dismissProgress();
      return response.statusCode == 200;

  }
}
