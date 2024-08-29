import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

///js扩展
extension JavascriptRuntimeExtension on JavascriptRuntime {
  ///启用文件插件
  Future<JavascriptRuntime> enableFilePlugin({required String? path}) async {
    if (path != null) {
      var file = File(path);
      final plugin = await file.readAsString();
      final evalResult = evaluate(plugin);
      if (kDebugMode) {
        print('插件结果: $path : $evalResult');
      }
    }
    return this;
  }

  ///启用系统文件插件
  Future<JavascriptRuntime> enableAssetsPlugin({required String path}) async {
    String plugin = await rootBundle.loadString(path);
    final evalResult = evaluate(plugin);
    if (kDebugMode) {
      print('插件结果: $path : $evalResult');
    }
    return this;
  }

  ///启用字符串插件
  Future<JavascriptRuntime> enableStringPlugin({required String code}) async {
    final evalResult = evaluate(code);
    if (kDebugMode) {
      print('插件结果: code : $evalResult');
    }
    return this;
  }

  ///注入方法
  ///@method 方法名
  ///@dynamic Function(dynamic args) 方法回调，args为js参数
  dynamic injectMethod(String method, dynamic Function(dynamic args) fn) {
    evaluate("""
      async function $method() {
         return await sendMessage('$method', JSON.stringify([...arguments]));
      }
    """);
    onMessage('$method', (dynamic args) {
      return fn.call(args);
    });
    return this;
  }

  ///调用语句
  ///@code 字符串
  ///@return dynamic类型
  Future<dynamic> invokeCode(String code) async {
    try {
      var asyncResult = await evaluateAsync(code);
      executePendingJob();
      return handlePromise(asyncResult).then((value) {
        if (value.isError) {
          print("出现异常2");
          return Future.error(value.rawResult);
        } else {
          return Future.value(value.rawResult);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("出现异常2");
      }
      return Future.error(e);
    }
  }

  ///执行方法
  ///@method 方法名
  ///@args 参数，支持String，num，Map，Iterable基本类型
  ///@return dynamic类型
  Future<dynamic> invokeMethod({required String method, List<dynamic> args = const []}) {
    var result = evaluate("typeof $method === 'function'");
    if (result.rawResult == false) {
      return Future.error("尚未实现此方法");
    }

    var params = args.map((e) {
      if (e is String) {
        return "'$e'";
      } else if (e is num) {
        return "$e";
      } else if (e is Map) {
        return "JSON.parse('${json.encode(e)}')";
      } else if (e is Iterable) {
        return "JSON.parse('${json.encode(e)}')";
      } else {
        return "'$e'";
      }
    }).join(",");

    var request = "$method($params)";
    if (kDebugMode) {
      print("当前请求:$request");
    }
    return invokeCode(request);
  }
}
