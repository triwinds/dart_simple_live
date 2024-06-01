import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/constant.dart';
import 'package:simple_live_app/app/controller/base_controller.dart';
import 'package:simple_live_app/app/event_bus.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/app/utils.dart';
import 'package:simple_live_app/models/db/follow_user.dart';
import 'package:simple_live_app/services/db_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_live_app/services/local_storage_service.dart';

class FollowUserController extends BasePageController<FollowUser> {
  StreamSubscription<dynamic>? subscription;
  StreamSubscription<dynamic>? subscriptionIndexedUpdate;

  RxList<FollowUser> allList = RxList<FollowUser>();

  /// 0:全部 1:直播中 2:未直播
  var filterMode = 0.obs;

  @override
  void onInit() {
    subscription = EventBus.instance.listen(Constant.kUpdateFollow, (p0) {
      refreshData();
    });
    subscriptionIndexedUpdate = EventBus.instance.listen(
      EventBus.kBottomNavigationBarClicked,
      (index) {
        if (index == 1) {
          scrollToTopOrRefresh();
        }
      },
    );
    if (allList.isEmpty) {
      refreshData();
    }
    super.onInit();
  }

  @override
  Future<List<FollowUser>> getData(int page, int pageSize) {
    if (page > 1) {
      return Future.value([]);
    }
    var list = DBService.instance.getFollowList();
    for (var item in list) {
      updateLiveStatus(item);
    }
    allList.assignAll(list);
    return Future.value(list);
  }

  void filterData() {
    if (filterMode.value == 0) {
      list.assignAll(allList);
      list.sort((a, b) => b.liveStatus.value.compareTo(a.liveStatus.value));
    } else if (filterMode.value == 1) {
      list.assignAll(allList.where((x) => x.liveStatus.value == 2));
    } else if (filterMode.value == 2) {
      list.assignAll(allList.where((x) => x.liveStatus.value == 1));
    }
    allList.sort((a, b) => b.liveStatus.value.compareTo(a.liveStatus.value));
  }

  void setFilterMode(int mode) {
    filterMode.value = mode;
    filterData();
  }

  void updateLiveStatus(FollowUser item) async {
    try {
      var site = Sites.allSites[item.siteId]!;
      var liveStatus = await site.liveSite.getLiveStatus(roomId: item.roomId);
      item.liveStatus.value = liveStatus.status ? 2 : 1;
      item.title = liveStatus.title;
      filterData();
    } catch (e) {
      Log.logPrint(e);
    }
  }

  void removeItem(FollowUser item) async {
    var result =
        await Utils.showAlertDialog("确定要取消关注${item.userName}吗?", title: "取消关注");
    if (!result) {
      return;
    }
    await DBService.instance.followBox.delete(item.id);
    refreshData();
  }

  @override
  void onClose() {
    subscription?.cancel();
    subscriptionIndexedUpdate?.cancel();
    super.onClose();
  }

  void exportFile() async {
    if (allList.isEmpty) {
      SmartDialog.showToast("列表为空");
      return;
    }

    try {
      var status = await Utils.checkStorgePermission();
      if (!status) {
        SmartDialog.showToast("无权限");
        return;
      }

      var dir = "";
      if (Platform.isIOS) {
        dir = (await getApplicationDocumentsDirectory()).path;
      } else {
        dir = await FilePicker.platform.getDirectoryPath() ?? "";
      }

      if (dir.isEmpty) {
        return;
      }
      var jsonFile = File(
          '$dir/SimpleLive_${DateTime.now().millisecondsSinceEpoch ~/ 1000}.json');
      var jsonText = generateJson();
      await jsonFile.writeAsString(jsonText);
      SmartDialog.showToast("已导出关注列表");
    } catch (e) {
      Log.logPrint(e);
      SmartDialog.showToast("导出失败：$e");
    }
  }

  void inputFile() async {
    try {
      var status = await Utils.checkStorgePermission();
      if (!status) {
        SmartDialog.showToast("无权限");
        return;
      }
      var file = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (file == null) {
        return;
      }
      var jsonFile = File(file.files.single.path!);
      await inputJson(await jsonFile.readAsString());
      SmartDialog.showToast("导入成功");
    } catch (e) {
      Log.logPrint(e);
      SmartDialog.showToast("导入失败:$e");
    } finally {
      refreshData();
    }
  }

  void exportText() {
    if (allList.isEmpty) {
      SmartDialog.showToast("列表为空");
      return;
    }
    var content = generateJson();
    Get.dialog(
      AlertDialog(
        title: const Text("导出为文本"),
        content: TextField(
          controller: TextEditingController(text: content),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          minLines: 5,
          maxLines: 8,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("关闭"),
          ),
          TextButton(
            onPressed: () {
              Utils.copyToClipboard(content);
              Get.back();
            },
            child: const Text("复制"),
          ),
        ],
      ),
    );
  }

  void inputText() async {
    final TextEditingController textController = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text("从文本导入"),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "请输入内容",
          ),
          minLines: 5,
          maxLines: 8,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("关闭"),
          ),
          TextButton(
            onPressed: () async {
              var content = await Utils.getClipboard();
              if (content != null) {
                textController.text = content;
              }
            },
            child: const Text("粘贴"),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.isEmpty) {
                SmartDialog.showToast("内容为空");
                return;
              }
              try {
                await inputJson(textController.text);
                SmartDialog.showToast("导入成功");
                Get.back();
                refreshData();
              } catch (e) {
                SmartDialog.showToast("导入失败，请检查内容是否正确");
              }
            },
            child: const Text("导入"),
          ),
        ],
      ),
    );
  }

  void exportWebdav() async {
    var json = generateJson();
    var username = LocalStorageService.instance.getValue(LocalStorageService.kWebdavUsername, "");
    var password = LocalStorageService.instance.getValue(LocalStorageService.kWebdavPassword, "");
    var webdavUrl = LocalStorageService.instance.getValue(LocalStorageService.kWebdavUrl, "https://www.example.com");
    var webdavUrlCtl = TextEditingController(text: webdavUrl);
    var usernameCtl = TextEditingController(text: username);
    var passwordCtl = TextEditingController(text: password);

    await Get.dialog(
      AlertDialog(
        title: const Text("导出至 Webdav"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          //position
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: webdavUrlCtl,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "请输入 Webdav 地址",
              ),
              maxLines: 1,),
            TextField(
              controller: usernameCtl,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "请输入 Webdav 用户名",
              ),
              maxLines: 1,),
            TextField(
              controller: passwordCtl,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "请输入 Webdav 密码",
              ),
              maxLines: 1,)
            ]),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("关闭"),
          ),
          TextButton(
            onPressed: () async {
              // Utils.copyToClipboard(content);
              Log.d("${webdavUrlCtl.text} ${usernameCtl.text} ${passwordCtl.text}");
              LocalStorageService.instance.setValue(LocalStorageService.kWebdavUrl, webdavUrlCtl.text);
              LocalStorageService.instance.setValue(LocalStorageService.kWebdavUsername, usernameCtl.text);
              LocalStorageService.instance.setValue(LocalStorageService.kWebdavPassword, passwordCtl.text);
              username = usernameCtl.text;
              password = passwordCtl.text;
              webdavUrl = webdavUrlCtl.text;
              Map<String, String> headers = {};
              if (username.isNotEmpty && password.isNotEmpty) {
                headers["Authorization"] = "Basic ${base64Encode(utf8.encode("$username:$password"))}";
              }
              var response = await http.put(
                Uri.parse("$webdavUrl/simple_live_follows.json"),
                headers: headers,
                body: json,
              );
              Log.d("response:${response.statusCode}, ${response.body}");
              if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
                SmartDialog.showToast("导出成功");
              } else {
                SmartDialog.showToast("导出失败, status code: ${response.statusCode}");
              }
              Get.back();
            },
            child: const Text("导出"),
          ),
        ],
      ),
    );
  }

  void importWebdav() async {
    var username = LocalStorageService.instance.getValue(LocalStorageService.kWebdavUsername, "");
    var password = LocalStorageService.instance.getValue(LocalStorageService.kWebdavPassword, "");
    var webdavUrl = LocalStorageService.instance.getValue(LocalStorageService.kWebdavUrl, "https://www.example.com");
    var webdavUrlCtl = TextEditingController(text: webdavUrl);
    var usernameCtl = TextEditingController(text: username);
    var passwordCtl = TextEditingController(text: password);

    await Get.dialog(
      AlertDialog(
        title: const Text("导出至 Webdav"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          //position
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: webdavUrlCtl,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "请输入 Webdav 地址",
              ),
              maxLines: 1,),
            TextField(
              controller: usernameCtl,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "请输入 Webdav 用户名",
              ),
              maxLines: 1,),
            TextField(
              controller: passwordCtl,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "请输入 Webdav 密码",
              ),
              maxLines: 1,)
            ]),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("关闭"),
          ),
          TextButton(
            onPressed: () async {
              // Utils.copyToClipboard(content);
              Log.d("${webdavUrlCtl.text} ${usernameCtl.text} ${passwordCtl.text}");
              LocalStorageService.instance.setValue(LocalStorageService.kWebdavUrl, webdavUrlCtl.text);
              LocalStorageService.instance.setValue(LocalStorageService.kWebdavUsername, usernameCtl.text);
              LocalStorageService.instance.setValue(LocalStorageService.kWebdavPassword, passwordCtl.text);
              username = usernameCtl.text;
              password = passwordCtl.text;
              webdavUrl = webdavUrlCtl.text;
              Map<String, String> headers = {};
              if (username.isNotEmpty && password.isNotEmpty) {
                headers["Authorization"] = "Basic ${base64Encode(utf8.encode("$username:$password"))}";
              }
              var response = await http.get(
                Uri.parse("$webdavUrl/simple_live_follows.json"),
                headers: headers,
              );
              Log.d("response:${response.statusCode}, ${utf8.decode(response.bodyBytes)}");
              if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
                try {
                  await inputJson(utf8.decode(response.bodyBytes));
                  refreshData();
                  SmartDialog.showToast("导入成功");
                } on Exception catch (e, stacktrace) {
                  Log.e("Fail to import json, $e", stacktrace);
                  SmartDialog.showToast("导入失败");
                }
                
              } else {
                SmartDialog.showToast("导入失败, status code: ${response.statusCode}");
              }
              Get.back();
            },
            child: const Text("导入"),
          ),
        ],
      ),
    );
  }

  String generateJson() {
    var data = allList
        .map(
          (item) => {
            "siteId": item.siteId,
            "id": item.id,
            "roomId": item.roomId,
            "userName": item.userName,
            "face": item.face,
            "addTime": item.addTime.toString(),
          },
        )
        .toList();
    return jsonEncode(data);
  }

  Future inputJson(String content) async {
    var data = jsonDecode(content);

    for (var item in data) {
      var user = FollowUser.fromJson(item);
      await DBService.instance.followBox.put(user.id, user);
    }
  }
}
