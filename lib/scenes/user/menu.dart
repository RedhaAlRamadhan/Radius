import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:radius/widgets/menu/provincelist.widget.dart';
import 'package:radius/widgets/menu/popularlist.widget.dart';
import 'package:radius/model/resturant.dart';

class Menu extends StatelessWidget {
  Resturant resturant;
  Menu({Key key, @required Resturant resturant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = resturant.title;

    return MaterialApp(
      title: title,
      home: Scaffold(
        // No appbar provided to the Scaffold, only a body with a
        // CustomScrollView.
        appBar: buildAppBar(title),
        body: CustomScrollView(
          slivers: <Widget>[
            // Add the app bar to the CustomScrollView.
            SliverAppBar(
              // Provide a standard title.

              // title: Text(title),
              // backgroundColor: Color(0xFFFFFF),

              // Allows the user to reveal the app bar if they begin scrolling
              // back up the list of items.
              backgroundColor: Colors.black54,
              floating: false,
              pinned: false,
              snap: false,
              // Display a placeholder widget to visualize the shrinking size.
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: <StretchMode>[
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
                // centerTitle: true,
                // title: Text(title),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      '',
                      fit: BoxFit.cover,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, 0.5),
                          end: Alignment(0.0, 0.0),
                          colors: <Color>[
                            Color(0x60000000),
                            Color(0x00000000),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Make the initial height of the SliverAppBar larger than normal.
              expandedHeight: 400,
            ),
            // Next, create a SliverList
            SliverPersistentHeader(
              pinned: true,
              delegate: PersistentHeader(
                widget: Column(
                  // Format this to meet your need
                  children: <Widget>[
                    ProvinceList(),
                  ],
                ),
              ),
            ),
            SliverList(
              // Use a delegate to build items as they're scrolled on screen.
              delegate: SliverChildBuilderDelegate(
                // The builder function returns a ListTile with a title that
                // displays the index of the current item.
                (content, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 2.5,
                      horizontal: 5,
                    ),
                    // child: SizedBox(
                    //   height: 100,
                    child: Card(
                      elevation: 2.5,
                      semanticContainer: true,
                      child: ListTile(
                        contentPadding: EdgeInsets.only(right: 10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.network(resturant.imageURL),
                        ),
                        title: Text(resturants[0].items[index].title),
                        onTap: () => {Navigator.pop(context)},
                        trailing:
                            Text(resturants[0].items[index].price.toString()),
                      ),
                    ),
                    // ),
                  );
                },
                // Builds 1000 ListTiles
                childCount: resturants[0].items.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(String title) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 5,
      title: Container(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 25,
            color: Colors.black.withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      centerTitle: true,
    );
  }
}

class PersistentHeader extends SliverPersistentHeaderDelegate {
  final Widget widget;

  PersistentHeader({this.widget});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      width: double.infinity,
      height: 47.5,
      child: Card(
        margin: EdgeInsets.all(0),
        color: Colors.white,
        elevation: 5.0,
        child: Center(child: widget),
      ),
    );
  }

  @override
  double get maxExtent => 47.5;

  @override
  double get minExtent => 47.5;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
