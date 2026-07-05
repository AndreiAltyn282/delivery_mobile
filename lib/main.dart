import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(DeliveryApp());

class DeliveryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Умная доставка',
      theme: ThemeData(primarySwatch: Colors.green),
      home: RoleSelectionScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
    );
  }
}

// ============================================================
// 1. ЭКРАН ВЫБОРА РОЛИ
// ============================================================

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.green[900]!],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping, size: 80, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  '🚚 Умная доставка',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Быстрая и надёжная доставка',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ClientScreen()),
                      );
                    },
                    icon: Icon(Icons.person, size: 28),
                    label: Text('👤 Я клиент', style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CourierScreen()),
                      );
                    },
                    icon: Icon(Icons.delivery_dining, size: 28),
                    label: Text('🏃 Я курьер', style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Версия 1.0',
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 2. ЭКРАН КЛИЕНТА
// ============================================================

class ClientScreen extends StatefulWidget {
  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  int? _lastOrderId;

  // ⚠️ ВАЖНО: Замените IP на ваш!
  final String API_URL = 'http://172.24.212.178:8080';
  final String TRACKER_URL = 'http://172.24.212.178:8081';

  Future<void> _createOrder() async {
    if (_phoneController.text.isEmpty || _addressController.text.isEmpty) {
      setState(() => _message = '⚠️ Заполните все поля!');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$API_URL/api/orders/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'clientPhone': _phoneController.text,
          'clientAddress': _addressController.text,
          'shopId': 1,
          'shopAddress': 'ул. Ленина 10',
          'shopLat': 55.7558,
          'shopLng': 37.6173,
          'priceTotal': 350.0,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _lastOrderId = data['orderId'];
          _message = '✅ Заказ #${data['orderId']} создан!\nКурьер: ${data['courierName'] ?? 'назначается...'}';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Заказ #${data['orderId']} принят!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _message = '❌ Ошибка: ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = '❌ Ошибка соединения: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📦 Заказать доставку'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Введите телефон и адрес для заказа',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: '📱 Ваш телефон',
                hintText: 'Например: +79001234567',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: '📍 Адрес доставки',
                hintText: 'Например: ул. Пушкина 15',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('📦 Заказать доставку', style: TextStyle(fontSize: 18)),
              ),
            ),
            SizedBox(height: 20),
            if (_message.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _message.contains('✅') ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _message.contains('✅') ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('✅') ? Colors.green[800] : Colors.red[800],
                    fontSize: 14,
                  ),
                ),
              ),
            if (_lastOrderId != null)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackingScreen(orderId: _lastOrderId!),
                      ),
                    );
                  },
                  child: Text('📍 Проверить статус заказа #$_lastOrderId'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 3. ЭКРАН СТАТУСА ЗАКАЗА (ТРЕКИНГ) - ИСПРАВЛЕННЫЙ
// ============================================================

class TrackingScreen extends StatefulWidget {
  final int orderId;
  TrackingScreen({required this.orderId});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;

  final String API_URL = 'http://172.24.212.178:8080';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('$API_URL/api/orders/status/${widget.orderId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _orderData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // ИСПРАВЛЕННАЯ ФУНКЦИЯ ДЛЯ СТАТУСА
  // ============================================================
  String _getStatusBadge(String status) {
    switch (status) {
      case 'ASSIGNED':
        return '🟢 В пути';
      case 'PENDING':
        return '🟡 Ожидает курьера';
      case 'DELIVERED':
        return '✅ Доставлен';
      case 'CANCELLED':
        return '❌ Отменён';
      default:
        return '📦 ' + status;  // Показываем реальный статус из БД
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📋 Заказ #${widget.orderId}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ============================================================
                    // ИСПРАВЛЕННАЯ ИКОНКА СТАТУСА
                    // ============================================================
                    Icon(
                      _orderData?['status'] == 'ASSIGNED'
                          ? Icons.delivery_dining
                          : _orderData?['status'] == 'PENDING'
                              ? Icons.hourglass_top
                              : _orderData?['status'] == 'DELIVERED'
                                  ? Icons.check_circle
                                  : Icons.receipt_long,
                      size: 80,
                      color: _orderData?['status'] == 'ASSIGNED'
                          ? Colors.green
                          : _orderData?['status'] == 'PENDING'
                              ? Colors.orange
                              : _orderData?['status'] == 'DELIVERED'
                                  ? Colors.green
                                  : Colors.grey,
                    ),
                    SizedBox(height: 16),
                    // ============================================================
                    // ИСПРАВЛЕННОЕ ОТОБРАЖЕНИЕ СТАТУСА
                    // ============================================================
                    Text(
                      _getStatusBadge(_orderData?['status'] ?? 'UNKNOWN'),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Курьер: ${_orderData?['courier_name'] ?? 'Не назначен'}',
                      style: TextStyle(fontSize: 18),
                    ),
                    if (_orderData?['courier_phone'] != null)
                      Text(
                        '📞 ${_orderData?['courier_phone']}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _loadStatus,
                        icon: Icon(Icons.refresh),
                        label: Text('Обновить статус'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

// ============================================================
// 4. ЭКРАН КУРЬЕРА
// ============================================================

class CourierScreen extends StatefulWidget {
  @override
  _CourierScreenState createState() => _CourierScreenState();
}

class _CourierScreenState extends State<CourierScreen> {
  bool _isOnline = false;

  final String TRACKER_URL = 'http://172.24.212.178:8081';

  void _toggleOnline() async {
    if (!_isOnline) {
      try {
        await http.post(
          Uri.parse('$TRACKER_URL/location/1?lat=55.7558&lng=37.6173'),
        );
        setState(() => _isOnline = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Вы на линии!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка подключения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() => _isOnline = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔴 Вы офлайн'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('👨‍✈️ Курьер'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: _isOnline ? Colors.green[50] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isOnline ? Colors.green : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isOnline ? Icons.check_circle : Icons.cancel,
                      color: _isOnline ? Colors.green : Colors.red,
                      size: 72,
                    ),
                    SizedBox(height: 12),
                    Text(
                      _isOnline ? '🟢 На линии' : '🔴 Офлайн',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isOnline)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '📍 55.7558, 37.6173',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _toggleOnline,
                  icon: Icon(_isOnline ? Icons.power_settings_new : Icons.power_off),
                  label: Text(
                    _isOnline ? '🔴 Отключиться' : '🟢 Выйти на линию',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOnline ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '📋 Доступные заказы: 0',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'В реальном приложении здесь будет список заказов',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
