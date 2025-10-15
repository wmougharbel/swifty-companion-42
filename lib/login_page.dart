import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {

  Future<String?> loginWith42() async {
    await dotenv.load(fileName: '.env');
    final app_id = dotenv.env['APP_ID'];
    final app_secret = dotenv.env['APP_SECRET'];
    final redirect_uri = 'com.example.flutterapplication://oauth/callback';
    final authUrl = 'https://api.intra.42.fr/oauth/authorize'
                    '?client_id=$app_id'
                    '&redirect_uri=${Uri.encodeComponent(redirect_uri)}'
                    '&response_type=code';
    final result = await FlutterWebAuth2.authenticate(url: authUrl, callbackUrlScheme: 'com.example.flutterapplication');
    final code = Uri.parse(result).queryParameters['code'];
    if (code == null)
      return null;

    final token = await http.post(
      Uri.parse('https://api.intra.42.fr/oauth/token'),
      body: jsonEncode({
        'grant_type': 'authorization_code',
        'client_id': app_id,
        'client_secret': app_secret,
        'code': code,
        'redirect_uri': redirect_uri,
      })
    );

    if (token.statusCode != 200) {
      print("Failed to exchange token. Error code ${token.statusCode}");
      print(token.body);
      return null;
    }
    else {
      final data = jsonDecode(token.body) as Map<String, dynamic>;
      print("Token: ${data['access_token']}");
      return data['access_token'] as String?;
    }
  }

  Future<String?> _getAccessToken() async {
    await dotenv.load(fileName: ".env");
    final app_id = dotenv.env['APP_ID'];
    final app_secret = dotenv.env['APP_SECRET'];
    final url = Uri.parse('https://api.intra.42.fr/oauth/authorize');
    final response = await http.post(
        url,
        body: {
          'grant_type': 'client_credentials',
          'client_id': app_id,
          'client_secret': app_secret,
          'scope': 'public',
        }
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final access_token = data['access_token'];
      return (access_token);
    }
    else {
      print('Failed to get token ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  Future<String?> _getDataFromAPI() async {
    String? access_token = await _getAccessToken();
    print(access_token);
    final url = Uri.parse('https://api.intra.42.fr/v2/me');
    final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $access_token'}
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final name = data['usual_full_name'];
      print("Name: $name");
      return name;
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  void _login() {
    print("Button clicked.");
    _getDataFromAPI();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      'assets/images/background-image.png'
                  ),
                fit: BoxFit.cover,
              ),

            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Card(
                color: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF074d5e),
                            ),
                            onPressed: () {
                              loginWith42();
                            },
                            child: Text (
                              'Login',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                            ),
                          )
                        ],
                      ),
                  ),

                ),
              ),
            ),
          )
        ],
      )
    );
  }
}
