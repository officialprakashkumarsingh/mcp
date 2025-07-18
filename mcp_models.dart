import 'dart:convert';

class McpServer {
  final String id;
  final String name;
  final String description;
  final String type; // 'prebuilt' or 'custom'
  final String? command;
  final List<String>? args;
  final Map<String, dynamic>? env;
  final bool isEnabled;
  final DateTime createdAt;
  final String iconName;

  McpServer({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.command,
    this.args,
    this.env,
    this.isEnabled = true,
    required this.createdAt,
    required this.iconName,
  });

  factory McpServer.fromJson(Map<String, dynamic> json) {
    return McpServer(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      command: json['command'],
      args: json['args']?.cast<String>(),
      env: json['env']?.cast<String, dynamic>(),
      isEnabled: json['isEnabled'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      iconName: json['iconName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'command': command,
      'args': args,
      'env': env,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'iconName': iconName,
    };
  }

  McpServer copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? command,
    List<String>? args,
    Map<String, dynamic>? env,
    bool? isEnabled,
    DateTime? createdAt,
    String? iconName,
  }) {
    return McpServer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      command: command ?? this.command,
      args: args ?? this.args,
      env: env ?? this.env,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      iconName: iconName ?? this.iconName,
    );
  }
}

class McpServerConnection {
  final String serverId;
  final String status; // 'connected', 'disconnected', 'error'
  final DateTime lastConnected;
  final String? errorMessage;

  McpServerConnection({
    required this.serverId,
    required this.status,
    required this.lastConnected,
    this.errorMessage,
  });

  factory McpServerConnection.fromJson(Map<String, dynamic> json) {
    return McpServerConnection(
      serverId: json['serverId'],
      status: json['status'],
      lastConnected: DateTime.parse(json['lastConnected']),
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverId': serverId,
      'status': status,
      'lastConnected': lastConnected.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }
}

// Prebuilt MCP servers
class PrebuiltMcpServers {
  static List<McpServer> get all => [
    wikipedia,
    duckduckgo,
    fileSystem,
    calculator,
    weather,
  ];

  static McpServer get wikipedia => McpServer(
    id: 'wikipedia',
    name: 'Wikipedia',
    description: 'Search and retrieve content from Wikipedia',
    type: 'prebuilt',
    iconName: 'wikipedia',
    createdAt: DateTime.now(),
  );

  static McpServer get duckduckgo => McpServer(
    id: 'duckduckgo',
    name: 'DuckDuckGo Search',
    description: 'Search the web using DuckDuckGo',
    type: 'prebuilt',
    iconName: 'search',
    createdAt: DateTime.now(),
  );

  static McpServer get fileSystem => McpServer(
    id: 'filesystem',
    name: 'File System',
    description: 'Read and write files on the local system',
    type: 'prebuilt',
    iconName: 'folder',
    createdAt: DateTime.now(),
  );

  static McpServer get calculator => McpServer(
    id: 'calculator',
    name: 'Calculator',
    description: 'Perform mathematical calculations',
    type: 'prebuilt',
    iconName: 'calculate',
    createdAt: DateTime.now(),
  );

  static McpServer get weather => McpServer(
    id: 'weather',
    name: 'Weather',
    description: 'Get current weather information',
    type: 'prebuilt',
    iconName: 'cloud',
    createdAt: DateTime.now(),
  );
}