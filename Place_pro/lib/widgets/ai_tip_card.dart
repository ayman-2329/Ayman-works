// AI Tip Card Widget with auto-refresh functionality
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AITipCard extends StatefulWidget {
    const AITipCard({super.key});

  @override
  AITipCardState createState() => AITipCardState();
}

class AITipCardState extends State<AITipCard> {
  final _random = Random();
  String _currentTip = 'Loading your daily tip...';
  bool _isLoading = true;
  bool _isBackendAvailable = false;
  String _tipCategory = 'general';

  @override
  void initState() {
    super.initState();
    _loadDailyTip();
  }

  Future<void> _loadDailyTip() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if backend is available
      _isBackendAvailable = await AIService.isBackendAvailable();
      
      if (!mounted) return;
      _isBackendAvailable = await AIService.isBackendAvailable();
      
      if (_isBackendAvailable) {
        final response = await AIService.getDailyTip();
        if (!mounted) return;
        if (response['success'] == true) {
          setState(() {
            _currentTip = response['tip'] ?? 'Stay focused on your goals and maintain a positive mindset.';
            _isLoading = false;
          });
        } else {
          _loadFallbackTip();
        }
      } else {
        _loadFallbackTip();
      }
    } catch (e) {
      debugPrint('Error loading daily tip: $e');
      if (mounted) {
        _loadFallbackTip();
      }
    }
  }

  void _loadFallbackTip() {
    final fallbackTips = [
      'Tip of the Day: Maintain a healthy work-life balance by setting clear boundaries.',
      'Tip of the Day: Practice the Pomodoro Technique for better focus and productivity.',
      'Tip of the Day: Network actively by attending industry events and connecting with professionals.',
      'Tip of the Day: Keep learning new skills relevant to your field to stay competitive.',
      'Tip of the Day: Prepare thoroughly for interviews by researching the company and practicing questions.',
    ];
    
    setState(() {
      _currentTip = fallbackTips[DateTime.now().day % fallbackTips.length];
      _isLoading = false;
    });
  }

  Future<void> _refreshTip() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isBackendAvailable) {
        // Get a random tip with different category each time
        final categories = ['productivity', 'career', 'wellness', 'learning'];
        _tipCategory = categories[_random.nextInt(categories.length)];
        
        final response = await AIService.getRandomTip(category: _tipCategory);
        if (!mounted) return;
        if (response['success'] == true) {
          setState(() {
            _currentTip = response['tip'] ?? 'Keep growing and learning every day.';
            _isLoading = false;
          });
        } else {
          _loadFallbackTip();
        }
      } else {
        _loadFallbackTip();
      }
    } catch (e) {
      debugPrint('Error refreshing tip: $e');
      if (mounted) {
        _loadFallbackTip();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Colors.amber.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isBackendAvailable ? 'AI-Powered Tip' : 'Daily Tip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  if (!_isLoading)
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _refreshTip,
                      tooltip: 'Get new tip',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading your personalized tip...'),
                  ],
                )
              else
                Text(
                  _currentTip,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              if (_isBackendAvailable && !_isLoading) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _tipCategory.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
