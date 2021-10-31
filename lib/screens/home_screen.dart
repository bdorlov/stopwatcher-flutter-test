import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

//import 'dart:isolate';

import 'package:path_provider/path_provider.dart';

import '../models/measurement.dart';


const timerTimeout = 5;


List<Measurement> decodeHistory(String data) {
  Iterable historyIterator = jsonDecode(data);
  return List<Measurement>.from(historyIterator.map((model) => Measurement.fromJson(model))).cast();
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}): super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int timeDifference = 0;
  Timer? _timer;
  DateTime? _startDateTime = DateTime.now();
  bool isRunning = false;

  List<Measurement> history = [];

  @override
  void initState() {
    loadHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stopwatcher"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info,
              color: Color.fromARGB(255, 100, 200, 255),
              size: 32,
              semanticLabel: 'This is my good icon!',
            ),
            onPressed: () {
              LicenseRegistry.addLicense(() async* {
                yield const LicenseEntryWithLineBreaks(["gatsby-package", "netlify-package"], "Cool additional packages");
              });
              showAboutDialog(
                context: context,
                applicationName: 'Stopwatcher',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Bla-bla-bla',
                children: [
                  const Text("This is the coolest Stopwatcher int the world!")
                ]
              );
            }
          )
        ]
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Center(child: Text(_filePath)),
          const Spacer(flex: 2),
          Text(_resultValue),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  isRunning ? stopTimer() : startTimer();
                },
                child: isRunning ? const Text('Stop') : const Text('Start')
              ),
              const SizedBox(width: 40),
              ElevatedButton(
                onPressed: () async {
                  debugPrint('clear');

                  setState(() {
                    timeDifference = 0;
                    history.clear();
                  });
                  removeFile();

                  // ReceivePort receivePort = ReceivePort();
                  // Isolate.spawn<SendPort>(testProc, receivePort.sendPort, debugName: "remoteIsolate");
                  // receivePort.listen((message) {
                  //   debugPrint("+++++Message from isolate: " + message.toString());
                  // });
                },
                child: const Text('Clear')
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Expanded(
            flex: 10,
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 5,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurpleAccent.shade400, width: 3),
                borderRadius: const BorderRadius.all(Radius.circular(10))
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(10),
                itemCount: history.length,
                itemBuilder: (BuildContext context, int index) {
                  debugPrint('>>>> index: $index');
                  return Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Colors.black38,
                          offset: Offset(5, 5),
                          blurRadius: 10.0,
                          spreadRadius: 2.0
                        )
                      ],
                      color: const Color.fromRGBO(240, 240, 255, 0.98)
                    ),
                    child: ListTile(
                      title: Text(
                        getTimeDifferenceString(history[index].period),
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.blueGrey
                        )
                      ),
                      subtitle: Text(
                        history[index].dateTime.toString(),
                        style: const TextStyle(
                          color: Color.fromARGB(155, 0, 0, 50)
                        )
                      )
                    ),
                  );
                }
              ),
            ),
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: saveHistory,
        backgroundColor: Colors.deepOrange,
      )
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void startTimer() {
    _startDateTime = DateTime.now();
    DateTime currentDateTime;
    _timer = Timer.periodic(
      const Duration(milliseconds: timerTimeout),
      (timer) {
        currentDateTime = DateTime.now();
        setState(() {
          timeDifference = currentDateTime.difference(_startDateTime!).inMilliseconds;
        });
      }
    );
    isRunning = true;
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      Measurement measurement = Measurement(period: timeDifference, dateTime: DateTime.now());
      history.insert(0, measurement);
    });
  }

  String getTimeDifferenceString(int difference) {
    return (difference / 1000).toStringAsFixed(2);
  }

  String get _resultValue {
    return timeDifference > 0 ? getTimeDifferenceString(timeDifference) : "No data";
  }

  Future<File> get _localFile async {
    String path = await _localPath;
    return File('$path/data.txt');
  }

  void writeFile(String text, {bool remove = false}) async {
    try {
      final file = await _localFile;
      if (remove) {
        await file.delete();
      } else {
        file.writeAsString(text);
      }
    } catch (e) {
      debugPrint(e.toString());
    } 
    
  }

  void removeFile() async {
    writeFile("", remove: true);
  }

  Future<String> readFile() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      debugPrint(e.toString());
      return "[]";
    }
    
  }

  void saveHistory() async {
    String historyString = jsonEncode(history);
    //debugPrint('historyString >>>> $historyString');
    writeFile(historyString);
  }

  void loadHistory() async {
    try {
      String data = await readFile();
      //debugPrint("=====data>>>: $data");
      List<Measurement> values = await compute(decodeHistory, data);
      setState(() {
        history = values;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // static void testProc(SendPort sendPort) {
  //   for (int i = 0; i < 10; i++) {
  //     sleep(const Duration(seconds: 1));
  //     debugPrint('>>>> from isolate: ' + i.toString());
  //     sendPort.send(i);
  //   }
  // }
}