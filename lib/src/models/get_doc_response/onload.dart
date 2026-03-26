// ignore_for_file: public_member_api_docs

import 'dart:convert';

class Onload {
  Onload({this.allModules});

  factory Onload.fromMap(Map<String, dynamic> data) => Onload(
       allModules: data['all_modules'] == null 
          ? null 
          : List<String>.from(data['all_modules'] as List)
      );

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Onload].
  factory Onload.fromJson(String data) {
    return Onload.fromMap(json.decode(data) as Map<String, dynamic>);
  }
  List<String>? allModules;

  Map<String, dynamic> toMap() => {
        'all_modules': allModules,
      };

  /// `dart:convert`
  ///
  /// Converts [Onload] to a JSON string.
  String toJson() => json.encode(toMap());
}
