// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluate_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EvaluateRequest _$EvaluateRequestFromJson(Map<String, dynamic> json) =>
    EvaluateRequest(
      questionText: json['question_text'] as String,
      responseText: json['response_text'] as String,
      durationMs: (json['duration_ms'] as num).toInt(),
      expectedResponseText: json['expected_response_text'] as String?,
    );

Map<String, dynamic> _$EvaluateRequestToJson(EvaluateRequest instance) {
  final val = <String, dynamic>{
    'question_text': instance.questionText,
    'response_text': instance.responseText,
    'duration_ms': instance.durationMs,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('expected_response_text', instance.expectedResponseText);
  return val;
}

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element

class _EvaluateApi implements EvaluateApi {
  _EvaluateApi(
    this._dio, {
    this.baseUrl,
    this.errorLogger,
  }) {
    baseUrl ??= 'https://dev42n01.ostello.co.in/fluency-test';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<dynamic> evaluate(
    EvaluateRequest request,
    String authToken,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': authToken};
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<dynamic>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/evaluate',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(
    String dioBaseUrl,
    String? baseUrl,
  ) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
