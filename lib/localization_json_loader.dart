library localization_json_loader;

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sp_util/sp_util.dart';

import 'asset_loader.dart';

class JsonLoader extends AssetLoader {
  /// 获取资源文件中的语言包
  Future<String> getLocaleAssetsPath(Locale locale) async {
    return 'assets/i18n/${localeToString(locale, separator: "_")}.json';
  }

  /// 获取用户目录中的语言包
  Future<String> getLocaleDocPath(Locale locale) async {
    var appDocDir = await getApplicationDocumentsDirectory();
    var appDocPath = appDocDir.path;
    return '$appDocPath/i18n/${localeToString(locale, separator: "_")}.json';
  }

  Future<Map<String, dynamic>> loadJsonWithLocale(Locale locale) async {
    var haveLocalLanguage = SpUtil.getBool('localLanguage');
    Map<String, dynamic> localeMap;
    var localePath;
    if (haveLocalLanguage) {
      localePath = await getLocaleDocPath(locale);
      var file = File(localePath);
      if (file.existsSync()) {
        var localeStr = await file.readAsString();
        localeMap = json.decode(localeStr);
      }
    }

    if (localeMap == null) {
      localePath = await getLocaleAssetsPath(locale);
      localeMap =
          await compute(_parseData, await rootBundle.loadString(localePath));
    }

    log('localization loader: load json file $localePath');
    return localeMap;
  }

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return await loadJsonWithLocale(locale);
  }
}

/// 解析数据
Map<String, dynamic> _parseData(String data) {
  final Map<String, dynamic> d = json.decode(data) as Map<String, dynamic>;
  return d;
}
