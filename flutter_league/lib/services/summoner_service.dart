import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riot_api/model/summoner.dart';
import 'package:flutter_riot_api/utils/constants.dart';

Future<Summoner?> getSummonerByName(String summonerName) async {
  final summonerResponse = await http.get(
    Uri.parse(
        '${apiUrl}summoner/v4/summoners/by-name/$summonerName?api_key=$apikey'),
  );

  if (summonerResponse.statusCode == 200) {
    final summonerData = jsonDecode(summonerResponse.body);
    final rankedData = await getRankedData(summonerData['id']);
    final jsonResult = (rankedData['result'] != 'Unranked')
        ? mergeJson(summonerData, rankedData)
        : summonerData;
    final summonerObjResponse = Summoner.fromJson(jsonResult);
    return summonerObjResponse;
  } else {
    // TODO: handle error
    return null;
  }
}

Future<Map<String, dynamic>> getRankedData(String accountId) async {
  final rankedResponse = await http.get(
    Uri.parse(
        '${apiUrl}league/v4/entries/by-summoner/$accountId?api_key=$apikey'),
  );

  if (rankedResponse.statusCode == 200) {
    final rankedData = jsonDecode(rankedResponse.body);
    if (rankedData.isNotEmpty) {
      return rankedData.last;
    }
  }

  return {'result': 'Unranked'};
}

Map<String, dynamic> mergeJson(
    Map<String, dynamic> summonerData, Map<String, dynamic> rankedData) {
  return {
    ...summonerData,
    ...rankedData,
  };
}
