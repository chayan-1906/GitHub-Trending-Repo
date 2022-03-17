import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:http/http.dart' as http;

import 'screens/network_error_screen.dart';

class Apis {
  String baseUrl = 'https://gh-trending-api.herokuapp.com';

  Future<http.Response> trendingRepoApi({BuildContext context}) async {
    print('trendingRepo Api called');
    http.Response response;
    try {
      var request = http.Request('GET', Uri.parse('$baseUrl/repositories'));

      http.StreamedResponse streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);

      print(response.statusCode);
      if (response.statusCode == 200) {
        print('Successful');
      } else {
        print(response.reasonPhrase);
      }
    } catch (error) {
      print('Error: $error');
      Navigator.pushReplacement(
        context,
        PageTransition(
          child: NetworkErrorScreen(),
          type: PageTransitionType.rippleRightUp,
        ),
      );
    }
    return response;
  }
}
