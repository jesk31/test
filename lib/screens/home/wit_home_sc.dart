import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witibju_1/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju_1/screens/home/wit_company_detail_sc.dart';
import 'package:witibju_1/screens/home/wit_compay_view_sc_.dart';
import 'package:witibju_1/screens/home/wit_home_get_estimate.dart';
import 'package:witibju_1/screens/home/wit_home_theme.dart';
import 'package:witibju_1/screens/home/wit_estimate_detail.dart';
import 'models/main_view_model.dart';
import 'wit_login_pop_home_sc.dart'; // 로그인 팝업창 파일을 임포트
import 'models/category.dart';

///메인 홈
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ///bool isLogined = false; // 로그인 상태 변수 임시로
  
   bool isLogined = true; // 로그인 상태 변수



  // SelectBox에 표시할 옵션 리스트
  List<String> options = ["송파더플레티넘", "기흥역 센트럴푸르지오", "병점 아이파크캐슬", "포레나송파"];
  String selectedOption = "송파더플레티넘"; // 기본 선택된 옵션

  @override
  Widget build(BuildContext context) {
    final mainViewModel = Provider.of<MainViewModel>(context);
    final userInfo = mainViewModel.userInfo;
    print('111111111111112222222222222222222222222');
    return Container(
      color: WitHomeTheme.nearlyWhite,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: WitHomeTheme.nearlyWhite,
          iconTheme: IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              iconSize: 35.0,
              onPressed: () {
                if (isLogined) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EstimateScreen(),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 300,
                          padding: EdgeInsets.all(20.0),
                          child: loingPopHome(
                            onLoginSuccess: () {
                              setState(() {
                                isLogined = true;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
              icon: Icon(
                Icons.email,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              // SelectBox 추가 (하단 팝업 표시)
              GestureDetector(
                onTap: () {
                  WitHomeWidgets.showSelectBox(context, selectedOption, options, (option) {
                    setState(() {
                      selectedOption = option;
                    });
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 50.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.0), // 텍스트 앞에 패딩 추가
                        child: Text(
                          selectedOption,
                          style: WitHomeTheme.title, // 폰트 스타일 적용
                        ),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                child: ImageBox(),
              ),
              SizedBox(height: 2),
              Text(
                "우리 입주할때 인테리어 비교견적을 받아보세요~",
                style: WitHomeTheme.title,
              ),
              SizedBox(height: 8),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50.0,
                decoration: BoxDecoration(
                  color: WitHomeTheme.nearlyslowBlue,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => getEstimate(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    "견적받으러 가기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4),
              getPopularCourseUI(),  ///견적받으러 가기
            ],
          ),
        ),
      ),
    );
  }
 ///최하단 카테고리
  Widget getPopularCourseUI() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              child: PopularCourseListView(
                callBack: (Category category) {
                  moveTo(category);
                },
              ),
            ),
            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  void moveTo(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailCompany(title: category.categoryNm,categoryId: category.categoryId),
      ),
    );
  }
}
