import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_mcp/client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'mcp_models.dart';
import 'mcp_implementations.dart';

class McpService {
  static final McpService _instance = McpService._internal();
  factory McpService() => _instance;
  McpService._internal();

  final List<McpServer> _servers = [];
  final Map<String, MCPClient> _connections = {};
  final Map<String, McpServerConnection> _connectionStatus = {};
  final StreamController<List<McpServer>> _serversController = StreamController.broadcast();
  final StreamController<Map<String, McpServerConnection>> _connectionsController = StreamController.broadcast();

  Stream<List<McpServer>> get serversStream => _serversController.stream;
  Stream<Map<String, McpServerConnection>> get connectionsStream => _connectionsController.stream;

  List<McpServer> get servers => List.unmodifiable(_servers);
  Map<String, McpServerConnection> get connections => Map.unmodifiable(_connectionStatus);

  Future<void> initialize() async {
    await _loadServers();
    await _loadPrebuiltServers();
    _serversController.add(_servers);
  }

  Future<void> _loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    final serversJson = prefs.getStringList('mcp_servers') ?? [];
    
    _servers.clear();
    for (final serverJson in serversJson) {
      try {
        final server = McpServer.fromJson(json.decode(serverJson));
        _servers.add(server);
      } catch (e) {
        print('Error loading server: $e');
      }
    }
  }

  Future<void> _loadPrebuiltServers() async {
    // Add prebuilt servers if they don't exist
    for (final prebuiltServer in PrebuiltMcpServers.all) {
      if (!_servers.any((s) => s.id == prebuiltServer.id)) {
        _servers.add(prebuiltServer);
      }
    }
  }

  Future<void> _saveServers() async {
    final prefs = await SharedPreferences.getInstance();
    final customServers = _servers.where((s) => s.type == 'custom').toList();
    final serversJson = customServers.map((s) => json.encode(s.toJson())).toList();
    await prefs.setStringList('mcp_servers', serversJson);
  }

  Future<String> addCustomServer({
    required String name,
    required String description,
    required String command,
    List<String>? args,
    Map<String, dynamic>? env,
    String iconName = 'extension',
  }) async {
    final server = McpServer(
      id: const Uuid().v4(),
      name: name,
      description: description,
      type: 'custom',
      command: command,
      args: args,
      env: env,
      iconName: iconName,
      createdAt: DateTime.now(),
    );

    _servers.add(server);
    await _saveServers();
    _serversController.add(_servers);
    return server.id;
  }

  Future<void> updateServer(String serverId, McpServer updatedServer) async {
    final index = _servers.indexWhere((s) => s.id == serverId);
    if (index != -1) {
      _servers[index] = updatedServer;
      if (updatedServer.type == 'custom') {
        await _saveServers();
      }
      _serversController.add(_servers);
    }
  }

  Future<void> deleteServer(String serverId) async {
    await disconnectServer(serverId);
    _servers.removeWhere((s) => s.id == serverId);
    await _saveServers();
    _serversController.add(_servers);
  }

  Future<bool> connectServer(String serverId) async {
    final server = _servers.firstWhere((s) => s.id == serverId);
    
    try {
      MCPClient? client;
      
      if (server.type == 'prebuilt') {
        client = await _connectPrebuiltServer(server);
      } else {
        client = await _connectCustomServer(server);
      }

      if (client != null) {
        _connections[serverId] = client;
        _connectionStatus[serverId] = McpServerConnection(
          serverId: serverId,
          status: 'connected',
          lastConnected: DateTime.now(),
        );
        _connectionsController.add(_connectionStatus);
        return true;
      }
    } catch (e) {
      _connectionStatus[serverId] = McpServerConnection(
        serverId: serverId,
        status: 'error',
        lastConnected: DateTime.now(),
        errorMessage: e.toString(),
      );
      _connectionsController.add(_connectionStatus);
    }
    
    return false;
  }

  Future<MCPClient?> _connectPrebuiltServer(McpServer server) async {
    // Implement prebuilt server connections based on server.id
    switch (server.id) {
      case 'wikipedia':
        return await _createWikipediaClient();
      case 'duckduckgo':
        return await _createDuckDuckGoClient();
      case 'filesystem':
        return await _createFileSystemClient();
      case 'calculator':
        return await _createCalculatorClient();
      case 'weather':
        return await _createWeatherClient();
      default:
        throw Exception('Unknown prebuilt server: ${server.id}');
    }
  }

  Future<MCPClient?> _connectCustomServer(McpServer server) async {
    if (server.command == null) {
      throw Exception('Custom server command is required');
    }

    try {
      final client = MCPClient();
      // Connect to stdio server
      final connection = await client.connectStdioServer(
        command: server.command!,
        args: server.args ?? [],
        env: server.env,
      );
      
      await connection.initialize();
      await connection.notifyInitialized();
      
      return client;
    } catch (e) {
      throw Exception('Failed to connect to custom server: $e');
    }
  }

  Future<void> disconnectServer(String serverId) async {
    final client = _connections[serverId];
    if (client != null) {
      // Close the connection
      _connections.remove(serverId);
    }
    
    _connectionStatus[serverId] = McpServerConnection(
      serverId: serverId,
      status: 'disconnected',
      lastConnected: DateTime.now(),
    );
    _connectionsController.add(_connectionStatus);
  }

  bool isServerConnected(String serverId) {
    final status = _connectionStatus[serverId];
    return status?.status == 'connected';
  }

  MCPClient? getServerClient(String serverId) {
    return _connections[serverId];
  }

  // Prebuilt server implementations
  Future<MCPClient> _createWikipediaClient() async {
    // This would be a simplified Wikipedia MCP client
    // In a real implementation, you'd create a proper MCP server for Wikipedia
    final client = MCPClient();
    // Implementation details would go here
    return client;
  }

  Future<MCPClient> _createDuckDuckGoClient() async {
    final client = MCPClient();
    // Implementation details would go here
    return client;
  }

  Future<MCPClient> _createFileSystemClient() async {
    final client = MCPClient();
    // Implementation details would go here
    return client;
  }

  Future<MCPClient> _createCalculatorClient() async {
    final client = MCPClient();
    // Implementation details would go here
    return client;
  }

  Future<MCPClient> _createWeatherClient() async {
    final client = MCPClient();
    // Implementation details would go here
    return client;
  }

  // Test method to demonstrate MCP server functionality
  Future<String> testServerFunction(String serverId, String input) async {
    final server = _servers.firstWhere((s) => s.id == serverId);
    
    try {
      switch (serverId) {
        case 'wikipedia':
          final result = await WikipediaSearchService.search(input);
          if (result['success']) {
            return '**${result['title']}**\n\n${result['extract']}\n\n[Read more](${result['url']})';
          } else {
            return 'Wikipedia search failed: ${result['error']}';
          }
          
        case 'duckduckgo':
          final result = await DuckDuckGoSearchService.search(input);
          if (result['success']) {
            return '**Search Result:**\n\n${result['result']}\n\nSource: ${result['source']}';
          } else {
            return 'Search failed: ${result['error']}';
          }
          
        case 'calculator':
          final result = CalculatorService.calculate(input);
          if (result['success']) {
            return '**${result['expression']} = ${result['result']}**';
          } else {
            return 'Calculation failed: ${result['error']}';
          }
          
        case 'weather':
          final result = await WeatherService.getWeather(input);
          if (result['success']) {
            return '**Weather in ${result['location']}:**\n\n'
                   '🌡️ Temperature: ${result['temperature']}°C\n'
                   '☁️ Condition: ${result['condition']}\n'
                   '💧 Humidity: ${result['humidity']}%\n\n'
                   '${result['note']}';
          } else {
            return 'Weather lookup failed: ${result['error']}';
          }
          
        case 'filesystem':
          return 'File system operations are not available in this demo for security reasons.';
          
        default:
          return 'Unknown server or functionality not implemented yet.';
      }
    } catch (e) {
      return 'Error calling ${server.name}: $e';
    }
  }

  void dispose() {
    _serversController.close();
    _connectionsController.close();
    // Close all connections
    for (final client in _connections.values) {
      // client.disconnect(); // Would implement proper disconnect
    }
    _connections.clear();
  }
}