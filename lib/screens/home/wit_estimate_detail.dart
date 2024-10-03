import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:witibju_1/screens/home/widgets/wit_home_widgets.dart';
import 'package:witibju_1/screens/home/wit_home_theme.dart';

import '../../util/wit_api_ut.dart';
import 'models/requestInfo.dart';
import 'wit_estimate_notice.dart'; // 알림 화면 연결

/// 견적화면
class EstimateScreen extends StatefulWidget {
  @override
  State<EstimateScreen> createState() => _EstimateScreenState();
}

class _EstimateScreenState extends State<EstimateScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RequestInfo> requestList = [];

  // formatCurrency 함수 추가
  String formatCurrency(String amount) {
    if (amount.isEmpty || amount == "-") {
      return "-";
    }

    // 금액을 정수로 변환한 후 3자리마다 콤마를 찍음
    final formatter = NumberFormat('#,###');
    int intAmount = int.parse(amount);
    return formatter.format(intAmount);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 회사 목록 조회
    getRequestList('72091587');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('견적 요청 화면'),
      ),
      body: Column(
        children: [
          // 광고 영역
          Container(
            height: 200, // 높이를 고정하여 Overflow 방지
            child: ImageBox(),
          ),
          SizedBox(height: 16.0),

          // 견적 및 알림 탭
          WitHomeWidgets.getTabBarUI(_tabController, ['견적', '알림']),

          // 탭 내용
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 8.0),
                      // requestList를 reqNo 별로 그룹화하여 SectionWidget 생성
                      ..._buildReqNoSections(),
                    ],
                  ),
                ),
                // 67라인 - 알림 화면 연결
                WitEstimateNoticeScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // reqNo 별로 요청 견적을 그룹화하고, 각 reqNo 내부에서 categoryId 별로 그룹화하여 SectionWidget 생성
  List<Widget> _buildReqNoSections() {
    Map<String, List<RequestInfo>> reqNoGroupedRequests = {};

    // requestList를 reqNo 별로 그룹화
    for (var request in requestList) {
      String reqNo = request.reqNo; // reqNo로 그룹화
      if (!reqNoGroupedRequests.containsKey(reqNo)) {
        reqNoGroupedRequests[reqNo] = [];
      }
      reqNoGroupedRequests[reqNo]!.add(request);
    }

    // 각 reqNo별 SectionWidget 생성
    List<Widget> sectionWidgets = [];
    reqNoGroupedRequests.forEach((reqNo, requests) {
      // 각 reqNo에서 categoryId 별로 다시 그룹화
      Map<String, List<RequestInfo>> categoryGroupedRequests = {};
      for (var request in requests) {
        String categoryId = request.categoryId; // categoryId로 그룹화
        if (!categoryGroupedRequests.containsKey(categoryId)) {
          categoryGroupedRequests[categoryId] = [];
        }
        categoryGroupedRequests[categoryId]!.add(request);
      }

      // reqNo별 섹션 추가
      sectionWidgets.add(
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
            children: [
              // Row를 사용하여 reqNo를 왼쪽에 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우로 정렬
                children: [
                  // 요청 번호 (reqNo)를 왼쪽에 표시하고 볼드 처리
                  Text(
                    '요청 번호: $reqNo',  // reqNo 사용
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  // 요청 개수를 오른쪽에 표시
                  Text(
                    '${requests.first.timeAgo} 요청 견적',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 8.0), // 날짜와 리스트 사이에 여백 추가
              // 각 categoryId 별로 SectionWidget 생성
              for (var entry in categoryGroupedRequests.entries) ...[
                SectionWidget(
                  title: '${entry.value.first.categoryNm} (${entry.value.length}건)',  // 카테고리 이름 옆에 총 요청 수 표시
                  items: entry.value.map((request) {
                    return ListItem(
                      company: request.companyNm,  // 회사 이름
                      time: request.reqDate,  // 요청 시간
                      rate: request.rate,  // 추가된 rate 필드
                      content: request.reqContents,  // 내용 (예: 견적 내용)
                      reqDateInfo: request.reqDateInfo,  // 추가: reqDateInfo 사용
                      reqState: request.reqState, // reqState 추가
                      reqStateNm: request.reqStateNm, // reqStateNm 추가
                      estimateAmount: request.estimateAmount, // reqStateNm 추가
                    );
                  }).toList(),
                  // SectionWidget에 onTap 이벤트 추가하여 상세 팝업 띄우기
                  onTap: () {
                    _showDetailPopup(context, entry.value);
                  },
                ),
                SizedBox(height: 8.0), // 카테고리 간 간격 추가
              ],
            ],
          ),
        ),
      );
    });

    return sectionWidgets;
  }

  // 팝업 화면을 띄우는 함수 (reqNo가 다건일 때 리스트로 표시)
  void _showDetailPopup(BuildContext context, List<RequestInfo> requests) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9, // 가로 사이즈 90%
            height: MediaQuery.of(context).size.height * 0.7, // 세로 사이즈 70%

            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${requests.first.categoryNm} 견적',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '${requests.first.reqNo}',
                            style: TextStyle(fontSize: 12), // 작은 글씨로 reqNo 추가
                          ),
                        ],
                      ),
                      // Expanded를 추가하여 중간 공간을 차지하게 만듭니다.
                      Expanded(child: Container()),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop(); // 팝업 닫기
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (BuildContext context, int index) {
                      final request = requests[index];
                      print('이거뭐냐 ' + request.estimateAmount);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(color: Colors.grey),
                            color: Colors.white, // 기본 흰색 배경 유지
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${request.companyNm}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 2.0), // 회사명과 별 이미지 사이 간격
                                  Image.asset(
                                    'assets/images/star.png',  // 별 이미지 추가
                                    width: 16.0,  // 이미지 너비
                                    height: 16.0, // 이미지 높이
                                  ),
                                  SizedBox(width: 2.0), // 별 이미지와 rate 텍스트 사이 간격
                                  Text('${request.rate}', style: TextStyle(fontSize: 16)), // rate 텍스트
                                  // 여백을 주기 위해 Expanded 사용
                                  Expanded(child: Container()),
                                  GestureDetector(
                                    onTap: request.reqState == '02'
                                        ? () {
                                      _showConfirmationDialog(
                                          context,
                                          request.companyNm,  // reqNo 전달
                                          request.estimateAmount,  // reqNo 전달
                                          request.reqNo,  // reqNo 전달
                                          request.seq,    // seq 전달
                                          '72091587' // reqUser 전달
                                      );
                                    }
                                        : null, // 상태가 02이 아닐 경우 클릭 비활성화
                                    child: Text(
                                      '${request.reqStateNm}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: request.reqState != '02'
                                            ? Colors.grey
                                            : Colors.blue, // 상태에 따라 텍스트 색상만 회색으로 변경
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8.0), // 견적 금액 추가

                              Text(
                                request.estimateAmount.isEmpty || request.estimateAmount == "-"
                                    ? '견적 금액: -'
                                    : '견적 금액: ${formatCurrency(request.estimateAmount)} 원',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.0),
                              Container(
                                width: double.infinity, // 전체 영역에 배경색 적용
                                padding: EdgeInsets.all(8.0), // 텍스트와 배경 사이에 패딩 추가
                                decoration: BoxDecoration(
                                  color: Colors.grey[300], // 더 진한 회색 배경
                                  borderRadius: BorderRadius.circular(4.0), // 모서리 둥글게
                                ),
                                child: Text(
                                  request.reqContents,  // 세번째 줄에 reqContents 표시
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),

                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 확인 창을 띄우는 함수
  void _showConfirmationDialog(BuildContext context, String companyNm,String estimateAmount,String reqNo, String seq, String reqUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("작업 요청"),
          content: RichText(
            text: TextSpan(
              text: companyNm,  // 회사명 부분
              style: TextStyle(fontSize: 14, color: Colors.blue),  // 파란색 스타일 적용
              children: <TextSpan>[
                TextSpan(
                  text: ' 업체에 작업을 요청할까요?',
                  style: TextStyle(fontSize: 14, color: Colors.black),  // 나머지 텍스트 스타일
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // 요청 상태 업데이트 함수 호출 후 팝업 창 닫기
                await updateRequestState(reqNo, seq, reqUser);
                Navigator.of(context).pop(); // 팝업 창 닫기
              },
              child: Text("보내기"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("취소"),
            ),
          ],
        );
      },
    );
  }

  // 요청 상태 업데이트 로직을 추가하는 함수
  Future<void> updateRequestState(String reqNo, String seq, String reqUser) async {
    String restId = "updateRequestState";
    final param = jsonEncode({
      "reqNo": reqNo,
      "seq": seq,
      "reqUser": reqUser,
      "reqState": '03'
    });

    try {
      final response = await sendPostRequest(restId, param);
      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('작업 요청을 완료했습니다.')),
        );
        // 요청이 성공하면 목록을 재조회
        await getRequestList('72091587');
        Navigator.of(context).pop(); // 팝업 창 닫기
      } else {
        print("요청 상태 업데이트 실패: ${response['message']}");
      }
    } catch (e) {
      print('요청 상태 업데이트 중 오류 발생: $e');
    }
  }

  Future<void> getRequestList(String reqUserNo) async {
    String restId = "getRequestList";

    final param = jsonEncode({"reqUser": reqUserNo});
    try {
      final _requestList = await sendPostRequest(restId, param);
      setState(() {
        requestList = RequestInfo().parseRequestList(_requestList) ?? [];
      });
    } catch (e) {
      print('신청 목록 조회 중 오류 발생: $e');
    }
  }
}

class SectionWidget extends StatelessWidget {
  final String title;
  final List<ListItem> items;
  final VoidCallback onTap;  // onTap 콜백 추가

  const SectionWidget({required this.title, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.9; // 화면 너비의 90%로 설정
    return GestureDetector(
      onTap: () {
        print('SectionWidget tapped'); // 터치 시 디버깅용 로그 출력
        onTap();  // 터치 시 onTap 콜백 실행
      },
      child: Container(
        width: width,
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onTap,  // title에 onTap 적용
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            for (var item in items) ...[
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('- ${item.company}', style: TextStyle(fontSize: 16)),  // 회사명 텍스트
                  SizedBox(width: 4.0), // 간격
                  Image.asset(
                    'assets/images/star.png',  // 별 이미지 추가
                    width: 16.0,  // 이미지 너비
                    height: 16.0, // 이미지 높이
                  ),
                  SizedBox(width: 4.0), // 이미지와 텍스트 사이 간격
                  Text('${item.rate} ', style: TextStyle(fontSize: 16)),  // reqDateInfo 사용
                ],
              ),
              SizedBox(height: 4.0),
              Text(item.content, style: TextStyle(color: Colors.grey)),  // 내용 표시
            ],
          ],
        ),
      ),
    );
  }
}

class ListItem {
  final String company;
  final String time;
  final String rate; // 추가: rate 필드
  final String content;
  final String reqDateInfo; // 추가: reqDateInfo 필드 추가
  final String reqState; // 추가: reqState 필드 추가
  final String reqStateNm; // 추가: reqStateNm 필드 추가
  final String estimateAmount; // 추가: reqStateNm 필드 추가


  ListItem({
    required this.company,
    required this.time,
    required this.rate,
    required this.content,
    required this.reqDateInfo,
    required this.reqState,
    required this.reqStateNm,
    required this.estimateAmount,
  });
}
