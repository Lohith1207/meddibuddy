import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'openai_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'profile_page.dart';

class myhomepage extends StatefulWidget {
  const myhomepage({super.key});

  @override
  State<myhomepage> createState() => _myhomepageState();
}

class _myhomepageState extends State<myhomepage> {
  final speechToText = SpeechToText();
  bool speechEnabled = false;
  bool isListening = false;
  String lastWords = '';
  String chatGPTReply = '';
  bool isLoading = false;
  bool manualStop = false;
  late FlutterTts flutterTts;
  bool isSpeaking = false;
  Future<void> speakText(String text) async {
    setState(() {
      isSpeaking = true;
    });

    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  final GeminiService geminiService = GeminiService();
  @override
  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts(); // initialize here
    initSpeech();

    // Setup handlers
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> initSpeech() async {
    speechEnabled = await speechToText.initialize(
      onStatus: onSpeechStatus,
      onError: onSpeechError,
    );
    setState(() {});
  }

  void onSpeechStatus(String status) {
    print('Speech status: $status');
    if ((status == 'done' || status == 'notListening') && !manualStop) {
      if (isListening) {}
    }
  }

  void onSpeechError(dynamic error) {
    print('Speech error: $error');
  }

  Future<void> startListening() async {
    if (speechToText.isListening) return;
    await speechToText.listen(
      onResult: onSpeechResult,
      listenMode: ListenMode.dictation,
      partialResults: true,
      cancelOnError: false,
      pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(minutes: 1),
    );
    setState(() {
      isListening = true;
      manualStop = false;
    });
  }

  Future<void> stopListening() async {
    if (speechToText.isListening) {
      await speechToText.stop();
    }
    setState(() {
      isListening = false;
      manualStop = true;
    });
  }

  void onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      lastWords = result.recognizedWords;
    });

    if (result.finalResult) {
      setState(() {
        isLoading = true;
      });

      final reply = await geminiService.sendMessage(lastWords);

      setState(() {
        chatGPTReply = reply;
        isLoading = false;
      });

      await speakText(reply);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Medi Buddy Chat',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              try {
                await flutterTts.stop();
                await Future.delayed(const Duration(milliseconds: 300));
                setState(() {
                  isSpeaking = false;
                });
                if (isListening) {
                  await stopListening();
                }
                setState(() {
                  lastWords = '';
                  chatGPTReply = '';
                  isLoading = false;
                  manualStop = true;
                });
              } catch (e) {
                print("Error while refreshing: $e");
              }
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            tooltip: 'Profile',
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Text(
                  lastWords.isEmpty
                      ? 'Your speech will appear here...'
                      : lastWords,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child:
                    isLoading
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Thinking...',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        )
                        : chatGPTReply.isEmpty
                        ? Text(
                          'How are you feeling?',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        )
                        : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: SingleChildScrollView(
                            child: Text(
                              chatGPTReply,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(
          isListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
        onPressed: () async {
          if (!speechEnabled) {
            speechEnabled = await speechToText.initialize(
              onStatus: onSpeechStatus,
              onError: onSpeechError,
            );
            setState(() {});
          }
          if (isListening) {
            await stopListening();
          } else {
            await startListening();
          }
        },
      ),
    );
  }
}
