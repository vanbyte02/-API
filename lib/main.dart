import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  runApp(const MyApp());
}

Future<Map<String, dynamic>> getExchangeRates() async {
  try {
    var response = await http.get(Uri.https("api.frankfurter.app", "latest"));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return jsonData['rates'];
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? exchangeRates;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> _fetchExchangeRates() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      var rates = await getExchangeRates();
      setState(() {
        exchangeRates = rates;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Курс центрального Европейского банка'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _fetchExchangeRates,
              child: const Text('Получить курс евро'),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (errorMessage.isNotEmpty) Text('Ошибка: $errorMessage'),
            if (exchangeRates != null) ...[
              const Text('Курсы евро к другим валютам:'),
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: exchangeRates!.length,
                  itemBuilder: (context, index) {
                    String currency = exchangeRates!.keys.elementAt(index);
                    double rate = (exchangeRates![currency] is int)
                        ? (exchangeRates![currency] as int).toDouble()
                        : (exchangeRates![currency] as double);
                    return ListTile(
                      title: Text('$currency: $rate'),
                    );
                  },
                ),
                )
                
              ),
            ],
          ],
        ),
      ),
    );
  }
}
