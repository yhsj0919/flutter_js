import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

typedef AlertBuilder = Function(dynamic args);

///js扩展
extension JavascriptRuntimeFetchExtension on JavascriptRuntime {
  ///启用axios
  Future<JavascriptRuntime> enableAxios() async {
    String axios = await rootBundle.loadString("assets/axios.js");
    final evalFetchResult = evaluate(axios);
    if (kDebugMode) {
      print('Axios 结果: $evalFetchResult');
    }
    return this;
  }

  ///启用sleep
  Future<JavascriptRuntime> enableSleep() async {
    String sleep = await rootBundle.loadString("assets/sleep.js");
    final evalFetchResult = evaluate(sleep);
    if (kDebugMode) {
      print('sleep 结果: $evalFetchResult');
    }
    return this;
  }

  /// 启用加密
  Future<JavascriptRuntime> enableCrypto() async {
    String crypto = await rootBundle.loadString("assets/crypto.js");
    final evalFetchResult = evaluate(crypto);
    if (kDebugMode) {
      print('crypto 结果: $evalFetchResult');
    }
    return this;
  }

  ///启用文件插件
  Future<JavascriptRuntime> enableFilePlugin({required String? path}) async {
    if (path != null) {
      var file = File(path);
      final plugin = await file.readAsString();
      final evalFetchResult = evaluate(plugin);
      if (kDebugMode) {
        print('插件结果: $path : $evalFetchResult');
      }
    }
    return this;
  }

  Future<JavascriptRuntime> enableAlert({required AlertBuilder build}) async {
    evaluate("""
    var window = {
      alert: function() {
        sendMessage('NativeAlert', JSON.stringify([...arguments]));
      },
    }
    
    function alert(channelName, message) {
          sendMessage('NativeAlert', JSON.stringify([...arguments]));
        }
        alert
    """);
    onMessage('NativeAlert', (dynamic args) {
      build.call(args);
    });
    return this;
  }

  ///启用系统文件插件
  Future<JavascriptRuntime> enableAssetsPlugin({required String path}) async {
    String plugin = await rootBundle.loadString(path);
    final evalFetchResult = evaluate(plugin);
    if (kDebugMode) {
      print('插件结果: $path : $evalFetchResult');
    }
    return this;
  }

  ///调用方法
  Future<String> _invokeMethod(String code) async {
    try {
      var asyncResult = await evaluateAsync(code);
      executePendingJob();
      return handlePromise(asyncResult).then((value) {
        if (value.isError) {
          return Future.error(value.rawResult);
        } else {
          return Future.value(value.stringResult);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("出现异常2");
      }
      return Future.error(e);
    }
  }

  Future<String> invokeMethod(
      {required String method, List<dynamic> args = const []}) {
    var result = evaluate("typeof $method === 'function'");
    if (result.rawResult == false) {
      return Future.error("尚未实现此方法");
    }
    var params = "$method(${args.map((e) => "'$e'").join(",")})";
    print("当前请求:$params");
    return _invokeMethod(params);
  }

  ///注册方法
  dynamic registerMethod(String methodName, dynamic Function(dynamic args) fn) {
    return onMessage(methodName, fn);
  }
}
