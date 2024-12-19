import 'package:app/design/colors.dart';
import 'package:app/models/survey_model.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PointHistoryScreen extends StatelessWidget {
  const PointHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '포인트 내역',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<PointHistory>>(
        future: ApiService().getPointHistory(userId), // API 메서드 필요
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('포인트 내역이 없습니다.'));
          }

          return Column(
            children: [
              // 현재 보유 포인트 카드
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.third,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      '현재 보유 포인트',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<int>(
                      future:
                          ApiService().getCurrentPoints(userId), // API 메서드 필요
                      builder: (context, pointSnapshot) {
                        if (!pointSnapshot.hasData) {
                          return const CircularProgressIndicator(
                              color: Colors.white);
                        }
                        return Text(
                          '${pointSnapshot.data} P',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 포인트 내역 리스트
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final history = snapshot.data![index];
                    return _buildHistoryItem(history);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(PointHistory history) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy.MM.dd').format(history.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                )
              ],
            ),
          ),
          Text(
            '${history.type == 'earn' ? '+' : '-'}${history.points}',
            style: TextStyle(
              color: history.type == 'earn' ? Colors.blue : Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
