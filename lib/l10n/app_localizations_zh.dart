// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '设备管理器';

  @override
  String get login => '登录';

  @override
  String get logout => '退出登录';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get loginButton => '登录';

  @override
  String get loginProblem => '登录遇到问题?';

  @override
  String get resetPassword => '重置密码';

  @override
  String get accountAppeal => '账号申诉';

  @override
  String get cancel => '取消';

  @override
  String welcome(String name) {
    return '欢迎，$name！';
  }

  @override
  String get loginFailed => '登录失败，请检查用户名和密码';

  @override
  String get networkError => '网络错误，请检查连接后重试';

  @override
  String get checkingLoginState => '检查登录状态...';

  @override
  String get startingApp => '正在启动应用...';

  @override
  String get loginExpired => '登录已过期，请重新登录';

  @override
  String get pleaseEnterUsername => '请输入用户名';

  @override
  String get pleaseEnterPassword => '请输入密码';

  @override
  String get passwordLogin => '账号密码登录';

  @override
  String get devices => '设备';

  @override
  String get dashboard => '仪表盘';

  @override
  String get mine => '我的';

  @override
  String get iot => '物联网';

  @override
  String get searchDeviceIdName => '搜索设备ID/名称';

  @override
  String get loadingDevicesFailed => '加载设备数据失败';

  @override
  String get networkConnectionFailed => '网络连接失败';

  @override
  String get serverError => '服务器错误';

  @override
  String get retry => '重试';

  @override
  String get noDeviceData => '暂无设备数据';

  @override
  String get loadingMoreDevices => '正在加载更多设备...';

  @override
  String allDevicesLoaded(int count) {
    return '已加载全部设备 (共$count个)';
  }

  @override
  String get online => '在线';

  @override
  String get offline => '离线';

  @override
  String get usageRate => '使用量';

  @override
  String get alerts => '告警';

  @override
  String get operationLog => '操作日志';

  @override
  String get remoteSettings => '远程设置';

  @override
  String get deviceOfflineCannotRemoteSet => '设备离线，无法进行远程设置';

  @override
  String get deviceLock => '设备关锁';

  @override
  String get deviceUnlock => '设备开锁';

  @override
  String get notPowered => '未通电';

  @override
  String get charging => '充电中';

  @override
  String get fullyCharged => '已充满';

  @override
  String get organizationUnitEmpty => '所属组织单位暂无';

  @override
  String get confirmExit => '确认退出';

  @override
  String get confirmLogoutMessage => '确定要退出登录吗？';

  @override
  String get logoutSuccess => '退出成功';

  @override
  String get logoutFailed => '退出失败，请重试';

  @override
  String get versionUpdate => '版本更新';

  @override
  String get aboutUs => '关于我们';

  @override
  String get versionUpdateTodo => '版本更新功能待实现';

  @override
  String get aboutUsTodo => '关于我们功能待实现';

  @override
  String get userRoleEmpty => '用户所属角色暂无';

  @override
  String get user => '用户';

  @override
  String get confirm => '确定';

  @override
  String get usageDistribution => '使用率分布';

  @override
  String get todayAlerts => '今日告警';

  @override
  String get operationLogs => '操作日志';

  @override
  String get alarm => '提醒';

  @override
  String get severe => '严重';

  @override
  String get deviceReport => '设备上报';

  @override
  String get platformDispatch => '平台下发';

  @override
  String get todayUsageTop5 => '今日使用量TOP5';

  @override
  String get loadDeviceDataFailed => '加载设备数据失败!';

  @override
  String remoteOpenCabinetDoor(String slotId) {
    return '是否远程打开$slotId柜门?';
  }

  @override
  String get pleaseEnterAdminPassword => '请输入管理员密码';

  @override
  String cabinetDoorOpening(String slotId) {
    return '正在打开$slotId柜门...';
  }

  @override
  String cabinetDoorOpenedSuccessfully(String slotId) {
    return '$slotId柜门已成功打开';
  }

  @override
  String cabinetDoorOpenFailed(String slotId) {
    return '$slotId柜门打开失败，请重试';
  }

  @override
  String get deviceCannotRemoteClose => '设备无法远程关闭';

  @override
  String get error => '错误';

  @override
  String get loginError => '登录错误';

  @override
  String get todayUsage => '今日使用量';

  @override
  String get noUsageRecords => '暂无使用记录';

  @override
  String get noUsageDataAvailable => '暂无使用数据';

  @override
  String get operationInfo => '操作信息';

  @override
  String get operationTime => '操作时间';

  @override
  String get usageInfo => '使用信息';

  @override
  String get usageTime => '使用时间';

  @override
  String inUse(Object port) {
    return '$port 正在使用';
  }

  @override
  String get noAlertData => '暂无告警数据';

  @override
  String get noAlertInfo => '暂无告警信息';

  @override
  String get alertInfo => '告警信息';

  @override
  String get alertTime => '告警时间';

  @override
  String get propertyReport => '属性上报';

  @override
  String get noLogData => '暂无日志数据';

  @override
  String get noLogInfo => '暂无日志信息';
}
