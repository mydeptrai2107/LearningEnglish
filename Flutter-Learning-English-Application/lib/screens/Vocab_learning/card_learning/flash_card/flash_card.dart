import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'all_constants.dart';
import 'reusable_card.dart';
import 'package:application_learning_english/models/word.dart';

// FlashCard widget chính, đây là nơi tạo giao diện flashcard và quản lý các hành động
class FlashCard extends StatefulWidget {
  final List<Word> words; // Danh sách các từ vựng
  final bool isShuffle; // Cờ chỉ định có trộn từ hay không
  final bool
      isEnglish; // Cờ xác định ngôn ngữ hiển thị là tiếng Anh hay tiếng Việt
  final bool autoPronounce; // Cờ xác định có tự động phát âm từ không

  const FlashCard({
    super.key,
    required this.words,
    required this.isShuffle,
    required this.autoPronounce,
    required this.isEnglish,
  });

  @override
  State<FlashCard> createState() =>
      _FlashCardState(); // Trả về trạng thái của FlashCard
}

class _FlashCardState extends State<FlashCard> {
  late List<Map<String, String>> wordPairs; // Danh sách các cặp từ (Anh - Việt)
  int _currentIndexNumber = 0; // Chỉ số của từ hiện tại
  double _initial = 0.1; // Giá trị ban đầu của thanh tiến trình
  bool isFlipped = false; // Cờ xác định flashcard có bị lật hay không
  bool autoFlippedEnable = false; // Cờ kiểm tra việc tự động lật flashcard
  double _startX = 0; // Vị trí bắt đầu của thao tác vuốt
  double _endX = 0; // Vị trí kết thúc của thao tác vuốt
  Timer? flipTimer; // Bộ đếm thời gian cho việc lật flashcard tự động
  Timer? changeCardTimer; // Bộ đếm thời gian để chuyển sang thẻ tiếp theo
  final GlobalKey<FlipCardState> cardKey =
      GlobalKey<FlipCardState>(); // Khóa để quản lý trạng thái của FlipCard
  FlutterTts flutterTts = FlutterTts(); // Đối tượng phát âm

  @override
  void initState() {
    super.initState();
    if (autoFlippedEnable) {
      startAutoFlip(); // Khởi tạo việc lật tự động nếu cần
    }
    getDataWord(); // Lấy dữ liệu từ từ vựng
    if (widget.isShuffle) {
      wordPairs.shuffle(); // Nếu cần trộn, trộn danh sách từ vựng
    }
    if (widget.autoPronounce) {
      pronounceCurrentWord(); // Phát âm từ hiện tại nếu bật tính năng tự động phát âm
    }
  }

  // Hàm lấy dữ liệu từ các từ vựng
  void getDataWord() {
    wordPairs = widget.words.map((word) {
      return {
        'english': word.english,
        'vietnamese': word.vietnamese
      }; // Tạo danh sách cặp từ (Anh - Việt)
    }).toList();
  }

  @override
  void dispose() {
    flipTimer?.cancel(); // Hủy bộ đếm thời gian flip khi đóng widget
    changeCardTimer
        ?.cancel(); // Hủy bộ đếm thời gian chuyển thẻ khi đóng widget
    super.dispose();
  }

  // Hàm bắt đầu lật flashcard tự động sau một khoảng thời gian
  void startAutoFlip() {
    flipTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      cardKey.currentState?.toggleCard(); // Lật flashcard
      setState(() {
        isFlipped = !isFlipped; // Đổi trạng thái lật thẻ
      });

      if (isFlipped) {
        changeCardTimer = Timer(Duration(seconds: 5), () {
          cardKey.currentState?.toggleCard(); // Lật lại flashcard sau 5 giây
          setState(() {
            isFlipped = false; // Đặt lại trạng thái là chưa lật
            showNextCard(); // Chuyển sang thẻ tiếp theo
            updateToNext(); // Cập nhật chỉ số thẻ
          });
        });
      }
    });
  }

  // Hàm dừng việc lật flashcard tự động
  void stopAutoFlip() {
    flipTimer?.cancel(); // Hủy bộ đếm thời gian lật
    changeCardTimer?.cancel(); // Hủy bộ đếm thời gian chuyển thẻ
  }

  // Hàm thay đổi trạng thái của việc lật flashcard tự động
  void toggleAutoFlip() {
    setState(() {
      autoFlippedEnable = !autoFlippedEnable; // Đảo trạng thái của tự động lật
      if (autoFlippedEnable) {
        startAutoFlip(); // Bắt đầu tự động lật
      } else {
        stopAutoFlip(); // Dừng tự động lật
      }
    });
  }

  // Hàm phát âm từ hiện tại
  void pronounceCurrentWord() {
    String textToSpeak = wordPairs[_currentIndexNumber][isFlipped
        ? (widget.isEnglish ? 'vietnamese' : 'english')
        : (widget.isEnglish ? 'english' : 'vietnamese')]!;
    flutterTts.speak(textToSpeak); // Phát âm từ hiện tại
  }

  @override
  Widget build(BuildContext context) {
    String value =
        "${_currentIndexNumber + 1} of ${wordPairs.length}"; // Hiển thị thông tin về tiến độ

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Màu nền của trang
      appBar: AppBar(
        centerTitle: true, // Căn giữa tiêu đề app bar
        title: Text("Flashcards App",
            style: TextStyle(fontSize: 30)), // Tiêu đề app
        backgroundColor: mainColor, // Màu nền app bar
        toolbarHeight: 80, // Chiều cao của app bar
        elevation: 5, // Độ đổ bóng của app bar
        shadowColor: mainColor, // Màu đổ bóng của app bar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Bo góc app bar
        ),
        actions: [
          Row(
            children: [
              Text("Auto Flip",
                  style: TextStyle(fontSize: 16)), // Chữ hiển thị Auto Flip
              Switch(
                value:
                    autoFlippedEnable, // Giá trị của switch (bật/tắt tự động lật)
                onChanged: (value) {
                  toggleAutoFlip(); // Thay đổi trạng thái khi người dùng chuyển switch
                },
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Căn giữa các widget trong cột
          children: <Widget>[
            Text("Question $value Completed",
                style: otherTextStyle), // Hiển thị tiến độ
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.white, // Màu nền của thanh tiến trình
                valueColor: AlwaysStoppedAnimation(
                    mainColor), // Màu của thanh tiến trình
                minHeight: 5, // Chiều cao tối thiểu của thanh tiến trình
                value: _initial, // Giá trị của thanh tiến trình
              ),
            ),
            SizedBox(height: 25),
            GestureDetector(
              onHorizontalDragStart: (details) {
                _startX =
                    details.globalPosition.dx; // Lấy vị trí bắt đầu của vuốt
                stopAutoFlip(); // Dừng lật tự động khi bắt đầu vuốt
              },
              onHorizontalDragUpdate: (details) {
                _endX =
                    details.globalPosition.dx; // Lấy vị trí kết thúc của vuốt
              },
              onHorizontalDragEnd: (details) {
                final double velocity = (_endX - _startX).abs() /
                    details.primaryVelocity!; // Tính tốc độ vuốt
                if (velocity > 1000) {
                  final double delta =
                      _endX - _startX; // Tính sự thay đổi của vị trí
                  if (delta > 0) {
                    if (_currentIndexNumber > 0) {
                      showPreviousCard(); // Vuốt trái, hiển thị thẻ trước
                    }
                  } else {
                    if (_currentIndexNumber < wordPairs.length - 1) {
                      showNextCard(); // Vuốt phải, hiển thị thẻ tiếp theo
                    }
                  }
                }
              },
              child: SizedBox(
                width: 300,
                height: 300,
                child: FlipCard(
                  // Widget FlipCard hiển thị thẻ với khả năng lật
                  key: cardKey,
                  direction: FlipDirection.HORIZONTAL, // Lật theo chiều ngang
                  flipOnTouch: false, // Không lật khi chạm vào thẻ
                  front: GestureDetector(
                    onTap: () {
                      cardKey.currentState?.toggleCard(); // Lật thẻ khi chạm
                      setState(() {
                        isFlipped = !isFlipped; // Đổi trạng thái thẻ
                      });
                      if (widget.autoPronounce) {
                        pronounceCurrentWord(); // Phát âm từ khi lật thẻ
                      }
                    },
                    child: Stack(children: [
                      ReusableCard(
                        text: wordPairs[_currentIndexNumber]
                            [widget.isEnglish ? 'english' : 'vietnamese']!,
                      ),
                      Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: Icon(Icons.volume_up), // Nút phát âm
                            onPressed: () {
                              flutterTts.speak(wordPairs[_currentIndexNumber][
                                  widget.isEnglish
                                      ? 'english'
                                      : 'vietnamese']!);
                            },
                          ))
                    ]), // Thẻ phía trước
                  ),
                  back: GestureDetector(
                    onTap: () {
                      cardKey.currentState?.toggleCard(); // Lật thẻ khi chạm
                      setState(() {
                        isFlipped = !isFlipped; // Đổi trạng thái thẻ
                      });
                      if (widget.autoPronounce) {
                        pronounceCurrentWord(); // Phát âm từ khi lật thẻ
                      }
                    },
                    child: Stack(children: [
                      ReusableCard(
                        text: wordPairs[_currentIndexNumber]
                            [widget.isEnglish ? 'vietnamese' : 'english']!,
                      ),
                      Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: Icon(Icons.volume_up), // Nút phát âm
                            onPressed: () {
                              flutterTts.speak(
                                wordPairs[_currentIndexNumber][widget.isEnglish
                                    ? 'vietnamese'
                                    : 'english']!,
                              );
                            },
                          ))
                    ]), // Thẻ phía sau
                  ),
                ),
              ),
            ),
            Text("Tap to view",
                style: otherTextStyle), // Hướng dẫn người dùng chạm để xem
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Cập nhật chỉ số của thẻ hiện tại để chuyển đến thẻ tiếp theo
  void updateToNext() {
    setState(() {
      _currentIndexNumber = (_currentIndexNumber + 1) % wordPairs.length;
      _initial = (_currentIndexNumber + 1) / wordPairs.length;
    });
    if (widget.autoPronounce) {
      pronounceCurrentWord(); // Phát âm từ mới nếu bật tính năng phát âm tự động
    }
  }

  // Cập nhật chỉ số của thẻ hiện tại để chuyển về thẻ trước
  void updateToPrev() {
    setState(() {
      _currentIndexNumber = (_currentIndexNumber - 1 >= 0)
          ? _currentIndexNumber - 1
          : wordPairs.length - 1;
      _initial = (_currentIndexNumber + 1) / wordPairs.length;
    });
    if (widget.autoPronounce) {
      pronounceCurrentWord(); // Phát âm từ mới nếu bật tính năng phát âm tự động
    }
  }

  // Hiển thị thẻ tiếp theo
  void showNextCard() {
    setState(() {
      _currentIndexNumber = (_currentIndexNumber + 1) % wordPairs.length;
      _initial = (_currentIndexNumber + 1) / wordPairs.length;
    });
    if (widget.autoPronounce) {
      pronounceCurrentWord(); // Phát âm từ khi chuyển thẻ
    }
  }

  // Hiển thị thẻ trước
  void showPreviousCard() {
    setState(() {
      _currentIndexNumber = (_currentIndexNumber - 1 >= 0)
          ? _currentIndexNumber - 1
          : wordPairs.length - 1;
      _initial = (_currentIndexNumber + 1) / wordPairs.length;
    });
    if (widget.autoPronounce) {
      pronounceCurrentWord(); // Phát âm từ khi chuyển thẻ
    }
  }
}
