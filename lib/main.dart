import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'pages/qr_info_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Promo Card Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const QRScannerHome(),
    );
  }
}

class QRScannerHome extends StatefulWidget {
  const QRScannerHome({super.key});

  @override
  State<QRScannerHome> createState() => _QRScannerHomeState();
}

class _QRScannerHomeState extends State<QRScannerHome> {
  final TextEditingController _cardIdController = TextEditingController();
  
  String? _getCardIdFromUrl() {
    final uri = Uri.parse(html.window.location.href);
    final queryParams = uri.queryParameters;
    
    // Проверяем параметр 'p' (ID карты)
    if (queryParams.containsKey('p')) {
      return queryParams['p'];
    }
    
    return null;
  }

  void _navigateToQRInfo(String cardId) {
    if (cardId.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QRInfoPage(cardId: cardId),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Проверяем URL при инициализации
    final cardIdFromUrl = _getCardIdFromUrl();
    if (cardIdFromUrl != null && cardIdFromUrl.isNotEmpty) {
      // Используем WidgetsBinding для навигации после первой отрисовки
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToQRInfo(cardIdFromUrl);
      });
    }
  }

  @override
  void dispose() {
    _cardIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Promo Card Scanner'),
        backgroundColor: Colors.lightBlue[400],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 120,
                color: Colors.lightBlue[200],
              ),
              const SizedBox(height: 32),
              Text(
                'Сканируйте QR-код',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Откройте ссылку из QR-кода промо-карты\nили введите ID карты вручную',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ID карты',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _cardIdController,
                        decoration: InputDecoration(
                          hintText: 'Введите ID карты (например: 999999999999)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.credit_card),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.go,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _navigateToQRInfo(value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_cardIdController.text.isNotEmpty) {
                            _navigateToQRInfo(_cardIdController.text);
                          }
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Показать информацию'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
