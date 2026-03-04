# Privacy Policy / 隐私政策

**App Name**: Device  
**Developer**: Jamanet（jama-net.com）  
**Bundle ID**: com.jamanet.app.device  
**Effective Date**: 2026-03-03  
**Last Updated**: 2026-03-03

---

## 中文版

### 引言

欢迎使用 **Device**（以下简称"本应用"）。本应用由 Jamanet 开发和运营，致力于为用户提供物联网（IoT）设备监控与管理服务。我们非常重视您的个人信息和隐私保护。本隐私政策旨在向您说明我们如何收集、使用、存储、共享和保护您的个人信息，以及您所享有的相关权利。

请您在使用本应用前，仔细阅读并充分理解本隐私政策。一旦您开始使用本应用，即表示您已阅读并同意本政策的全部内容。

### 一、我们收集的信息

在您使用本应用时，我们可能会收集以下信息：

#### 1. 您主动提供的信息
- **账户信息**：当您注册或登录时，我们会收集您的用户名和密码，用于身份验证和账户管理。
- **用户反馈**：当您使用反馈功能时，您提交的反馈内容。

#### 2. 自动收集的信息
- **设备信息**：应用版本号、设备型号、操作系统版本等基本设备信息（通过 package_info_plus 获取），用于应用兼容性和问题排查。
- **网络信息**：Wi-Fi 网络名称（SSID），仅用于辅助 IoT 设备配网连接。
- **蓝牙设备信息**：附近蓝牙低功耗（BLE）设备的扫描结果和连接数据，仅用于发现和连接您的 IoT 设备。
- **推送通知令牌**：Firebase Cloud Messaging（FCM）设备令牌，用于向您发送设备告警和通知消息。

#### 3. 设备权限说明
本应用将请求以下设备权限，并仅在获得您的授权后使用：

| 权限 | 用途 |
|------|------|
| **蓝牙** | 连接和管理附近的 IoT 设备 |
| **相机** | 扫描二维码以绑定设备 |
| **位置** | 读取 Wi-Fi 网络信息以辅助设备配网（系统要求） |
| **通知** | 接收设备告警和状态通知 |
| **后台运行** | 持续监控设备状态并在后台推送告警通知 |

### 二、我们如何使用您的信息

我们收集的信息将用于以下目的：

1. **账户管理**：验证您的身份，提供登录和密码管理服务。
2. **设备管理**：通过蓝牙连接、二维码扫描实现 IoT 设备的添加、配置和管理。
3. **监控与告警**：实时监控设备状态，通过推送通知及时向您发送设备告警信息。
4. **数据展示**：在仪表板中展示设备使用数据、告警日志和统计信息。
5. **服务优化**：分析应用使用情况，改进产品功能和用户体验。
6. **客户支持**：处理您的反馈和问题。

### 三、信息存储与安全

1. **本地存储**：认证令牌和 Wi-Fi 配置信息通过 SharedPreferences 安全存储在您的设备本地，不会上传至第三方。
2. **网络传输**：所有与服务器之间的通信均通过加密通道（HTTPS / WSS）进行。
3. **令牌管理**：认证令牌设有过期机制，过期后将自动失效并清除。
4. **数据安全**：我们采取合理的技术和管理措施来保护您的个人信息免遭未经授权的访问、泄露、篡改或丢失。

### 四、信息共享与披露

我们不会向第三方出售、出租或交易您的个人信息。我们仅在以下情况下可能共享您的信息：

1. **第三方服务**：本应用使用 Firebase Cloud Messaging 提供推送通知服务，相关数据将按照 Google Firebase 的隐私政策处理。
2. **法律要求**：在法律法规要求、政府机关依法要求或为保护我们及其他用户合法权益的情况下，我们可能会披露您的信息。
3. **经您同意**：在获得您明确同意的前提下，我们可能与第三方共享您的信息。

### 五、第三方 SDK 说明

本应用集成了以下第三方 SDK：

| SDK 名称 | 用途 | 隐私政策 |
|----------|------|----------|
| Firebase Core / Messaging | 推送通知 | [Google Privacy Policy](https://policies.google.com/privacy) |
| flutter_blue_plus | 蓝牙设备连接 | 仅本地使用，不传输数据至第三方 |
| mobile_scanner | 二维码扫描 | 仅本地使用，不传输数据至第三方 |
| network_info_plus | 读取 Wi-Fi 信息 | 仅本地使用，不传输数据至第三方 |
| package_info_plus | 获取应用版本信息 | 仅本地使用，不传输数据至第三方 |

### 六、您的权利

您享有以下权利：

1. **访问权**：您有权查看我们收集的与您相关的个人信息。
2. **更正权**：您有权更正不准确的个人信息（如修改密码）。
3. **删除权**：您可以通过注销账户请求删除您的个人信息。
4. **撤回同意**：您可以随时在系统设置中关闭相关权限（如蓝牙、相机、位置、通知），但这可能影响部分功能的正常使用。

### 七、未成年人保护

本应用主要面向企业用户，不专门面向 16 周岁以下的未成年人。如果我们发现在未获得家长或监护人同意的情况下收集了未成年人的个人信息，我们将采取措施尽快删除相关信息。

### 八、隐私政策更新

我们可能会适时修订本隐私政策。政策更新后，我们将在应用内通知您。重大变更将通过弹窗等方式提醒您重新阅读。

### 九、联系我们

如果您对本隐私政策有任何疑问、意见或建议，请通过以下方式与我们联系：

- **官方网站**：[https://www.jama-net.com/](https://www.jama-net.com/)
- **应用内反馈**：通过"我的 > 意见反馈"提交

---

## English Version

### Introduction

Welcome to **Device** (hereinafter referred to as "the App"). The App is developed and operated by Jamanet, dedicated to providing IoT device monitoring and management services. We take your personal information and privacy protection seriously. This Privacy Policy explains how we collect, use, store, share, and protect your personal information, and your related rights.

Please read and fully understand this Privacy Policy before using the App. By using the App, you acknowledge that you have read and agreed to all terms of this Policy.

### 1. Information We Collect

When you use the App, we may collect the following information:

#### 1.1 Information You Provide
- **Account Information**: When you register or log in, we collect your username and password for authentication and account management.
- **User Feedback**: Content you submit through the feedback feature.

#### 1.2 Automatically Collected Information
- **Device Information**: App version, device model, operating system version and other basic device information (obtained via package_info_plus) for app compatibility and troubleshooting.
- **Network Information**: Wi-Fi network name (SSID), used solely to assist IoT device network configuration.
- **Bluetooth Device Information**: BLE scan results and connection data from nearby Bluetooth Low Energy devices, used solely to discover and connect your IoT devices.
- **Push Notification Token**: Firebase Cloud Messaging (FCM) device token, used to send device alerts and notifications.

#### 1.3 Device Permissions

| Permission | Purpose |
|-----------|---------|
| **Bluetooth** | Connect and manage nearby IoT devices |
| **Camera** | Scan QR codes for device binding |
| **Location** | Read Wi-Fi network information for device configuration (required by the OS) |
| **Notifications** | Receive device alerts and status notifications |
| **Background Execution** | Continuously monitor device status and deliver alert notifications in the background |

### 2. How We Use Your Information

We use collected information for the following purposes:

1. **Account Management**: Verify your identity and provide login and password management services.
2. **Device Management**: Add, configure, and manage IoT devices via Bluetooth connection and QR code scanning.
3. **Monitoring & Alerts**: Monitor device status in real-time and send timely alert notifications via push notifications.
4. **Data Display**: Present device usage data, alert logs, and statistics on the dashboard.
5. **Service Improvement**: Analyze app usage to improve product features and user experience.
6. **Customer Support**: Process your feedback and inquiries.

### 3. Information Storage & Security

1. **Local Storage**: Authentication tokens and Wi-Fi configuration are securely stored locally on your device via SharedPreferences and are not uploaded to third parties.
2. **Network Transmission**: All communication with our servers is conducted through encrypted channels (HTTPS / WSS).
3. **Token Management**: Authentication tokens have an expiration mechanism and will automatically expire and be cleared.
4. **Data Security**: We implement reasonable technical and organizational measures to protect your personal information from unauthorized access, disclosure, alteration, or loss.

### 4. Information Sharing & Disclosure

We do not sell, rent, or trade your personal information to third parties. We may share your information only under the following circumstances:

1. **Third-Party Services**: The App uses Firebase Cloud Messaging for push notification services. Related data is processed in accordance with Google Firebase's Privacy Policy.
2. **Legal Requirements**: We may disclose your information when required by law, government authorities, or to protect our and other users' legal rights.
3. **With Your Consent**: We may share your information with third parties with your explicit consent.

### 5. Third-Party SDKs

The App integrates the following third-party SDKs:

| SDK Name | Purpose | Privacy Policy |
|----------|---------|---------------|
| Firebase Core / Messaging | Push Notifications | [Google Privacy Policy](https://policies.google.com/privacy) |
| flutter_blue_plus | Bluetooth Device Connection | Local use only, no data transmitted to third parties |
| mobile_scanner | QR Code Scanning | Local use only, no data transmitted to third parties |
| network_info_plus | Read Wi-Fi Information | Local use only, no data transmitted to third parties |
| package_info_plus | Retrieve App Version Info | Local use only, no data transmitted to third parties |

### 6. Your Rights

You have the following rights:

1. **Right of Access**: You may view the personal information we have collected about you.
2. **Right of Rectification**: You may correct inaccurate personal information (e.g., change your password).
3. **Right of Deletion**: You may request deletion of your personal information by deactivating your account.
4. **Right to Withdraw Consent**: You may disable relevant permissions (Bluetooth, Camera, Location, Notifications) in your system settings at any time, though this may affect certain features.

### 7. Children's Privacy

The App is primarily designed for business users and is not intended for children under the age of 16. If we discover that we have collected personal information from a minor without parental or guardian consent, we will take steps to delete such information as soon as possible.

### 8. Policy Updates

We may update this Privacy Policy from time to time. After updates, we will notify you within the App. Significant changes will be highlighted through pop-up notifications.

### 9. Contact Us

If you have any questions, comments, or suggestions regarding this Privacy Policy, please contact us through:

- **Official Website**: [https://www.jama-net.com/](https://www.jama-net.com/)
- **In-App Feedback**: Submit via "My > Feedback"
