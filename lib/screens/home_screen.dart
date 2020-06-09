import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:rutorrentflutter/components/task_tile.dart';
import 'dart:convert';

import 'package:rutorrentflutter/models/task.dart';

import '../constants.dart';

class HomeScreen extends StatefulWidget {
  static String url = 'https://fremicro081.xirvik.com/rtorrent/plugins/httprpc/action.php';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Stream<List<Task>> _initTasksData() async* {
    while(true) {

      await Future.delayed(Duration(seconds: 1),(){
      });

      List<Task> tasksList = [];
      var response = await http.post(Uri.parse(HomeScreen.url),
          headers: {
            'authorization':Constants().getBasicAuth(),
          },
          body: {
            'mode': 'list',
          },
          encoding: Encoding.getByName("utf-8"));
//      print(response.statusCode);
//      print(response.body);

      var tasksPath = jsonDecode(response.body)['t'];
      for (var hashKey in tasksPath.keys) {
        var taskObject = tasksPath[hashKey];
        Task task = Task(hashKey); // new task created
        task.name = taskObject[4];
        task.size = filesize(taskObject[5]);
        task.savePath = taskObject[25];
        task.status = int.parse(taskObject[0])==0?(Status.stopped):(int.parse(taskObject[3])==0?(Status.pausing):Status.downloading);
        task.remainingContent = filesize(taskObject[19]);
        task.completedChunks = int.parse(taskObject[6]);
        task.totalChunks = int.parse(taskObject[7]);
        task.sizeOfChunk = int.parse(taskObject[13]);
        task.torrentAdded = int.parse(taskObject[21]);
        task.torrentCreated = int.parse(taskObject[26]);
        task.seedsActual = int.parse(taskObject[18]);
        task.peersActual = int.parse(taskObject[15]);
        task.ulSpeed = int.parse(taskObject[11]);
        task.dlSpeed = int.parse(taskObject[12]);

        tasksList.add(task);
      }
      yield tasksList;
    }
  }

  @override
  void initState() {
    super.initState();
    _initTasksData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.solidMoon),
            onPressed: (){
              Fluttertoast.showToast(msg: "Night mode currently unavailable");
              _initTasksData();
            },
          ),
        ],
      ),
      drawer: Drawer(),
      body: Container(
        child: StreamBuilder(
          stream: _initTasksData(),
          builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot){
            if(!snapshot.hasData){
              return Center(child: Text('No Tasks to Show'),);
            }
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context,int index){
                return TaskTile(snapshot.data[index]);
              },
            );
          },
        )
      ),
    );
  }
}
