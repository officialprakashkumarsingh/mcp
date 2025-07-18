import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mcp_models.dart';

class McpServerFormDialog extends StatefulWidget {
  final McpServer? server;
  final Function(McpServer) onSave;

  const McpServerFormDialog({
    super.key,
    this.server,
    required this.onSave,
  });

  @override
  State<McpServerFormDialog> createState() => _McpServerFormDialogState();
}

class _McpServerFormDialogState extends State<McpServerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _commandController = TextEditingController();
  final _argsController = TextEditingController();
  final _envController = TextEditingController();
  
  String _selectedIcon = 'extension';
  
  final List<String> _availableIcons = [
    'extension',
    'settings',
    'code',
    'terminal',
    'api',
    'cloud',
    'storage',
    'search',
    'calculate',
    'folder',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.server != null) {
      _nameController.text = widget.server!.name;
      _descriptionController.text = widget.server!.description;
      _commandController.text = widget.server!.command ?? '';
      _argsController.text = widget.server!.args?.join(' ') ?? '';
      _envController.text = widget.server!.env?.entries
          .map((e) => '${e.key}=${e.value}')
          .join('\n') ?? '';
      _selectedIcon = widget.server!.iconName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _commandController.dispose();
    _argsController.dispose();
    _envController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'extension':
        return Icons.extension;
      case 'settings':
        return Icons.settings;
      case 'code':
        return Icons.code;
      case 'terminal':
        return Icons.terminal;
      case 'api':
        return Icons.api;
      case 'cloud':
        return Icons.cloud_outlined;
      case 'storage':
        return Icons.storage;
      case 'search':
        return Icons.search;
      case 'calculate':
        return Icons.calculate_outlined;
      case 'folder':
        return Icons.folder_outlined;
      default:
        return Icons.extension;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        maxWidth: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.server == null ? 'Create Server' : 'Edit Server',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
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
              const SizedBox(height: 20),
              
              // Name field
              _buildTextField(
                controller: _nameController,
                label: 'Server Name',
                hint: 'Enter server name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description field
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter server description',
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Command field
              _buildTextField(
                controller: _commandController,
                label: 'Command',
                hint: 'node server.js',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Command is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Arguments field
              _buildTextField(
                controller: _argsController,
                label: 'Arguments (optional)',
                hint: '--port 3000 --config config.json',
              ),
              const SizedBox(height: 16),
              
              // Environment variables field
              _buildTextField(
                controller: _envController,
                label: 'Environment Variables (optional)',
                hint: 'API_KEY=your_key\nDEBUG=true',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Icon selection
              Text(
                'Icon',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final iconName = _availableIcons[index];
                    final isSelected = iconName == _selectedIcon;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = iconName;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey.shade300,
                          ),
                        ),
                        child: Icon(
                          _getIconData(iconName),
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: _saveServer,
                        child: Text(
                          'Save',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _saveServer() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Parse arguments
    List<String>? args;
    if (_argsController.text.trim().isNotEmpty) {
      args = _argsController.text.trim().split(' ');
    }

    // Parse environment variables
    Map<String, dynamic>? env;
    if (_envController.text.trim().isNotEmpty) {
      env = {};
      for (final line in _envController.text.trim().split('\n')) {
        final parts = line.split('=');
        if (parts.length == 2) {
          env[parts[0].trim()] = parts[1].trim();
        }
      }
    }

    final server = McpServer(
      id: widget.server?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      type: 'custom',
      command: _commandController.text.trim(),
      args: args,
      env: env,
      iconName: _selectedIcon,
      createdAt: widget.server?.createdAt ?? DateTime.now(),
    );

    widget.onSave(server);
    Navigator.pop(context);
  }
}