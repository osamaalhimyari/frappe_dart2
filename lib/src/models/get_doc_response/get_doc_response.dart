import 'dart:convert';

import 'package:frappe_dart/src/models/get_doc_response/doc.dart';
import 'package:frappe_dart/src/models/get_doc_response/docinfo.dart';

class GetDocResponse {
  GetDocResponse({
    this.docs,
    this.docinfo,
    this.rawData,
    this.rawDocs,
  });

  factory GetDocResponse.fromMap(Map<String, dynamic> data) {
    return GetDocResponse(
      docs: (data['docs'] as List<dynamic>?)
          ?.map((e) => Doc.fromMap(e as Map<String, dynamic>))
          .toList(),

      // ✅ Keep raw docs as original maps
      rawDocs: (data['docs'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),

      docinfo: data['docinfo'] == null
          ? null
          : Docinfo.fromMap(data['docinfo'] as Map<String, dynamic>),

      // ✅ Keep entire raw response
      rawData: Map<String, dynamic>.from(data),
    );
  }

  factory GetDocResponse.fromJson(String data) {
    return GetDocResponse.fromMap(
      json.decode(data) as Map<String, dynamic>,
    );
  }

  /// Typed parsed docs
  List<Doc>? docs;

  /// Typed parsed docinfo
  Docinfo? docinfo;

  /// Full raw response JSON
  Map<String, dynamic>? rawData;

  /// Raw docs list (useful for dynamic fields)
  List<Map<String, dynamic>>? rawDocs;

  Map<String, dynamic> toMap() =>
      rawData ??
      {
        'docs': docs?.map((e) => e.toMap()).toList(),
        'docinfo': docinfo?.toMap(),
      };

  String toJson() => json.encode(toMap());
}
