# MCP Server Integration for AhamAI Flutter App

This document describes the Model Context Protocol (MCP) server integration added to your Flutter Android app.

## Overview

The app now supports MCP servers, allowing users to connect to various external services and tools. The integration includes:

- **Prebuilt MCP Servers**: Ready-to-use servers for common services
- **Custom MCP Servers**: User-created servers with custom configurations
- **Minimalistic UI**: Clean, modern interface using white, grey, and black colors
- **Input Bar Integration**: MCP server icon in chat input bars

## Features

### Prebuilt MCP Servers

1. **Wikipedia** 📚
   - Search and retrieve content from Wikipedia
   - Test with queries like "Flutter", "Artificial Intelligence"

2. **DuckDuckGo Search** 🔍
   - Web search using DuckDuckGo's instant answers
   - Test with queries like "weather today", "latest news"

3. **Calculator** 🧮
   - Perform mathematical calculations
   - Test with expressions like "2 + 3 * 4", "100 / 5"

4. **Weather** 🌤️
   - Get weather information for cities
   - Test with city names like "London", "New York", "Tokyo"

5. **File System** 📁
   - File operations (disabled for security in demo)

### Custom MCP Servers

Users can create custom MCP servers by providing:
- Server name and description
- Command to execute
- Arguments and environment variables
- Custom icon selection

## File Structure

```
lib/
├── mcp_models.dart          # MCP server data models
├── mcp_service.dart         # MCP server management service
├── mcp_page.dart           # Main MCP servers interface
├── mcp_server_form.dart    # Form for creating/editing servers
└── mcp_implementations.dart # Prebuilt server implementations
```

## Usage

### Accessing MCP Servers

1. Open any chat page (Character Chat or Main Chat)
2. Look for the MCP extension icon (🧩) in the input bar
3. Tap the icon to open the MCP Servers page

### Testing Prebuilt Servers

1. In the MCP Servers page, find a prebuilt server
2. Tap the blue test icon (▶️) next to the server
3. Enter a test query in the dialog
4. View the results in the result dialog

### Creating Custom Servers

1. In the MCP Servers page, tap "Add MCP Server"
2. Fill in the server details:
   - Name and description
   - Command to execute the server
   - Optional arguments and environment variables
   - Choose an icon
3. Tap "Save" to create the server

### Managing Servers

- **Connect/Disconnect**: Use the play/stop button
- **Edit**: Use the menu button for custom servers
- **Delete**: Use the menu button for custom servers
- **Test**: Use the test button for prebuilt servers

## Design Principles

### Minimalistic Aesthetic

- **Colors**: Primarily white, grey, and black
- **Typography**: Google Fonts Poppins for consistency
- **Layout**: Clean, spacious design with subtle borders
- **Icons**: Material Design icons in grey tones

### User Experience

- **Intuitive Navigation**: Clear visual hierarchy
- **Responsive Design**: Adapts to different screen sizes
- **Feedback**: Loading states and error handling
- **Accessibility**: Tooltips and clear labels

## Technical Implementation

### MCP Service

The `McpService` class manages:
- Server configuration storage
- Connection management
- Real-time status updates
- Test functionality

### Data Persistence

- Custom servers are saved to `SharedPreferences`
- Prebuilt servers are loaded automatically
- Connection states are managed in memory

### Network Integration

- HTTP requests for Wikipedia and DuckDuckGo APIs
- Error handling for network failures
- Timeout management for external calls

## Dependencies

```yaml
dependencies:
  dart_mcp: ^0.3.2           # MCP client/server library
  shared_preferences: ^2.2.2  # Local storage
  uuid: ^4.2.1               # Unique ID generation
  http: ^1.1.0               # HTTP requests
```

## Future Enhancements

1. **Chat Integration**: Use MCP servers directly in chat conversations
2. **Advanced Servers**: More complex prebuilt servers (GitHub, Slack, etc.)
3. **Server Marketplace**: Share and discover community servers
4. **Authentication**: Support for authenticated MCP servers
5. **Real-time Updates**: WebSocket-based servers
6. **Batch Operations**: Execute multiple server calls simultaneously

## Security Considerations

- Custom server commands are executed with user permissions
- Network requests are limited to HTTPS where possible
- File system access is restricted in demo mode
- Input validation for all user-provided data

## Testing

Each prebuilt server includes example test cases:
- Wikipedia: Search for "Flutter"
- DuckDuckGo: Search for "weather today"
- Calculator: Calculate "2 + 3 * 4"
- Weather: Get weather for "London"

## Support

For issues or feature requests related to MCP integration, refer to:
- [dart_mcp package documentation](https://pub.dev/packages/dart_mcp)
- [MCP specification](https://modelcontextprotocol.io/docs)