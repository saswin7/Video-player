import 'dart:async';
import 'package:apm_pip/models/apmModel.dart';
//import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:apm_pip/common/constants.dart';

class HttpHandler {
  final dio = Dio();
  final String _baseUrl = 
    env == 'development' ? API_URL_DEV : API_URL_PROD;
  String endpoint;
  
  HttpHandler(){
    endpoint = createEndpoint();
  }

  String createEndpoint(){
      String endpoint;
      
      endpoint = _baseUrl + '/api/v1/apm';
          
      return endpoint;
  }
 
  Future<List<Apm>> getAll() async {

    try {
        Response res = await dio.get(endpoint);
        final resBody = res.data;

        if (res.statusCode == 200) {
          return resBody['data'].map<Apm>((item) => 
            Apm.fromJson(item)
          ).toList();
        } 
    }catch (e) {
      errorHandler(e);
    }

  }

  Future<Apm> create(Apm apm) async{

    try{
      Response res = await dio.post(
            endpoint,
            data: {
              'name' : apm.name,
              'command' : apm.command,
              'desc' : apm.desc,
              'url' : apm.url
            }
          );

      final resBody = res.data;

      if (res.statusCode == 201){
        return Apm.fromJson(resBody['data']);
      }

    }catch(e){
      errorHandler(e);
      }
    } 

    Future<Apm> delete(int id) async{
      try {
        final Response res = await dio.delete(endpoint + '/' + id.toString());
        final resBody = res.data;

        if (res.statusCode == 200){
          return Apm.fromJson(resBody['data']);
        }
      } catch (e) {
        errorHandler(e);
      }
    }

    Future<Apm> edit(Apm apm) async{
      try{
        final res = await dio.put(
            endpoint + '/' + apm.id.toString(),
            data: {
              "name" : apm.name,
              "command" : apm.command,
              "desc" : apm.desc,
              "url" : apm.url
            });
        final resBody = res.data;

        if (res.statusCode == 200){
          return Apm.fromJson(resBody['data']);
        }
      }catch(e){
        errorHandler(e);
      }
    }

    void errorHandler(e){
       if (e.response != null){
        final resError = e.response.data;
        String errorMsg = resError['error'];
        
        throw errorMsg;
      }

      if (e.error.osError != null){
        int code = e.error.osError.errorCode;
        if (code == 101)
          throw 'Sin conexión a internet';
        if (code == 111)
          throw 'Conexión rechazada. Posiblemente la API no esté online';
      }
      throw e.error?.message;
    }
  }
