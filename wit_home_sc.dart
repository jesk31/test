import 'package:flutter/material.dart';
import 'package:witibju_1/screens/home/wit_home_theme.dart';
import 'package:witibju_1/screens/home/wit_company_info_sc.dart';
import 'package:witibju_1/screens/home/wit_compay_view_sc_.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  get onPressed => null;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: WitHomeTheme.nearlyWhite,    //AppTheme.nearlyWhite,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              getAppBarUI(),
              getImageBox(),
              getPopularCourseUI(),
            ],
          ),
      ),

    );
  }

  Widget getPopularCourseUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0, left: 18, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
           Flexible(
            fit: FlexFit.loose,
            child: PopularCourseListView(
              callBack: () {
                moveTo();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget getImageBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18),
      child:  Container(

            width: 640,
            height: 160,
            child: Image.asset('assets/home/image1.png'),
          )


    );
  }

  Widget getAppBarUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
             Text(
                  '멋진왕자님',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 0.27,
                    color: WitHomeTheme.darkerText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            iconSize: 35.0,
            color: Colors.red,
            onPressed: onPressed,
            icon: Icon(
              Icons.email,
            ),
          ),
        ],
      ),
    );
  }
  void moveTo() {
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => CourseInfoScreen(),
      ),
    );
  }
}


class _ImageBox extends StatelessWidget {
  const _ImageBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Image.asset(
          'assets/home/image1.png',
        ),
      ),
    );
  }
}

