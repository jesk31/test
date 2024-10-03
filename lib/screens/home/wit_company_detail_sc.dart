import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:witibju_1/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju_1/screens/home/wit_home_sc.dart';
import 'package:witibju_1/screens/home/wit_home_theme.dart';
import '../../util/wit_api_ut.dart';
import 'models/company.dart';

dynamic companyInfo = {};

class DetailCompany extends StatefulWidget {
  final String title;
  final String categoryId;

  const DetailCompany({super.key, required this.title, required this.categoryId});

  @override
  State<DetailCompany> createState() => _DetailCompanyState();
}

class _DetailCompanyState extends State<DetailCompany> with SingleTickerProviderStateMixin {
  List<Company> companyList = []; // API로부터 받아오는 회사 리스트
  final List<String> tabNames = ['견적서비스', '아파트 커뮤니티'];
  List<String> selectedItems = []; // 선택된 항목 리스트
  late TabController _tabController;
  bool isAllSelected = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 회사 목록 조회
    getCompanyList(widget.categoryId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WitHomeTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    getAppBarUI(),
                    WitHomeWidgets.getTabBarUI(_tabController, tabNames),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    getEstimateService(),
                    getApartmentCommunity(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              // "견적 요청하기" 버튼 클릭 시 sendRequestInfo 메서드 호출
              sendRequestInfo();
            },
            child: Container(
              width: double.infinity,
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  '견적 요청하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 회사 목록 조회 메서드
  Future<void> getCompanyList(String categoryId) async {
    String restId = "getCompanyList";
    final param = jsonEncode({"categoryId": widget.categoryId});
    try {
      final _companyList = await sendPostRequest(restId, param);
      setState(() {
        companyList = Company().parseCompanyList(_companyList) ?? [];
        // 기본적으로 모든 회사가 선택되도록 selectedItems 초기화
        selectedItems = companyList.map((company) => company.companyId).toList();
        isAllSelected = true;  // 처음에는 전체 선택 상태로 설정
      });
    } catch (e) {
      print('회사 목록 조회 중 오류 발생: $e');
    }
  }

  // 견적 요청 정보 보내기 메서드
  Future<void> sendRequestInfo() async {
    String restId = "saveRequestInfo";
    final param = jsonEncode({
      "reqGubun": 'S',
      "reqUser": '72091587',
      "categoryId": widget.categoryId,
      "companyIds": selectedItems  // 선택된 회사 ID 배열
    });

    try {
      final response = await sendPostRequest(restId, param);

      if (response != null) {
        // 성공 시 알림을 띄우고 HomeScreen으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('견적 요청을 완료했습니다.')),
        );

        // HomeScreen으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        throw Exception('응답 없음');
      }
    } catch (e) {
      print('견적 요청 실패: $e');
      // 실패 시 에러 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('견적 요청에 실패했습니다. 다시 시도해 주세요.')),
      );
    }
  }

  Widget getAppBarUI() {
    return AppBar(
      title: Text(widget.title),
    );
  }

  Widget getEstimateService() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (isAllSelected) {
                  selectedItems.clear();
                } else {
                  selectedItems = companyList.map((company) => company.companyId).toList();
                }
                isAllSelected = !isAllSelected;
              });
            },
            child: Container(
              width: double.infinity,
              height: 50.0,
              decoration: BoxDecoration(
                color: isAllSelected ? Colors.grey : Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  isAllSelected ? '전체 해제' : '전체 선택',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: companyList.length,
              itemBuilder: (context, index) {
                final company = companyList[index];
                bool isSelected = selectedItems.contains(company.companyId);

                return ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedItems.remove(company.companyId);
                        } else {
                          selectedItems.add(company.companyId);
                        }
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.blue : Colors.transparent,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        company.companyNm,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: WitHomeTheme.nearlyBlue,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            company.rateNum,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: WitHomeTheme.nearlyBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedItems.remove(company.companyId);
                      } else {
                        selectedItems.add(company.companyId);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getApartmentCommunity() {
    return Center(
      child: Text('아파트 커뮤니티 탭의 내용'),
    );
  }
}
