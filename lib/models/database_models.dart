class SettingsModel {
  final String language;

  SettingsModel({required this.language});

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(language: json['language'] ?? 'pl');
  }

  Map<String, dynamic> toJson() => {'language': language};

  SettingsModel copyWith({String? language}) {
    return SettingsModel(language: language ?? this.language);
  }
}

class UserModel {
  final String id;
  final String login;
  final String email;
  final String phone;
  final List<String> piecesList;
  final SettingsModel settings;

  UserModel({
    required this.id,
    required this.login,
    required this.email,
    required this.phone,
    required this.piecesList,
    required this.settings,
  });

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      login: json['login'],
      email: json['email'],
      phone: json['phone'],
      piecesList: List<String>.from(json['piece_list'] ?? []),
      settings: SettingsModel.fromJson(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'login': login,
    'email': email,
    'phone': phone,
    'piece_list': piecesList,
    'settings': settings.toJson(),
  };

  UserModel copyWith({
    String? login,
    String? email,
    String? phone,
    List<String>? piecesList,
    SettingsModel? settings,
  }) {
    return UserModel(
      id: id,
      login: login ?? this.login,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      piecesList: piecesList ?? this.piecesList,
      settings: settings ?? this.settings,
    );
  }
}

class PieceModel {
  final String id;
  final String name;
  final String xmlUrl;
  final String createdAt;

  PieceModel({
    required this.id,
    required this.name,
    required this.xmlUrl,
    required this.createdAt,
  });

  factory PieceModel.fromJson(String id, Map<String, dynamic> json) {
    return PieceModel(
      id: id,
      name: json['name'],
      xmlUrl: json['xml_url'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'xml_url': xmlUrl,
    'created_at': createdAt,
  };
}

class PieceFullModel {
  final PieceModel meta;
  final String? xmlContent;

  PieceFullModel({
    required this.meta,
    required this.xmlContent,
  });
}