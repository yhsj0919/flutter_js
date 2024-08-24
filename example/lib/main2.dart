import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'plugins_ext.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JsCallDart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _jsResult = '';
  JavascriptRuntime? flutterJs;

  @override
  void initState() {
    super.initState();

    flutterJs = getJavascriptRuntime();
    flutterJs?.injectMethod("alert", (args) {
      String output = args.join(' ');
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // 用户必须点击按钮来关闭对话框
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('JS Alert'),
            content: SingleChildScrollView(
              child: Text('$output'),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭对话框
                },
              ),
            ],
          );
        },
      );
    });

    flutterJs?.enableAssetsPlugin(path: "assets/test.js");

    flutterJs?.injectMethod('getDataAsync', (dynamic args) {
      return "来自Dart的消息";
    });

    flutterJs?.injectMethod('dartMethod', (dynamic args) {
      return "这是静态消息";
    });

    flutterJs?.injectMethod('asyncWithError', (_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      return Future.error('Some error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("JsCallDart"),
      ),
      body: Center(
        child: Text("${_jsResult}"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.javascript_outlined),
        label: Text("互相调用"),
        onPressed: () {
          setState(() {
            _jsResult = "";
          });
          // flutterJs?.evaluate('''
          //
          // var sss=JSON.parse('{"aa":"bb"}')
          //
          // test2('a',2)
          //
          // ''');

          flutterJs?.invokeMethod(method: 'test2', args: [
            "sss",
            {"aa": "vvv"},
            ["sss","dddd"]
          ]).then((v) {
            setState(() {
              _jsResult = v;
            });
          });
        },
      ),
    );
  }
}
