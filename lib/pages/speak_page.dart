import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeakPage extends StatefulWidget {
  final String extractedText;

  SpeakPage({required this.extractedText});

  @override
  _SpeakPageState createState() => _SpeakPageState();
}

class _SpeakPageState extends State<SpeakPage> with SingleTickerProviderStateMixin {
  late FlutterTts _flutterTts;
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<Map> _voices = [];
  Map? _currentVoice;

  int? _currentWordStart, _currentWordEnd, _lastWordEnd;

  bool _isPlaying = false;
  Color highlightedBackgroundColor = Color(0xFF64B5F6); // Replace XXXXXX with your desired color code

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    initTTS();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void initTTS() async {
    _flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        _currentWordStart = start;
        _currentWordEnd = end;
      });
    });
    var data = await _flutterTts.getVoices;
    try {
      List<Map> voices = List<Map>.from(data);
      setState(() {
        _voices = voices.where((voice) => voice["name"].contains("en")).toList();
        _currentVoice = _voices.first;
        setVoice(_currentVoice!);
      });
    } catch (e) {
      print(e);
    }
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
    setState(() {
      _currentVoice = voice;
    });
  }

  void _toggleSpeaking() async {
    if (_isPlaying) {
      await _flutterTts.stop();
      _animationController.stop();
    } else {
      if (_lastWordEnd != null) {
        String textToSpeak = widget.extractedText.substring(_lastWordEnd!);
        await _flutterTts.speak(textToSpeak);
      } else {
        await _flutterTts.speak(widget.extractedText);
      }
      _animationController.repeat(reverse: true); // Start animation
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEFF1), // Background color
      appBar: AppBar(
        title: Text('Speak Page'),
        backgroundColor: Color(0xFF455A64), // App bar color
      ),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleSpeaking,
        child: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _animationController, // Use _animationController
        ),
        backgroundColor: Color(0xFF455A64), // FAB color
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _speakerSelector(),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // Text background color
                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 20,
                        color: Colors.black87, // Text color
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: widget.extractedText.substring(0, _currentWordStart ?? 0),
                        ),
                        if (_currentWordStart != null && _currentWordEnd != null)

                          TextSpan(
                            text: widget.extractedText.substring(_currentWordStart!, _currentWordEnd!),
                            style: TextStyle(
                              color: Colors.white, // Highlighted text color
                              backgroundColor: highlightedBackgroundColor.withOpacity(_animation.value),
                            ),
                          ),
                        TextSpan(
                          text: widget.extractedText.substring(_currentWordEnd ?? widget.extractedText.length),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _speakerSelector() {
    return DropdownButton(
      value: _currentVoice,
      items: _voices
          .map(
            (_voice) => DropdownMenuItem(
          value: _voice,
          child: Text(
            _voice["name"],
            style: TextStyle(
              color: Colors.black87, // Dropdown text color
            ),
          ),
        ),
      )
          .toList(),
      onChanged: (value) {
        setVoice(value as Map);
      },
      dropdownColor: Colors.white, // Dropdown background color
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SpeakPage(extractedText: "Hello, this is a sample text."),
  ));
}
