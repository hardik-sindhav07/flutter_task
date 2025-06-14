import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../models/questions_model.dart';

part 'questions_api.g.dart';

@RestApi(baseUrl: "https://dev42n01.ostello.co.in/fluency-test/onboarding")
abstract class QuestionsApi {
  factory QuestionsApi(Dio dio, {String baseUrl}) = _QuestionsApi;

  @GET("/question")
  Future<QuestionsModel> fetchQuestions();
} 