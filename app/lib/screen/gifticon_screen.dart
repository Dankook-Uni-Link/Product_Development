import 'package:app/models/gifticon_model.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

class Gifticon_Screen extends StatefulWidget {
  const Gifticon_Screen({super.key});

  @override
  _Gifticon_ScreenState createState() => _Gifticon_ScreenState();
}

class _Gifticon_ScreenState extends State<Gifticon_Screen> {
  List<Gifticon> gifticons = [];
  int? selectedGifticonIndex;

  @override
  void initState() {
    super.initState();
    _fetchGifticons();
  }

  Future<void> _fetchGifticons() async {
    try {
      final apiService = ApiService();
      final gifticonList = await apiService.getGifticonList();
      setState(() {
        gifticons = gifticonList;
      });
    } catch (e) {
      // 에러 처리
      print('Failed to load gifticons: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedGifticon = selectedGifticonIndex != null
        ? gifticons[selectedGifticonIndex!]
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          '기프티콘 보유 목록',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 3 / 4,
              ),
              itemCount: gifticons.length,
              itemBuilder: (context, index) {
                final gifticon = gifticons[index];
                final isSelected = selectedGifticonIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedGifticonIndex = isSelected ? null : index;
                    });
                  },
                  child: Card(
                    elevation: isSelected ? 8 : 2,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(gifticon.imageUrl),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gifticon.storeName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(gifticon.productName),
                              Text(gifticon.price),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                selectedGifticon != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '선택된 제품: ${selectedGifticon.storeName} - ${selectedGifticon.productName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('가격: ${selectedGifticon.price}'),
                        ],
                      )
                    : const Text(
                        '미선택 상태',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: selectedGifticonIndex != null
                          ? () {
                              // 수령 로직
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedGifticonIndex != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                      child: const Text('수령하기'),
                    ),
                    ElevatedButton(
                      onPressed: selectedGifticonIndex != null
                          ? () {
                              // 선물 로직
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedGifticonIndex != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                      child: const Text('선물하기'),
                    ),
                    ElevatedButton(
                      onPressed: selectedGifticonIndex != null
                          ? () {
                              // 전환 로직
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedGifticonIndex != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                      child: const Text('전환하기'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
