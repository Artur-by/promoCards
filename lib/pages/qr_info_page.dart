import 'package:flutter/material.dart';
import '../models/qr_data.dart';
import '../services/qr_service.dart';

class QRInfoPage extends StatefulWidget {
  final String cardId;

  const QRInfoPage({super.key, required this.cardId});

  @override
  State<QRInfoPage> createState() => _QRInfoPageState();
}

class _QRInfoPageState extends State<QRInfoPage> {
  final QRService _qrService = QRService();
  QRData? _qrData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isNotFound = false;

  @override
  void initState() {
    super.initState();
    _loadQRData();
  }

  Future<void> _loadQRData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isNotFound = false;
    });

    try {
      final data = await _qrService.getQRData(widget.cardId);
      setState(() {
        _qrData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        if (e is QRServiceException) {
          _errorMessage = e.message;
          _isNotFound = e.isNotFound;
        } else {
          _errorMessage = e.toString();
          _isNotFound = false;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация о промо-карте'),
        backgroundColor: Colors.lightBlue[400],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isNotFound ? Icons.search_off : Icons.error_outline,
                          size: 80,
                          color: _isNotFound ? Colors.orange[300] : Colors.red[300],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _isNotFound ? 'Карта не найдена' : 'Ошибка загрузки данных',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[700],
                                ),
                          ),
                        ),
                        if (_isNotFound) ...[
                          const SizedBox(height: 24),
                          Card(
                            color: Colors.orange[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange[700]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Проверьте правильность ID карты: ${widget.cardId}',
                                      style: TextStyle(color: Colors.orange[900]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        if (!_isNotFound)
                          ElevatedButton.icon(
                            onPressed: _loadQRData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Повторить'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : _qrData == null
                  ? const Center(
                      child: Text('Данные не найдены'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInfoCard(
                            'Клиент',
                            _qrData!.clientName,
                            Icons.business,
                            Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            'Продукт',
                            _qrData!.productName,
                            Icons.shopping_bag,
                            Colors.green,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            'Действительно до',
                            _formatDate(_qrData!.validUntil),
                            Icons.calendar_today,
                            Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          _buildStatusCard(_qrData!),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: label == 'Статус'
                    ? color
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: label == 'Статус' ? Colors.white : color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) return raw;

      final day = parsed.day.toString().padLeft(2, '0');
      final month = parsed.month.toString().padLeft(2, '0');
      final year = parsed.year.toString();

      return '$day-$month-$year';
    } catch (_) {
      return raw;
    }
  }

  Widget _buildStatusCard(QRData data) {
    final status = data.status;

    // Цвет фона под иконкой и самой иконки в зависимости от статуса
    Color iconBackgroundColor;
    Color iconColor;
    const IconData icon = Icons.credit_card;

    if (status == 'Валидна') {
      iconBackgroundColor = Colors.green[400]!;
      iconColor = Colors.white;
    } else if (status == 'Погашена') {
      iconBackgroundColor = Colors.orange[400]!;
      iconColor = Colors.white;
    } else if (status == 'Истекшая') {
      iconBackgroundColor = Colors.red[400]!;
      iconColor = Colors.white;
    } else {
      iconBackgroundColor = Colors.grey[400]!;
      iconColor = Colors.white;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статус',
                    style:
                        Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
