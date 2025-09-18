class LoginResponse {
  final String message;
  final LoginResult result;
  final int status;
  final int timestamp;

  LoginResponse({
    required this.message,
    required this.result,
    required this.status,
    required this.timestamp,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      result: LoginResult.fromJson(json['result'] ?? {}),
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? 0,
    );
  }
}

class LoginResult {
  final int expires;
  final List<Permission> permissions;
  final List<Role> roles;
  final User user;
  final List<String> currentAuthority;
  final String token;

  LoginResult({
    required this.expires,
    required this.permissions,
    required this.roles,
    required this.user,
    required this.currentAuthority,
    required this.token,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      expires: json['expires'] ?? 0,
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((p) => Permission.fromJson(p))
          .toList() ?? [],
      roles: (json['roles'] as List<dynamic>?)
          ?.map((r) => Role.fromJson(r))
          .toList() ?? [],
      user: User.fromJson(json['user'] ?? {}),
      currentAuthority: (json['currentAuthority'] as List<dynamic>?)
          ?.map((a) => a.toString())
          .toList() ?? [],
      token: json['token'] ?? '',
    );
  }
}

class Permission {
  final String id;
  final String name;
  final List<String> actions;
  final List<dynamic> dataAccesses;

  Permission({
    required this.id,
    required this.name,
    required this.actions,
    required this.dataAccesses,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      actions: (json['actions'] as List<dynamic>?)
          ?.map((a) => a.toString())
          .toList() ?? [],
      dataAccesses: json['dataAccesses'] ?? [],
    );
  }
}

class Role {
  final String id;
  final String name;
  final String type;
  final String? username;
  final String? userType;
  final Map<String, dynamic>? options;

  Role({
    required this.id,
    required this.name,
    required this.type,
    this.username,
    this.userType,
    this.options,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      username: json['username'],
      userType: json['userType'],
      options: json['options'],
    );
  }
}

class User {
  final String id;
  final String username;
  final UserType type;
  final int status;
  final String name;
  final String telephone;
  final int createTime;
  final List<UserRole> roleList;
  final List<Organization> orgList;
  final String creatorId;
  final String creatorName;
  final String modifierId;
  final String modifierName;
  final int modifyTime;
  final Gender gender;
  final Register register;
  String orgId;
  String orgName;

  User({
    required this.id,
    required this.username,
    required this.type,
    required this.status,
    required this.name,
    required this.telephone,
    required this.createTime,
    required this.roleList,
    required this.orgList,
    required this.creatorId,
    required this.creatorName,
    required this.modifierId,
    required this.modifierName,
    required this.modifyTime,
    required this.gender,
    required this.register,
    this.orgId = '',
    this.orgName = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final orgList = (json['orgList'] as List<dynamic>?)
          ?.map((o) => Organization.fromJson(o))
          .toList() ?? [];
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      type: UserType.fromJson(json['type'] ?? {}),
      status: json['status'] ?? 0,
      name: json['name'] ?? '',
      telephone: json['telephone'] ?? '',
      createTime: json['createTime'] ?? 0,
      roleList: (json['roleList'] as List<dynamic>?)
          ?.map((r) => UserRole.fromJson(r))
          .toList() ?? [],
      orgList: orgList,
      creatorId: json['creatorId'] ?? '',
      creatorName: json['creatorName'] ?? '',
      modifierId: json['modifierId'] ?? '',
      modifierName: json['modifierName'] ?? '',
      modifyTime: json['modifyTime'] ?? 0,
      gender: Gender.fromJson(json['gender'] ?? {}),
      register: Register.fromJson(json['register'] ?? {}),
      orgId: orgList.first.id,
      orgName: orgList.first.fullName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'type': type.toJson(),
      'status': status,
      'name': name,
      'telephone': telephone,
      'createTime': createTime,
      'roleList': roleList.map((r) => r.toJson()).toList(),
      'orgList': orgList.map((o) => o.toJson()).toList(),
      'creatorId': creatorId,
      'creatorName': creatorName,
      'modifierId': modifierId,
      'modifierName': modifierName,
      'modifyTime': modifyTime,
      'gender': gender.toJson(),
      'register': register.toJson(),
    };
  }
}

class UserType {
  final String name;
  final String id;

  UserType({
    required this.name,
    required this.id,
  });

  factory UserType.fromJson(Map<String, dynamic> json) {
    return UserType(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}

class UserRole {
  final String id;
  final String name;

  UserRole({
    required this.id,
    required this.name,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Organization {
  final String id;
  final String name;
  final int sortIndex;
  final String fullName;

  Organization({
    required this.id,
    required this.name,
    required this.sortIndex,
    required this.fullName,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sortIndex: json['sortIndex'] ?? 0,
      fullName: json['fullName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sortIndex': sortIndex,
      'fullName': fullName,
    };
  }
}

class Gender {
  final String text;
  final String value;

  Gender({
    required this.text,
    required this.value,
  });

  factory Gender.fromJson(Map<String, dynamic> json) {
    return Gender(
      text: json['text'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'value': value,
    };
  }
}

class Register {
  final String text;
  final String value;

  Register({
    required this.text,
    required this.value,
  });

  factory Register.fromJson(Map<String, dynamic> json) {
    return Register(
      text: json['text'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'value': value,
    };
  }
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class LogoutResponse {
  final String message;
  final bool result;
  final int status;
  final int timestamp;

  LogoutResponse({
    required this.message,
    required this.result,
    required this.status,
    required this.timestamp,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      message: json['message'] ?? '',
      result: json['result'] ?? false,
      status: json['status'] ?? 0,
      timestamp: json['timestamp'] ?? 0,
    );
  }
}