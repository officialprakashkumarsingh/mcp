import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mcp_models.dart';
import 'mcp_service.dart';
import 'mcp_server_form.dart';

class McpPage extends StatefulWidget {
  const McpPage({super.key});

  @override
  State<McpPage> createState() => _McpPageState();
}

class _McpPageState extends State<McpPage> {
  final McpService _mcpService = McpService();
  List<McpServer> _servers = [];
  Map<String, McpServerConnection> _connections = {};
  StreamSubscription? _serversSubscription;
  StreamSubscription? _connectionsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeMcp();
  }

  void _initializeMcp() async {
    await _mcpService.initialize();
    
    _serversSubscription = _mcpService.serversStream.listen((servers) {
      setState(() {
        _servers = servers;
      });
    });
    
    _connectionsSubscription = _mcpService.connectionsStream.listen((connections) {
      setState(() {
        _connections = connections;
      });
    });
    
    // Load initial data
    setState(() {
      _servers = _mcpService.servers;
      _connections = _mcpService.connections;
    });
  }

  @override
  void dispose() {
    _serversSubscription?.cancel();
    _connectionsSubscription?.cancel();
    super.dispose();
  }

  IconData _getServerIcon(String iconName) {
    switch (iconName) {
      case 'wikipedia':
        return Icons.menu_book;
      case 'search':
        return Icons.search;
      case 'folder':
        return Icons.folder_outlined;
      case 'calculate':
        return Icons.calculate_outlined;
      case 'cloud':
        return Icons.cloud_outlined;
      case 'extension':
        return Icons.extension;
      default:
        return Icons.settings;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'connected':
        return Colors.green;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'MCP Servers',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _showCreateServerDialog,
          ),
        ],
      ),
      body: _servers.isEmpty
          ? _buildEmptyState()
          : _buildServersList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.extension_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No MCP Servers',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add prebuilt servers or create custom ones',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildServersList() {
    final prebuiltServers = _servers.where((s) => s.type == 'prebuilt').toList();
    final customServers = _servers.where((s) => s.type == 'custom').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (prebuiltServers.isNotEmpty) ...[
          _buildSectionHeader('Prebuilt Servers'),
          const SizedBox(height: 12),
          ...prebuiltServers.map((server) => _buildServerCard(server)),
          const SizedBox(height: 24),
        ],
        if (customServers.isNotEmpty) ...[
          _buildSectionHeader('Custom Servers'),
          const SizedBox(height: 12),
          ...customServers.map((server) => _buildServerCard(server)),
          const SizedBox(height: 24),
        ],
        _buildAddButton(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildServerCard(McpServer server) {
    final connection = _connections[server.id];
    final isConnected = connection?.status == 'connected';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getServerIcon(server.iconName),
            color: Colors.grey.shade600,
            size: 24,
          ),
        ),
        title: Text(
          server.name,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              server.description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(connection?.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  connection?.status ?? 'disconnected',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
                         IconButton(
               icon: Icon(
                 isConnected ? Icons.stop : Icons.play_arrow,
                 color: isConnected ? Colors.red : Colors.green,
                 size: 20,
               ),
               onPressed: () => _toggleConnection(server.id),
             ),
             if (server.type == 'prebuilt')
               IconButton(
                 icon: Icon(Icons.play_circle_outline, color: Colors.blue, size: 20),
                 onPressed: () => _testServer(server),
                 tooltip: 'Test Server',
               ),
            if (server.type == 'custom')
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600, size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditServerDialog(server);
                  } else if (value == 'delete') {
                    _deleteServer(server.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: _showCreateServerDialog,
        child: Text(
          'Add MCP Server',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showCreateServerDialog() {
    showDialog(
      context: context,
      builder: (context) => McpServerFormDialog(
        onSave: (server) async {
          await _mcpService.addCustomServer(
            name: server.name,
            description: server.description,
            command: server.command!,
            args: server.args,
            env: server.env,
            iconName: server.iconName,
          );
        },
      ),
    );
  }

  void _showEditServerDialog(McpServer server) {
    showDialog(
      context: context,
      builder: (context) => McpServerFormDialog(
        server: server,
        onSave: (updatedServer) async {
          await _mcpService.updateServer(server.id, updatedServer);
        },
      ),
    );
  }

  void _toggleConnection(String serverId) async {
    final isConnected = _mcpService.isServerConnected(serverId);
    
    if (isConnected) {
      await _mcpService.disconnectServer(serverId);
    } else {
      await _mcpService.connectServer(serverId);
    }
  }

  void _testServer(McpServer server) async {
    String testInput = '';
    
    // Get appropriate test input based on server type
    switch (server.id) {
      case 'wikipedia':
        testInput = 'Flutter';
        break;
      case 'duckduckgo':
        testInput = 'weather today';
        break;
      case 'calculator':
        testInput = '2 + 3 * 4';
        break;
      case 'weather':
        testInput = 'London';
        break;
      default:
        testInput = 'test';
    }

    // Show input dialog
    final input = await showDialog<String>(
      context: context,
      builder: (context) => _TestServerDialog(
        server: server,
        defaultInput: testInput,
      ),
    );

    if (input != null && input.isNotEmpty) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );

      try {
        final result = await _mcpService.testServerFunction(server.id, input);
        Navigator.pop(context); // Close loading dialog
        
        // Show result dialog
        showDialog(
          context: context,
          builder: (context) => _ServerResultDialog(
            server: server,
            input: input,
            result: result,
          ),
        );
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _deleteServer(String serverId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Delete Server',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this server?',
          style: GoogleFonts.poppins(color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _mcpService.deleteServer(serverId);
    }
  }
}

class _TestServerDialog extends StatefulWidget {
  final McpServer server;
  final String defaultInput;

  const _TestServerDialog({
    required this.server,
    required this.defaultInput,
  });

  @override
  State<_TestServerDialog> createState() => _TestServerDialogState();
}

class _TestServerDialogState extends State<_TestServerDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultInput);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Test ${widget.server.name}',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getInputHint(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.defaultInput,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: Colors.grey.shade600),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(
            'Test',
            style: GoogleFonts.poppins(color: Colors.black),
          ),
        ),
      ],
    );
  }

  String _getInputHint() {
    switch (widget.server.id) {
      case 'wikipedia':
        return 'Enter a topic to search on Wikipedia';
      case 'duckduckgo':
        return 'Enter a search query';
      case 'calculator':
        return 'Enter a math expression (e.g., 2 + 3 * 4)';
      case 'weather':
        return 'Enter a city name';
      default:
        return 'Enter test input';
    }
  }
}

class _ServerResultDialog extends StatelessWidget {
  final McpServer server;
  final String input;
  final String result;

  const _ServerResultDialog({
    required this.server,
    required this.input,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        maxWidth: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${server.name} Result',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    'Input: ',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      input,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Result:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                result,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}