import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:git_commit_list/network/api_manager.dart';
import 'package:git_commit_list/resources/theme.dart';

import 'resources/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (Platform.isAndroid) {
      return MaterialApp(
        title: 'Task',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'GitHub API'),
      );
    } else if (Platform.isIOS) {

      return MaterialApp(
        title: 'Task',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'GitHub API'),
      );
    }
    return MaterialApp(
      title: 'Task',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'GitHub API'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<dynamic> commits = [];

  List author = [];
  List msg = [];
  List hashNo = [];

  bool isLoading = false;

  @override
  void initState() {
    getCommit();
    super.initState();
  }

  void getCommit() {
    isLoading = true;
    author.clear();
    msg.clear();
    hashNo.clear();

    ApiManager.getCommits().then((value) {
      if (value.statusCode == 200) {
        try {
          List<dynamic> res = jsonDecode(value.body);

          commits = res;


          for (var message in commits) {

            String mes = message['commit']['message'];
            int hasPosition = mes.indexOf("#");
            author.add(mes.substring(0, hasPosition - 1));
            msg.add(mes.substring(0, hasPosition - 1));

            String aStr = mes.substring(hasPosition, hasPosition + 6).replaceAll(new RegExp(r'[^0-9]'),'');
            int aInt = int.parse(aStr);
            hashNo.add(aInt.toString());

          }
          isLoading = false;
          setState(() {});
        } catch (e) {
          print("inBodyError" + e.toString());
        }
      } else if (value.statusCode == 401) {
        print("statusCode " + value.statusCode.toString());
      } else {
        print("inBodyError");
      }
    }).catchError((onError) {
      print("outBodyError : ");
    });
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xffdbdbdb),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppTheme.themeColor,
        elevation: 2,
      ),
      body: !isLoading?ListView.builder(
        itemCount: commits.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: _size.width/30,vertical: _size.width/70),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white
              ),
              child: Padding(
                padding: EdgeInsets.all(_size.width/30),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(commits[index]['author']['avatar_url']),
                      maxRadius: _size.width/15,
                    ),
                    SizedBox(width: _size.width/30,),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex:1,
                                child: Text(
                                  commits[index]['commit']['author']['name'],
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: AppTheme.hashNoColor
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 1.0,horizontal: 3),
                                  child: Text(
                                    "#${hashNo[index]}",
                                    style: TextStyle(
                                        color: AppTheme.hashTxtColor,
                                        fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            msg[index],
                            maxLines: 2,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ):Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.themeColor,),
          SizedBox(height: _size.width/20,),
          Text(
            "Please wait...",
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),),
    );
  }
}
