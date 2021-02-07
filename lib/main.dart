import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:radius/scenes/user/menu.dart';
import 'package:radius/scenes/user/home.dart';

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nearby',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              // User
              child: Column(
                children: [
                  Container(
                    child: Text(
                      "User",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    padding: EdgeInsets.only(
                      top: 5,
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Open Homepage'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text(
                      'Open Menu 45%',
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Menu()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('Open Cart'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Menu()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('Open Receipt'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Menu()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('Open Order Info'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Menu()),
                      );
                    },
                  ),
                ],
              ),
            ), //----------------------End of User
            Container(
              //-----------------Owner
              child: Column(
                children: [
                  Container(
                    child: Text(
                      "Owner",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    padding: EdgeInsets.only(
                      top: 5,
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Open Homepage'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Menu()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('Open Menu 25%'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Menu()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('Open Order Info'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Menu()),
                      );
                    },
                  ),
                ],
              ),
            ) //---------------------------End of Owner
          ],
        ),
      ),
    );
  }
}
