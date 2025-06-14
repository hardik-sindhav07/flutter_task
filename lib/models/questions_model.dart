class QuestionsModel {
  int? statusCode;
  List<Data>? data;
  String? message;

  QuestionsModel({this.statusCode, this.data, this.message});

  QuestionsModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  String? questionText;
  String? suggestedResponseHint;
  String? suggestedResponseText;

  Data(
      {this.questionText,
        this.suggestedResponseHint,
        this.suggestedResponseText});

  Data.fromJson(Map<String, dynamic> json) {
    questionText = json['question_text'];
    suggestedResponseHint = json['suggested_response_hint'];
    suggestedResponseText = json['suggested_response_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question_text'] = questionText;
    data['suggested_response_hint'] = suggestedResponseHint;
    data['suggested_response_text'] = suggestedResponseText;
    return data;
  }
}
