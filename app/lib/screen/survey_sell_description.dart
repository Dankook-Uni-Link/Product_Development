import 'package:app/design/colors.dart';
import 'package:flutter/material.dart';

class Survey_sell_DetailScreen extends StatelessWidget {
  final String title;

  const Survey_sell_DetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: AppColors.primary,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '설명:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 100, // 설명 박스의 높이를 줄임
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: const Text(
                "상세한 설명이 들어가는 부분입니다. 상품의 특징이나, 가격, 구성, 사용법 등이 들어갈 수 있습니다.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            const Spacer(), // 버튼을 아래쪽으로 밀어줌
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          const Color(0xFF3B2D2D), // Button background color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 23, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // 트렌디한 모서리 반경
                      ),
                      elevation: 5, // 그림자 효과
                    ),
                    child: const Text(
                      '구매하기',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          const Color(0xFF3B2D2D), // Button background color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 23, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // 트렌디한 모서리 반경
                      ),
                      elevation: 5, // 그림자 효과
                    ),
                    child: const Text(
                      '선물하기',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          const Color(0xFF3B2D2D), // Button background color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // 트렌디한 모서리 반경
                      ),
                      elevation: 5, // 그림자 효과
                    ),
                    child: const Text(
                      '찜 하기',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // 버튼과 하단의 간격을 줌
          ],
        ),
      ),
    );
  }
}
