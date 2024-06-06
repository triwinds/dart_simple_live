// ignore_for_file: prefer_inlined_adds

import 'package:get/get.dart';
import 'package:simple_live_app/modules/categoty_detail/category_detail_controller.dart';
import 'package:simple_live_app/modules/categoty_detail/category_detail_page.dart';
import 'package:simple_live_app/modules/indexed/indexed_controller.dart';
import 'package:simple_live_app/modules/live_room/live_room_controller.dart';
import 'package:simple_live_app/modules/live_room/live_room_page.dart';
import 'package:simple_live_app/modules/search/search_controller.dart';
import 'package:simple_live_app/modules/search/search_page.dart';
import 'package:simple_live_app/modules/sync/device/sync_device_controller.dart';
import 'package:simple_live_app/modules/sync/device/sync_device_page.dart';
import 'package:simple_live_app/modules/sync/scan_qr/sync_scan_qr_controller.dart';
import 'package:simple_live_app/modules/sync/scan_qr/sync_scan_qr_page.dart';
import 'package:simple_live_app/modules/toolbox/toolbox_controller.dart';
import 'package:simple_live_app/modules/toolbox/toolbox_page.dart';
import 'package:simple_live_app/modules/sync/sync_controller.dart';
import 'package:simple_live_app/modules/sync/sync_page.dart';
import 'package:simple_live_app/modules/user/account/account_controller.dart';
import 'package:simple_live_app/modules/user/account/account_page.dart';
import 'package:simple_live_app/modules/user/account/bilibili/qr_login_controller.dart';
import 'package:simple_live_app/modules/user/account/bilibili/qr_login_page.dart';
import 'package:simple_live_app/modules/user/account/bilibili/web_login_controller.dart';
import 'package:simple_live_app/modules/user/account/bilibili/web_login_page.dart';
import 'package:simple_live_app/modules/user/appstyle_setting_page.dart';
import 'package:simple_live_app/modules/user/auto_exit_settings_page.dart';
import 'package:simple_live_app/modules/user/danmu_settings_page.dart';
import 'package:simple_live_app/modules/user/danmu_shield/danmu_shield_controller.dart';
import 'package:simple_live_app/modules/user/danmu_shield/danmu_shield_page.dart';
import 'package:simple_live_app/modules/user/follow_user/follow_user_controller.dart';
import 'package:simple_live_app/modules/user/follow_user/follow_user_page.dart';
import 'package:simple_live_app/modules/user/history/history_controller.dart';
import 'package:simple_live_app/modules/user/history/history_page.dart';
import 'package:simple_live_app/modules/user/indexed_settings/indexed_settings_controller.dart';
import 'package:simple_live_app/modules/user/indexed_settings/indexed_settings_page.dart';
import 'package:simple_live_app/modules/user/other/other_settings_controller.dart';
import 'package:simple_live_app/modules/user/other/other_settings_page.dart';
import 'package:simple_live_app/modules/user/play_settings_page.dart';
import 'package:simple_live_app/modules/user/test_page.dart';

import '../modules/indexed/indexed_page.dart';
import 'route_path.dart';

class AppPages {
  AppPages._();
  static final routes = [
    // 首页
    GetPage(
      name: RoutePath.kIndex,
      page: () => const IndexedPage(),
      bindings: [
        BindingsBuilder.put(() => IndexedController()),
        //BindingsBuilder.put(() => HomeController()),
      ],
    ),
    // 观看记录
    GetPage(
      name: RoutePath.kHistory,
      page: () => const HistoryPage(),
      bindings: [
        BindingsBuilder.put(() => HistoryController()),
      ],
    ),
    // 关注用户
    GetPage(
      name: RoutePath.kFollowUser,
      page: () => const FollowUserPage(),
      bindings: [
        BindingsBuilder.put(() => FollowUserController()),
      ],
    ),
    // 搜索
    GetPage(
      name: RoutePath.kSearch,
      page: () => const SearchPage(),
      bindings: [
        BindingsBuilder.put(() => AppSearchController()),
      ],
    ),
    //分类详情
    GetPage(
      name: RoutePath.kCategoryDetail,
      page: () => const CategoryDetailPage(),
      binding: BindingsBuilder.put(
        () => CategoryDetailController(
          site: Get.arguments[0],
          subCategory: Get.arguments[1],
        ),
      ),
    ),
    //直播间
    GetPage(
      name: RoutePath.kLiveRoomDetail,
      page: () => const LiveRoomPage(),
      binding: BindingsBuilder.put(
        () => LiveRoomController(
          pSite: Get.arguments,
          pRoomId: Get.parameters["roomId"] ?? "",
        ),
      ),
    ),
    //弹幕设置
    GetPage(
      name: RoutePath.kSettingsDanmu,
      page: () => const DanmuSettingsPage(),
    ),
    //外观设置
    GetPage(
        name: RoutePath.kAppstyleSetting,
        page: () => const AppstyleSettingPage()),
    //播放设置
    GetPage(
      name: RoutePath.kSettingsPlay,
      page: () => const PlaySettingsPage(),
    ),
    //播放设置
    GetPage(
      name: RoutePath.kSettingsAutoExit,
      page: () => const AutoExitSettingsPage(),
    ),
    //工具箱
    GetPage(
      name: RoutePath.kTools,
      page: () => const ToolBoxPage(),
      bindings: [
        BindingsBuilder.put(() => ToolBoxController()),
      ],
    ),
    //关键词屏蔽
    GetPage(
      name: RoutePath.kSettingsDanmuShield,
      page: () => const DanmuShieldPage(),
      bindings: [
        BindingsBuilder.put(() => DanmuShieldController()),
      ],
    ),
    //主页设置
    GetPage(
      name: RoutePath.kSettingsIndexed,
      page: () => const IndexedSettingsPage(),
      bindings: [
        BindingsBuilder.put(() => IndexedSettingsController()),
      ],
    ),
    //账号设置
    GetPage(
      name: RoutePath.kSettingsAccount,
      page: () => const AccountPage(),
      bindings: [
        BindingsBuilder.put(() => AccountController()),
      ],
    ),
    //哔哩哔哩Web登录
    GetPage(
      name: RoutePath.kBiliBiliWebLogin,
      page: () => const BiliBiliWebLoginPage(),
      bindings: [
        BindingsBuilder.put(() => BiliBiliWebLoginController()),
      ],
    ),
    //哔哩哔哩二维码登录
    GetPage(
      name: RoutePath.kBiliBiliQRLogin,
      page: () => const BiliBiliQRLoginPage(),
      bindings: [
        BindingsBuilder.put(() => BiliBiliQRLoginController()),
      ],
    ),
    // 数据同步
    GetPage(
      name: RoutePath.kSync,
      page: () => const SyncPage(),
      bindings: [
        BindingsBuilder.put(() => SyncController()),
      ],
    ),
    //扫码
    GetPage(
      name: RoutePath.kSyncScan,
      page: () => const SyncScanQRPage(),
      bindings: [
        BindingsBuilder.put(() => SyncScanQRControlelr()),
      ],
    ),
    //同步设备
    GetPage(
      name: RoutePath.kSyncDevice,
      page: () => const SyncDevicePage(),
      bindings: [
        BindingsBuilder.put(
          () => SyncDeviceController(
            client: Get.arguments['client'],
            info: Get.arguments['info'],
          ),
        ),
      ],
    ),
    //其他设置
    GetPage(
      name: RoutePath.kSettingsOther,
      page: () => const OtherSettingsPage(),
      bindings: [
        BindingsBuilder.put(() => OtherSettingsController()),
      ],
    ),

    //测试页面
    GetPage(
      name: RoutePath.kTest,
      page: () => const TestPage(),
      bindings: [
        BindingsBuilder.put(() => TestController()),
      ],
    ),
  ];
}
