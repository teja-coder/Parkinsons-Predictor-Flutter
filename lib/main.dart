
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
      null, // icon for your app notification
      [
        NotificationChannel(
            channelKey: 'key1',
            channelName: 'Proto Coders Point',
            channelDescription: "Notification example",
            defaultColor: Color(0XFF9050DD),
            ledColor: Colors.white,
            playSound: true,
            enableLights:true,
            enableVibration: true
        )
      ]
  );
  runApp(MaterialApp(
    home: HomePage(title: 'Flutter Demo Home Page',),
  ));
}

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double dx=100, dy=100;
  List calDatax = [],calDatay = [];
  List xData = [],yData = [];
  int start = DateTime.now().second;
  int flag = 0,cnt=0;
  double max_dx=0,max_dy=0,min_dx=double.maxFinite,min_dy=double.maxFinite;
  double threshold(double x){
    return 0.8*x;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('PD'),
        ),
        body: StreamBuilder<GyroscopeEvent>(
              stream: SensorsPlatform.instance.gyroscopeEvents,
              builder: (_, snapshot){
              if(snapshot.hasData){
                dx = dx+ (snapshot.data!.y*30);
                dy = dy+ (snapshot.data!.x*30);
                if(DateTime.now().second-start<5){
                  calDatax.add(dx);
                  calDatay.add(dy);
                  max_dx = max(max_dx,dx);
                  min_dx = min(min_dx,dx);
                  max_dy = max(max_dx,dy);
                  min_dy = min(min_dx,dy);
                //  0.8x and 0.8y act as thresholds, when the acceleromer crosses
                //  the threshold for 3 sec, it pushes a notification("you gonna be dead")
                }
                else{
                  int itr=0;
                  max_dx = threshold(max_dx);
                  min_dx = threshold(min_dx);
                  max_dy = threshold(max_dy);
                  min_dy = threshold(min_dy);
                  xData.add(dx);
                  yData.add(dy);
                  print(xData);
                  print(yData);
                  if(dx>=max_dx) {
                    flag = 1;
                  }
                  else if(dx>min_dx) {
                    flag = 0;
                  }
                  if(flag==1){
                    cnt+=1;
                  }
                  itr += 1;
                  if(itr==10){
                    if(cnt>=5){
                        return Notify();
                    }
                  }
                }
              }
              return Transform.translate(offset: Offset(dx,dy),
              child: const CircleAvatar(radius: 20,));
              },
      ),
    );
  }
}

Notify() async {
   AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 1,
          channelKey: 'key1',
          title:'Prediction status',
          body: 'Based on the recent analysis done on your movements, your could be a potential patient of Parkinson\'s disease. Contact a neurophysician ASAP.'
      )
  );
}