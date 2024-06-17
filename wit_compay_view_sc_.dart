import 'package:witibju_1/screens/home/models/category.dart';
import 'package:witibju_1/screens/home/wit_home_theme.dart';
import 'package:flutter/material.dart';

// 인기 코스 리스트 뷰를 나타내는 StatefulWidget 클래스
class PopularCourseListView extends StatefulWidget {
  const PopularCourseListView({Key? key, this.callBack}) : super(key: key);

  // 콜백 함수, 사용자가 아이템을 선택했을 때 호출됨
  final Function()? callBack;

  @override
  _PopularCourseListViewState createState() => _PopularCourseListViewState();
}

class _PopularCourseListViewState extends State<PopularCourseListView> with TickerProviderStateMixin {
  // 애니메이션 컨트롤러 변수
  AnimationController? animationController;

  // 위젯이 처음 생성될 때 호출되는 메서드
  @override
  void initState() {
    // 애니메이션 컨트롤러 초기화 (2초 동안 애니메이션 지속)
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  // 데이터를 비동기로 가져오는 메서드 (딜레이 200ms)
  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  // 위젯의 레이아웃을 정의하는 메서드
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FutureBuilder<bool>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          // 데이터를 아직 로드 중일 때 빈 SizedBox 반환
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            // 데이터가 로드되면 GridView를 반환
            return SizedBox(
              //height: MediaQuery.of(context).size.height, // 화면의 높이로 GridView 크기를 지정
              height: 600, // 화면의 높이로 GridView 크기를 지정
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: Category.popularCourseList.length, // 아이템 수
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2개의 열
                  mainAxisSpacing: 32.0, // 행 간격
                  crossAxisSpacing: 32.0, // 열 간격
                  childAspectRatio: 0.8, // 자식의 종횡비
                ),
                itemBuilder: (BuildContext context, int index) {
                  final int count = Category.popularCourseList.length;
                  // 각 아이템에 대한 애니메이션 설정
                  final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController!,
                      curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn),
                    ),
                  );
                  // 애니메이션 시작
                  animationController?.forward();
                  // 각 카테고리 아이템을 CategoryView로 반환
                  return CategoryView(
                    callback: widget.callBack,
                    category: Category.popularCourseList[index],
                    animation: animation,
                    animationController: animationController,
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

// 각 카테고리 아이템의 뷰를 나타내는 StatelessWidget 클래스
class CategoryView extends StatelessWidget {
  const CategoryView(
      {Key? key, this.category, this.animationController, this.animation, this.callback})
      : super(key: key);

  final VoidCallback? callback; // 아이템 클릭 시 호출될 콜백 함수
  final Category? category; // 카테고리 데이터
  final AnimationController? animationController; // 애니메이션 컨트롤러
  final Animation<double>? animation; // 애니메이션

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!, // 애니메이션 컨트롤러로 애니메이션 빌드
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!, // 투명도 애니메이션
          child: Transform(
            transform: Matrix4.translationValues(0.0, 50 * (1.0 - animation!.value), 0.0), // Y축 변환 애니메이션
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: callback, // 아이템 클릭 시 콜백 호출
              child: SizedBox(
                height: 280, // 아이템 높이
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: HexColor('#F8FAFB'),
                                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                                            child: Text(
                                              category!.title, // 카테고리 제목
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                letterSpacing: 0.27,
                                                color: WitHomeTheme.darkerText,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  '${category!.lessonCount} lesson', // 레슨 수
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w200,
                                                    fontSize: 12,
                                                    letterSpacing: 0.27,
                                                    color: WitHomeTheme.grey,
                                                  ),
                                                ),
                                                Container(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        '${category!.rating}', // 카테고리 평점
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w200,
                                                          fontSize: 18,
                                                          letterSpacing: 0.27,
                                                          color: WitHomeTheme.grey,
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.star, // 별 아이콘
                                                        color: WitHomeTheme.nearlyBlue,
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 48,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 48,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24, right: 16, left: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: WitHomeTheme.grey.withOpacity(0.2),
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 6.0),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                            child: AspectRatio(
                                aspectRatio: 1.28,
                                child: Image.asset(category!.imagePath)), // 카테고리 이미지
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
