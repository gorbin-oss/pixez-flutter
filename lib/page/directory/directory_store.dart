/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'directory_store.g.dart';

class DirectoryStore = _DirectoryStoreBase with _$DirectoryStore;

abstract class _DirectoryStoreBase with Store {
  static const platform = const MethodChannel('com.perol.dev/save');
  @observable
  String path;
  @observable
  bool checkSuccess = false;

  @observable
  ObservableList<FileSystemEntity> list = ObservableList();
  SharedPreferences _preferences;

  _DirectoryStoreBase() {
    init();
  }

  @action
  Future<void> enterFolder(Directory fileSystemEntity) async {
    path = fileSystemEntity.path;
    list = ObservableList.of(fileSystemEntity.listSync());
  }

  @action
  Future<void> undo() async {
    path = (await platform.invokeMethod('get_path')) as String;
    list = ObservableList.of(Directory(path).listSync());
  }

  @action
  Future<void> check() async {
    if (!path.contains("/storage/emulated/0")) {
      return;
    }
    await _preferences.setString("store_path", path);
    checkSuccess = true;
  }

  @action
  Future<void> backFolder() async {
    final fileSystemEntity = Directory(path).parent;
    if (!fileSystemEntity.path.contains("/storage/emulated/0")) {
      return;
    }
    path = fileSystemEntity.path;
    list = ObservableList.of(fileSystemEntity.listSync());
  }

  @action
  setPath(String result) {
    path = result;
  }

  @action
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    path = _preferences.getString("store_path") ??
        (await getExternalStorageDirectory()).path;//绝了
    final directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync();
    }
    list = ObservableList.of(Directory(path).listSync());
  }
}
