import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'evaluate_api.g.dart';

@RestApi(baseUrl: "https://dev42n01.ostello.co.in/fluency-test")
abstract class EvaluateApi {
  factory EvaluateApi(Dio dio, {String baseUrl}) = _EvaluateApi;

  @POST("/evaluate")
  Future<dynamic> evaluate(
    @Body() EvaluateRequest request,
    @Header("Authorization") String authToken,
  );
}

@JsonSerializable()
class EvaluateRequest {
  @JsonKey(name: 'question_text')
  final String questionText;
  @JsonKey(name: 'response_text')
  final String responseText;
  @JsonKey(name: 'duration_ms')
  final int durationMs;
  @JsonKey(name: 'expected_response_text', includeIfNull: false)
  final String? expectedResponseText;

  EvaluateRequest({
    required this.questionText,
    required this.responseText,
    required this.durationMs,
    this.expectedResponseText,
  });

  factory EvaluateRequest.fromJson(Map<String, dynamic> json) => _$EvaluateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EvaluateRequestToJson(this);
}
