import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Simple Wikipedia search implementation
class WikipediaSearchService {
  static Future<Map<String, dynamic>> search(String query) async {
    try {
      final url = Uri.parse(
        'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(query)}'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'title': data['title'] ?? 'Unknown',
          'extract': data['extract'] ?? 'No description available',
          'url': data['content_urls']?['desktop']?['page'] ?? '',
        };
      } else {
        return {
          'success': false,
          'error': 'Wikipedia search failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}

// Simple DuckDuckGo instant answer implementation
class DuckDuckGoSearchService {
  static Future<Map<String, dynamic>> search(String query) async {
    try {
      final url = Uri.parse(
        'https://api.duckduckgo.com/?q=${Uri.encodeComponent(query)}&format=json&no_html=1&skip_disambig=1'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        String result = '';
        if (data['Abstract'] != null && data['Abstract'].isNotEmpty) {
          result = data['Abstract'];
        } else if (data['Definition'] != null && data['Definition'].isNotEmpty) {
          result = data['Definition'];
        } else if (data['RelatedTopics'] != null && data['RelatedTopics'].isNotEmpty) {
          result = data['RelatedTopics'][0]['Text'] ?? '';
        } else {
          result = 'No results found';
        }
        
        return {
          'success': true,
          'result': result,
          'source': data['AbstractSource'] ?? 'DuckDuckGo',
          'url': data['AbstractURL'] ?? '',
        };
      } else {
        return {
          'success': false,
          'error': 'DuckDuckGo search failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}

// Simple calculator implementation
class CalculatorService {
  static Map<String, dynamic> calculate(String expression) {
    try {
      // Simple calculator that can handle basic operations
      expression = expression.replaceAll(' ', '');
      
      // Very basic expression evaluator (for demo purposes)
      // In a real implementation, you'd use a proper math parser
      final result = _evaluateExpression(expression);
      
      return {
        'success': true,
        'expression': expression,
        'result': result,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Invalid expression: $e',
      };
    }
  }
  
  static double _evaluateExpression(String expression) {
    // Very basic calculator - handles simple +, -, *, / operations
    // This is a simplified implementation for demo purposes
    
    // Replace operators with spaces for splitting
    expression = expression.replaceAll('+', ' + ');
    expression = expression.replaceAll('-', ' - ');
    expression = expression.replaceAll('*', ' * ');
    expression = expression.replaceAll('/', ' / ');
    
    final parts = expression.split(' ').where((s) => s.isNotEmpty).toList();
    
    if (parts.length == 1) {
      return double.parse(parts[0]);
    }
    
    double result = double.parse(parts[0]);
    
    for (int i = 1; i < parts.length; i += 2) {
      if (i + 1 < parts.length) {
        final operator = parts[i];
        final operand = double.parse(parts[i + 1]);
        
        switch (operator) {
          case '+':
            result += operand;
            break;
          case '-':
            result -= operand;
            break;
          case '*':
            result *= operand;
            break;
          case '/':
            if (operand != 0) {
              result /= operand;
            } else {
              throw Exception('Division by zero');
            }
            break;
        }
      }
    }
    
    return result;
  }
}

// Simple weather service (mock implementation)
class WeatherService {
  static Future<Map<String, dynamic>> getWeather(String location) async {
    // This is a mock implementation since we don't have a weather API key
    // In a real implementation, you'd integrate with OpenWeatherMap or similar
    
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    
    final cities = {
      'london': {'temp': 15, 'condition': 'Cloudy', 'humidity': 65},
      'new york': {'temp': 22, 'condition': 'Sunny', 'humidity': 55},
      'tokyo': {'temp': 18, 'condition': 'Rainy', 'humidity': 80},
      'paris': {'temp': 17, 'condition': 'Partly Cloudy', 'humidity': 60},
      'sydney': {'temp': 25, 'condition': 'Sunny', 'humidity': 45},
    };
    
    final normalizedLocation = location.toLowerCase();
    final weatherData = cities[normalizedLocation];
    
    if (weatherData != null) {
      return {
        'success': true,
        'location': location,
        'temperature': weatherData['temp'],
        'condition': weatherData['condition'],
        'humidity': weatherData['humidity'],
        'note': 'This is mock weather data for demonstration',
      };
    } else {
      return {
        'success': false,
        'error': 'Weather data not available for $location. Try: London, New York, Tokyo, Paris, or Sydney',
      };
    }
  }
}