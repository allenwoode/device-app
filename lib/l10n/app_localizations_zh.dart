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
  String get ok => '确定';

  @override
  String get success => '成功';

  @override
  String get failed => '失败';

  @override
  String get finish => '完成';

  @override
  String get continueConfig => '继续配置';

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
  String get loadingMoreDevices => '加载更多设备...';

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
  String get versionUpdateTodo => '已经是最新版本';

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
  String get notice => '提醒';

  @override
  String get alarm => '警报';

  @override
  String get severe => '严重';

  @override
  String get report => '属性上报';

  @override
  String get dispatch => '平台下发';

  @override
  String get event => '事件上报';

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
  String inIdel(Object port) {
    return '$port 空闲中';
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
  String get noLogData => '暂无日志数据';

  @override
  String get noLogInfo => '暂无日志信息';

  @override
  String get deviceConnector => '设备配网';

  @override
  String get deviceManagement => '设备管理';

  @override
  String get feedback => '反馈建议';

  @override
  String get settings => '设置';

  @override
  String get deviceUnbind => '设备解绑';

  @override
  String get confirmDeviceUnbind => '确定对当前设备解绑吗？';

  @override
  String get unbind => '解绑';

  @override
  String get addDevice => '添加设备';

  @override
  String get scanQROrEnterID => '扫描二维码或手动输入设备ID';

  @override
  String get unbindDevices => '解绑设备';

  @override
  String get batchUnbindDevices => '将批量对设备进行解绑';

  @override
  String get deviceAddedSuccessfully => '设备添加成功';

  @override
  String get enterDeviceIDManually => '手动输入设备ID';

  @override
  String get pleaseEnterDeviceID => '请输入设备ID';

  @override
  String get bindDevice => '绑定设备';

  @override
  String get scanQRCode => '扫描二维码';

  @override
  String get scanDeviceQRCode => '扫描设备二维码';

  @override
  String get bindFailed => '绑定失败，请检查设备ID是否正确';

  @override
  String get bindOperationFailed => '绑定操作异常，请重试';

  @override
  String get loadDeviceListFailed => '加载设备列表失败';

  @override
  String get pleaseSelectAtLeastOneDevice => '请至少选择一个设备';

  @override
  String get confirmUnbindDevices => '确认解绑设备';

  @override
  String confirmUnbindMessage(int count) {
    return '确定要解绑选中的 $count 个设备吗？此操作不可撤销。';
  }

  @override
  String get unbindingDevices => '正在解绑设备...';

  @override
  String pleaseWaitProcessingDevices(int count) {
    return '请稍候，正在处理 $count 个设备';
  }

  @override
  String get noDevicesToUnbind => '暂无设备可解绑';

  @override
  String get unbindWarning => '解绑设备后将无法再控制该设备';

  @override
  String selectedDevicesCount(int count) {
    return '已选择 $count 个设备';
  }

  @override
  String get selectAll => '全选';

  @override
  String get clear => '清空';

  @override
  String allDevicesLoadedCount(int count) {
    return '已加载全部 $count 个设备';
  }

  @override
  String unbindCount(int count) {
    return '解绑($count)';
  }

  @override
  String successfullyUnbound(int count) {
    return '成功解绑 $count 个设备';
  }

  @override
  String get unbindFailedRetry => '解绑失败，请重试';

  @override
  String unbindMixed(int success, int failed) {
    return '成功解绑 $success 个设备，$failed 个失败';
  }

  @override
  String get unbindOperationError => '解绑操作异常，请重试';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get languageSettings => '语言设置';

  @override
  String currentLanguage(String language) {
    return '当前语言：$language';
  }

  @override
  String get notificationSettings => '消息通知';

  @override
  String get notificationSettingsSubtitle => '管理推送通知设置';

  @override
  String get notificationFeatureTodo => '通知设置功能待开发';

  @override
  String get privacySecurity => '隐私与安全';

  @override
  String get privacySecuritySubtitle => '修改登录密码';

  @override
  String get securityFeatureTodo => '安全设置功能待开发';

  @override
  String get storageManagement => '存储管理';

  @override
  String get storageManagementSubtitle => '清理缓存和本地数据';

  @override
  String get clearCache => '清理缓存';

  @override
  String get clearCacheConfirm => '确定要清理应用缓存吗？这将删除临时文件，但不会影响您的个人数据。';

  @override
  String get cacheCleared => '缓存清理完成';

  @override
  String get saveLanguageSettingsFailed => '保存语言设置失败，请重试';

  @override
  String get feedbackType => '反馈类型';

  @override
  String get feedbackContent => '反馈内容';

  @override
  String get contactInfo => '联系方式（可选）';

  @override
  String get feedbackHint => '请详细描述您的问题或建议...';

  @override
  String get contactHint => '请输入您的邮箱或手机号';

  @override
  String get contactHelpText => '提供联系方式有助于我们更好地回复您';

  @override
  String get submitFeedback => '提交反馈';

  @override
  String get pleaseFillFeedback => '请输入反馈内容';

  @override
  String get feedbackSubmitSuccess => '反馈提交成功';

  @override
  String get feedbackSubmitFailed => '提交失败，请重试';

  @override
  String get featureSuggestion => '功能建议';

  @override
  String get bugReport => '问题反馈';

  @override
  String get usageQuestion => '使用咨询';

  @override
  String get deposit => '存';

  @override
  String get withdraw => '取';

  @override
  String get other => '其他';

  @override
  String get permissionInsufficient => '权限不足';

  @override
  String get cameraPermissionRequired => '需要相机权限才能扫描二维码，请在设置中开启相机权限。';

  @override
  String get processing => '正在处理中...';

  @override
  String get bindingDevice => '正在绑定设备...';

  @override
  String get bindSuccess => '绑定成功';

  @override
  String get scanInstructions => '将设备二维码放入扫描框内';

  @override
  String get scanHint => '扫描成功后将自动绑定设备';

  @override
  String get ready => '准备就绪';

  @override
  String get readyForNextDevice => '准备配置下一台设备';

  @override
  String autoConnectingToDevice(String name) {
    return '自动连接到 $name...';
  }

  @override
  String get scanningAzDevices => '正在扫描蓝牙设备...';

  @override
  String foundAzDevices(int count) {
    return '找到 $count 个蓝牙设备';
  }

  @override
  String connectedTo(String name) {
    return '已连接到 $name';
  }

  @override
  String get connectionFailed => '连接失败';

  @override
  String get disconnected => '已断开连接';

  @override
  String get sendingConfig => '发送配置中...';

  @override
  String get configSentSuccess => '发送配置成功';

  @override
  String get configSentFailed => '发送配置失败';

  @override
  String get connecting => '正在连接...';

  @override
  String get scanning => '扫描中...';

  @override
  String get scanAzDevices => '扫描蓝牙设备';

  @override
  String get disconnect => '断开';

  @override
  String get sendConfig => '发送配置';

  @override
  String get startScanning => '开始扫描蓝牙设备';

  @override
  String scanComplete(int count) {
    return '扫描完成，找到 $count 个设备';
  }

  @override
  String get noAzDevices => '未找到蓝牙设备，请确保设备已开启';

  @override
  String get scanError => '扫描错误';

  @override
  String attemptingConnection(String name) {
    return '尝试连接到: $name';
  }

  @override
  String get connectionSuccess => '连接成功';

  @override
  String get errorConnectFirst => '请先连接设备';

  @override
  String get errorEnterSsid => '请输入 WiFi SSID';

  @override
  String get errorEnterPassword => '请输入 WiFi 密码';

  @override
  String get startSendingWifiConfig => '开始发送 WiFi 配置';

  @override
  String get ssid => 'SSID';

  @override
  String get passwordLength => '密码长度';

  @override
  String get sendException => '发送异常';

  @override
  String get deviceAcceptedConfig => '✓ 设备已接受配置';

  @override
  String get deviceRejectedConfig => '✗ 设备拒绝配置';

  @override
  String get receivingFrame => '接收帧';

  @override
  String get deviceResponse => '设备响应';

  @override
  String get frameProcessingError => '帧处理错误';

  @override
  String get unknownDataFormat => '未知数据格式';

  @override
  String get waitingForDeviceResponse => '等待设备响应...';

  @override
  String get deviceResponseTimeout => '设备响应超时，请检查WIFI密码是否正确';

  @override
  String get foundAzDevicesLabel => '找到的蓝牙设备:';

  @override
  String get wifiConfig => 'WiFi 配置';

  @override
  String get wifiSsid => 'WiFi SSID';

  @override
  String get wifiPassword => 'WiFi 密码';

  @override
  String get enterWifiPassword => '输入WiFi密码';

  @override
  String get logs => '日志:';

  @override
  String get receivedNotification => '收到通知';

  @override
  String get usageStatus => '使用状态:';

  @override
  String get lockStatus => '锁状态:';

  @override
  String get chargingStatus => '充电状态:';

  @override
  String get pleaseEnableBluetooth => '请开启蓝牙';

  @override
  String get bluetoothNotEnabled => '蓝牙未开启';

  @override
  String get bluetoothEnabled => '已开启蓝牙';

  @override
  String get bluetoothRequired => '需要蓝牙';

  @override
  String get bluetoothRequiredMessage => '扫描设备需要开启蓝牙，是否现在开启？';

  @override
  String get turnOn => '开启';

  @override
  String get changePassword => '修改密码';

  @override
  String get oldPassword => '当前密码';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get pleaseEnterOldPassword => '请输入当前密码';

  @override
  String get pleaseEnterNewPassword => '请输入新密码';

  @override
  String get pleaseEnterConfirmPassword => '请确认新密码';

  @override
  String get passwordsDoNotMatch => '新密码与确认密码不一致';

  @override
  String get passwordTooShort => '密码长度至少为6位';

  @override
  String get updatePassword => '更新密码';

  @override
  String get passwordUpdateSuccess => '密码修改成功';

  @override
  String get passwordUpdateFailed => '密码修改失败，请检查当前密码是否正确';

  @override
  String get oldPasswordIncorrect => '当前密码不正确';

  @override
  String get passwordResetSuccess => '密码重置成功';

  @override
  String get passwordResetFailed => '密码重置失败';

  @override
  String get operateCabinetDoor => '操作柜门';

  @override
  String get deviceCharging => '设备充电';

  @override
  String get operatePanel => '操作面板';

  @override
  String get deviceOnline => '设备上线';

  @override
  String get deviceOffline => '设备离线';

  @override
  String get remoteOperationSuccess => '远程调用成功';

  @override
  String get remoteOperationFailed => '远程调用失败';

  @override
  String get remoteOpenDoor => '远程开启柜门';

  @override
  String get remoteOpenAlarm => '远程开启报警';

  @override
  String get appVersion => '版本';

  @override
  String get searchDevice => '搜索设备';

  @override
  String get searchDeviceHint => '输入设备ID或名称';

  @override
  String get search => '搜索';

  @override
  String get registrationNumber => '备案号';

  @override
  String get officialWebsite => '官网';

  @override
  String get noMoreData => '没有更多数据';
}
