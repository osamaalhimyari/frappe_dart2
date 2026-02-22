// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:frappe_dart/src/models/get_doctype_response/non_standard_fieldnames.dart';
import 'package:frappe_dart/src/models/get_doctype_response/transaction.dart';

class Dashboard {
  Dashboard({
    this.transactions,
    this.nonStandardFieldnames,
    this.fieldname,
    this.heatmap = false, // ✅ default value
  });

  factory Dashboard.fromMap(Map<String, dynamic> data) => Dashboard(
        transactions: (data['transactions'] as List<dynamic>?)
            ?.map((e) => Transaction.fromMap(e as Map<String, dynamic>))
            .toList(),
        nonStandardFieldnames: data['non_standard_fieldnames'] == null
            ? null
            : NonStandardFieldnames.fromMap(
                data['non_standard_fieldnames'] as Map<String, dynamic>,
              ),
        fieldname: data['fieldname'] as String?,
        heatmap: data['heatmap'] as bool? ?? false, // ✅ parse safely
      );

  /// Parses JSON string into Dashboard
  factory Dashboard.fromJson(String data) {
    return Dashboard.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  List<Transaction>? transactions;
  NonStandardFieldnames? nonStandardFieldnames;
  String? fieldname;
  bool heatmap; // ✅ moved below fields and not initialized here

  Map<String, dynamic> toMap() => {
        'transactions': transactions?.map((e) => e.toMap()).toList(),
        'non_standard_fieldnames': nonStandardFieldnames?.toMap(),
        'fieldname': fieldname,
        'heatmap': heatmap, // ✅ added to JSON output
      };

  /// Converts Dashboard to JSON string
  String toJson() => json.encode(toMap());
}
