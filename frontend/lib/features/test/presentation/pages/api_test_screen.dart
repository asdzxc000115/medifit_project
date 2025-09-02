// lib/features/test/presentation/pages/api_test_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../services/api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final List<Map<String, dynamic>> _testResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runAllTests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API 연결 테스트'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _runAllTests,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _testResults.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader();
          }
          return _buildTestResultCard(_testResults[index - 1]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _runAllTests,
        backgroundColor: const Color(0xFF4A90E2),
        child: const Icon(Icons.play_arrow, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'API 연결 상태 확인',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A90E2),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '백엔드 서버와의 연결 상태를 테스트합니다.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('백엔드 URL', 'http://localhost:8080'),
          _buildInfoRow('API 버전', 'v1'),
          _buildInfoRow('인증 방식', 'JWT Token'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResultCard(Map<String, dynamic> result) {
    final bool isSuccess = result['success'] ?? false;
    final String testName = result['testName'] ?? '';
    final String message = result['message'] ?? '';
    final String endpoint = result['endpoint'] ?? '';
    final int duration = result['duration'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    testName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${duration}ms',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (endpoint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  endpoint,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isSuccess ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    final apiService = getService<ApiService>();

    // 테스트 목록
    final tests = [
      {
        'name': '기본 연결 테스트',
        'endpoint': '/api/test/hello',
        'test': () => apiService.testConnection(),
      },
      {
        'name': '서버 상태 확인',
        'endpoint': '/api/test/health',
        'test': () => apiService.checkHealth(),
      },
      {
        'name': 'Echo 테스트',
        'endpoint': '/api/test/echo',
        'test': () => apiService.echo('Flutter에서 보낸 메시지'),
      },
    ];

    for (var test in tests) {
      await _runSingleTest(test);
      // 각 테스트 간 잠깐 대기
      await Future.delayed(const Duration(milliseconds: 300));
    }

    setState(() {
      _isLoading = false;
    });

    // 결과 요약 스낵바
    final successCount = _testResults.where((r) => r['success'] == true).length;
    final totalCount = _testResults.length;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '테스트 완료: $successCount/$totalCount 성공',
        ),
        backgroundColor: successCount == totalCount
            ? Colors.green
            : Colors.orange,
      ),
    );
  }

  Future<void> _runSingleTest(Map<String, dynamic> testConfig) async {
    final String testName = testConfig['name'];
    final String endpoint = testConfig['endpoint'];
    final Function testFunction = testConfig['test'];

    final startTime = DateTime.now();

    try {
      final result = await testFunction();
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      setState(() {
        _testResults.add({
          'testName': testName,
          'endpoint': endpoint,
          'success': result['success'] ?? false,
          'message': result['message'] ?? result['data'] ?? '응답 데이터 없음',
          'duration': duration,
        });
      });
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      setState(() {
        _testResults.add({
          'testName': testName,
          'endpoint': endpoint,
          'success': false,
          'message': '테스트 실행 실패: $e',
          'duration': duration,
        });
      });
    }
  }
}