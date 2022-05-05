// ignore_for_file: file_names

import 'dart:io';
import 'package:demoapp/data/constant.dart';
import 'package:demoapp/data/model/model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RestAPI implements GitHubUserProfile {
  @override
  Future<Output<List<UserProfile>>> fetchUser(int offset, int length) async {
    String url = Urls.userQuery(length, offset);
    try {
      final resp = await http.get(Uri.parse(url));
      final map = json.decode(resp.body);
      final userLst = (map as List).map((e) => UserProfile.fromMap(e));
      final fetchedUsers = userLst.toList();
      return Output(
          report: 'Fetched Data From API',
          isSuccess: true,
          value: fetchedUsers);
    } on FormatException catch (e) {
      return Output(report: 'FormatException: $e', isSuccess: false);
    } on HttpException catch (e) {
      return Output(report: 'HttpException: $e', isSuccess: false);
    } on SocketException catch (e) {
      return Output(report: 'SocketException: $e', isSuccess: false);
    } catch (e) {
      return Output(report: 'Error: $e', isSuccess: false);
    }
  }
}

abstract class GitHubUserProfile {
  Future<Output<List<UserProfile>>> fetchUser(int offset, int length) async =>
      Output(report: '', isSuccess: true, value: []);
}
