import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PracticeAppTimeCrunch extends StatefulWidget {
  const PracticeAppTimeCrunch({super.key});
  @override
  State<PracticeAppTimeCrunch> createState() => _PracticeAppTimeCrunchState();
}

class _PracticeAppTimeCrunchState extends State<PracticeAppTimeCrunch> {
  double result = 0.0;
  bool isLoading = false;  // Loading indicator state
  final TextEditingController textEditingController = TextEditingController();
  String selectedBaseCurrency = 'USD';
  String selectedTargetCurrency = 'EUR';
  final List<String> currencies = ['USD', 'EUR', 'BDT', 'INR', 'AUD'];

  Future<void> convertCurrency(String amount, String baseCurrency, String targetCurrency) async {
    if (amount.isEmpty || double.tryParse(amount) == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Invalid Input"),
            content: const Text("Please enter a valid number."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      isLoading = true;  // Start loading
    });

    var url = Uri.parse('https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_iD8TqeV6KS0kvvcsLxbppgnbnlMyZmY2vTD4Mp4O=$baseCurrency');
    var headers = {
      'apikey': 'fca_live_iD8TqeV6KS0kvvcsLxbppgnbnlMyZmY2vTD4Mp4O'
    };

    try {
      var response = await http.get(url, headers: headers);
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['data'] != null && data['data'][targetCurrency] != null) {
          double rate = data['data'][targetCurrency];
          double parsedAmount = double.parse(amount);
          setState(() {
            result = parsedAmount * rate;
            isLoading = false;  // Stop loading
          });
        } else {
          setState(() {
            isLoading = false;  // Stop loading
          });
          print('Currency rate not available');
        }
      } else {
        setState(() {
          isLoading = false;  // Stop loading
        });
        print('Failed to load currency data with status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;  // Stop loading
      });
      print('Error occurred: $e');
      if (e is SocketException) {
        print('SocketException: ${e.message}');
      } else if (e is HttpException) {
        print('HttpException: ${e.message}');
      } else {
        print('Unknown exception: $e');
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("An error occurred while fetching data. Please try again."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 253, 253, 253),
        elevation: 0,
        title: const Text("Currency Converter"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading ? const CircularProgressIndicator() : Text(
              "$selectedTargetCurrency ${result.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: TextField(
                controller: textEditingController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  hintStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.money),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            DropdownButton<String>(
              value: selectedBaseCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  selectedBaseCurrency = newValue!;
                });
              },
              items: currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('From $value'),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedTargetCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTargetCurrency = newValue!;
                });
              },
              items: currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('To $value'),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                convertCurrency(textEditingController.text, selectedBaseCurrency, selectedTargetCurrency);
              },
              child: const Text('Convert'),
            ),
          ],
        ),
      ),
    );
  }
}
