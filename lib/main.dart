import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

void main() {
  runApp(runApps());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String defaultLanguage = 'en-US';

  TextToSpeech tts = TextToSpeech();

  String text = '';
  double volume = 1; // Range: 0-1
  double rate = 1.0; // Range: 0-2
  double pitch = 1.0; // Range: 0-2

  String language;
  String languageCode;
  List<String> languages = <String>[];
  List<String> languageCodes = <String>[];
  String voice;

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = text;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initLanguages();
    });
  }

  Future<void> initLanguages() async {
    /// populate lang code (i.e. en-US)
    languageCodes = await tts.getLanguages();

    /// populate displayed language (i.e. English)
    final List<String> displayLanguages = await tts.getDisplayLanguages();
    if (displayLanguages == null) {
      return;
    }

    languages.clear();
    for (final dynamic lang in displayLanguages) {
      languages.add(lang as String);
    }

    final String defaultLangCode = await tts.getDefaultLanguage();
    if (defaultLangCode != null && languageCodes.contains(defaultLangCode)) {
      languageCode = defaultLangCode;
    } else {
      languageCode = defaultLanguage;
    }
    language = await tts.getDisplayLanguageByCode(languageCode);

    /// get voice
    voice = await getVoiceByLang(languageCode);

    if (mounted) {
      setState(() {});
    }
  }

  Future<String> getVoiceByLang(String lang) async {
    final List<String> voices = await tts.getVoiceByLang(languageCode);
    if (voices != null && voices.isNotEmpty) {
      return voices.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Speakly",
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 24, 35, 40),
        drawer: Drawer(
          child: Material(
            color: Color.fromARGB(255, 24, 35, 40),
            child: ListView(
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                GradientButton(
                    callback: () {
                      Navigator.pushNamed(context, '/');
                    },
                    gradient: Gradients.rainbowBlue,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.home),
                    )),
                const SizedBox(
                  height: 30,
                ),
                GradientButton(
                    callback: () {
                      Navigator.pushNamed(context, '/about');
                    },
                    gradient: Gradients.rainbowBlue,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.info),
                    )),
              ],
            ),
          ),
        ),
        appBar: NewGradientAppBar(
          title: Center(child: const Text('Speakly')),
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.cyan, Color.fromARGB(255, 63, 87, 99)],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  TextField(
                    controller: textEditingController,
                    maxLines: 5,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyan)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        fillColor: Colors.white,
                        hintText: 'Enter some text here...',
                        hintStyle: TextStyle(color: Colors.white)),
                    onChanged: (String newText) {
                      setState(() {
                        text = newText;
                      });
                    },
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: <Widget>[
                      const Text(
                        'Volume',
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: volume,
                          thumbColor: Colors.cyan,
                          min: 0,
                          max: 1,
                          onChanged: (double value) {
                            initLanguages();
                            setState(() {
                              volume = value;
                            });
                          },
                        ),
                      ),
                      Text('(${volume.toStringAsFixed(2)})'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Text(
                        'Rate',
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: rate,
                          thumbColor: Colors.green,
                          activeColor: Colors.greenAccent,
                          min: 0,
                          max: 2,
                          label: rate.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              rate = value;
                            });
                          },
                        ),
                      ),
                      Text('(${rate.toStringAsFixed(2)})'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Text(
                        'Pitch',
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: pitch,
                          thumbColor: Colors.red,
                          activeColor: Colors.red,
                          min: 0,
                          max: 2,
                          label: pitch.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              pitch = value;
                            });
                          },
                        ),
                      ),
                      Text('(${pitch.toStringAsFixed(2)})'),
                    ],
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(right: 5),
                          child: CircularGradientButton(
                            gradient: Gradients.rainbowBlue,
                            callback: () {
                              tts.stop();
                            },
                            child: SafeArea(
                                child: Icon(Icons.stop_circle_rounded)),
                          ),
                        ),
                      ),
                      if (supportPause)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(right: 5),
                            child: CircularGradientButton(
                              gradient: Gradients.rainbowBlue,
                              callback: () => tts.pause(),
                              child: SafeArea(
                                  child:
                                      Icon(Icons.pause_circle_filled_rounded)),
                            ),
                          ),
                        ),
                      if (supportResume)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(right: 5),
                            child: CircularGradientButton(
                                gradient: Gradients.rainbowBlue,
                                callback: () {
                                  tts.resume();
                                },
                                child: SafeArea(
                                    child:
                                        Icon(Icons.play_circle_fill_rounded))),
                          ),
                        ),
                      Expanded(
                          child: Container(
                        child: CircularGradientButton(
                          gradient: Gradients.rainbowBlue,
                          callback: () {
                            speak();
                          },
                          child: SafeArea(
                              child: Icon(Icons.speaker_group_outlined)),
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Column(
                    children: <Widget>[
                      const SizedBox(
                        width: 200,
                      ),
                      DropdownButton<String>(
                        value: language,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 23,
                        elevation: 15,
                        style: const TextStyle(color: Colors.blue),
                        underline: Container(height: 1, color: Colors.blue),
                        onChanged: (String newValue) async {
                          languageCode =
                              await tts.getLanguageCodeByName(newValue);
                          voice = await getVoiceByLang(languageCode);
                          setState(() {
                            language = newValue;
                          });
                        },
                        items: languages
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get supportPause => defaultTargetPlatform != TargetPlatform.android;

  bool get supportResume => defaultTargetPlatform != TargetPlatform.android;

  void speak() {
    tts.setVolume(volume);
    tts.setRate(rate);
    if (languageCode != null) {
      tts.setLanguage(languageCode);
    }
    tts.setPitch(pitch);
    tts.speak(text);
  }
}

class aboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 24, 35, 40),
      ),
      home: Scaffold(
        appBar: NewGradientAppBar(
          title: Center(child: const Text('About')),
          gradient: LinearGradient(
            colors: [Colors.lightGreen, Colors.cyan, Colors.blue],
          ),
        ),
        drawer: Drawer(
          child: Material(
            color: Color.fromARGB(255, 24, 35, 40),
            child: ListView(
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                GradientButton(
                    callback: () {
                      Navigator.pushNamed(context, '/');
                    },
                    gradient: Gradients.rainbowBlue,
                    child: Icon(Icons.home)),
                SizedBox(
                  height: 5,
                ),
                GradientButton(
                    callback: () {
                      Navigator.pushNamed(context, '/about');
                    },
                    gradient: Gradients.rainbowBlue,
                    child: Icon(Icons.info))
              ],
            ),
          ),
        ),
        body: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 1000,
                width: 70,
              ),
              GradientCard(
                  gradient: Gradients.rainbowBlue,
                  child: Container(
                    height: 200,
                    width: 500,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "This app was made by students off SSRVM. For more information pls visit github.com/pynvimdev. This App is aimed at people with diffuculties communicating.\n\n\n                                        Build - 1.0",
                      style: TextStyle(fontSize: 20),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class runApps extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speakly',
      initialRoute: '/about',
      routes: {'/': (context) => MyApp(), '/about': (context) => aboutPage()},
    );
  }
}
