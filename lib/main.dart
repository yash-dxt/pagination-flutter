import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _dogImages = <String>[];
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    fetchFive();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetch();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pagination Example"),
      ),
      body: _dogImages.length < 5
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _dogImages.clear();
                await fetchFive();
              },
              child: ListView.builder(
                  controller: _scrollController,
                  itemExtent: 200,
                  itemCount: _dogImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _dogImages.length) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return Container(
                      height: 50,
                      child: Image.network("${_dogImages[index]}",
                          fit: BoxFit.cover),
                    );
                  }),
            ),
    );
  }

  fetch() async {
    http.Response response =
        await http.get("https://dog.ceo/api/breeds/image/random");
    if (response.statusCode == 200) {
      setState(() {
        _dogImages.add(jsonDecode(response.body)["message"]);
      });
    } else {
      throw Exception("Sorry, couldn't fetch Image");
    }
  }

  fetchFive() async {
    for (int i = 0; i < 5; i++) {
      await fetch();
    }
  }
}
