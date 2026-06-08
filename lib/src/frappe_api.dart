import 'package:frappe_dart2/frappe_dart2.dart';
import 'package:frappe_dart2/src/models/report_view_request.dart';
import 'package:frappe_dart2/src/models/report_view_response.dart';
import 'package:frappe_dart2/src/models/savedocs_response/savedocs_response.dart';
import 'package:frappe_dart2/src/models/send_email_response.dart';

/// An abstract class that defines the Frappe API.
abstract class FrappeApi {
  /// Logs in the user.
  ///
  /// Takes a [LoginRequest] object as input and returns a [LoginResponse].
  Future<LoginResponse> login(LoginRequest loginRequest);

  /// Logs out the current user.
  ///
  /// Returns an [LogoutResponse] indicating the result of the logout operation.
  Future<LogoutResponse> logout();

  /// Retrieves the logged user
  ///
  /// Returns a [LoggedUserResponse] containing the user's username or email.
  Future<LoggedUserResponse> getLoggerUser();

  /// Retrieves the session default values.
  ///
  /// Returns a [Map<String, dynamic>] containing the session default values.
  Future<Map<String, dynamic>> getSessionDefaultValues();

  /// Retrieves the notifications values.
  ///
  /// Returns a [Map<String, dynamic>] containing the session default values.
  Future<Map<String, dynamic>> notificationsLog();

  /// Retrieves the desk sidebar items.
  ///
  /// Returns a [DeskSidebarItemsResponse] with the list of sidebar items.
  Future<DeskSidebarItemsResponse> getDeskSideBarItems();

  /// Retrieves a desktop page based on the provided request.
  ///
  /// Takes a [DesktopPageRequest] object and returns a [DesktopPageResponse].
  Future<DesktopPageResponse> getDesktopPage(
    DesktopPageRequest deskPageRequest,
  );

  /// Retrieves a number card by its name.
  ///
  /// Takes the [name] of the number card and returns a [NumberCardResponse].
  Future<NumberCardResponse> getNumberCard(String doc, String filters);

  /// Retrieves a number card percentage difference by its name.
  ///
  /// Takes the [name] of the number card and
  /// returns a [NumberCardPercentageDifferenceResponse].
  Future<NumberCardPercentageDifferenceResponse>
  getNumberCardPercentageDifference(String doc, String filters, String result);

  /// Retrieves details of a specific doctype.
  ///
  /// Takes the [doctype] as a parameter and returns an [Map<String, dynamic>].
  Future<Map<String, dynamic>> getFieldsForTable(String doctype);
 
  /// Retrieves details of a specific doctype.
  ///
  /// Takes the [doctype] as a parameter and returns an [GetDoctypeResponse].
  Future<GetDoctypeResponse> getDoctype(String doctype);

  /// Retrieves a document by doctype and name.
  ///
  /// Takes [doctype] and [name] as parameters and returns a [GetDocResponse].
  Future<GetDocResponse> getdoc(String doctype, String name);

  ///
  /// Retrieves a document by doctype and name.
  ///
  /// Takes [doctype] and [name] as parameters and returns a [Map<String,dynamic>].
  Future<Map<String,dynamic>> getdocData(String doctype, String name);

  ///
  Future<GetCountResponse> getCount(GetCountRequest getCountRequest);

  /// Saves documents.
  ///
  /// Returns an [SavedocsReponse<T>] indicating the result of the operation.
  Future<SavedocsReponse<T>> savedocs<T>({
    required T document,
    required String action,
    required String Function() toJson,
    required T Function(Map<String, dynamic>) fromMap,
  });

  /// Searches for a link.
  ///
  /// Returns an [SearchLinkResponse] containing the search results.
  Future<SearchLinkResponse> searchLink(SearchLinkRequest searchLinkRequest);

  /// Validate a link.
  ///
  /// Returns an [ValidateLinkResponse] containing the validate link results.
  Future<Map<String, dynamic>> validateLink(
    ValidateLinkRequest validateLinkRequest,
  );

  /// Retrieves the system settings.
  ///
  /// Returns a [SystemSettingsResponse] containing the system settings.
  Future<SystemSettingsResponse> getSystemSettings();

  /// Retrieves the system versions.
  ///
  /// Returns a [GetVersionsResponse] containing version information.
  Future<GetVersionsResponse> getVersions();

  /// Retrieves a list of items based on the specified parameters.
  ///
  /// Takes [fields], [limitStart], [orderBy], and [doctype] as parameters
  /// and returns a [Map].
  Future<Map<String, dynamic>> getList({
    required String doctype,
    List<String>? fields,
    int? limitStart,
    int? limitPageLength,
    String? orderBy,
    String? parent,
    Map<String, dynamic>? filters,
    String? groupBy,
    bool? debug,
    bool? asDict,
    Map<String, dynamic>? orFilters,
  });

  /// Retrieves the list of apps
  ///
  /// Returns an [AppsResponse] containing the list of apps.
  Future<AppsResponse> getApps();

  /// Retrieves the user info
  ///
  /// Returns an [UserInfoResponse] containing the user info.
  Future<UserInfoResponse> getUserInfo();

  /// Pings the server.
  ///
  /// Returns a [PingResponse] containing the ping response.
  Future<PingResponse> ping();

  /// Saves a document.
  ///
  /// Takes a [Map] of [String, dynamic] as input and returns a [Map].
  Future<Map<String, dynamic>> save(Map<String, dynamic> doc);

  /// Deletes a document.
  ///
  /// Takes a [DeleteDocRequest] as input and returns a [Map].
  Future<Map<String, dynamic>> deleteDoc(DeleteDocRequest deleteDocRequest);

  /// Retrieves a value from the server.
  ///
  /// Takes a [GetRequest] as input and returns a [Map].
  Future<Map<String, dynamic>> getValue({
    required String doctype,
    required String fieldname,
  });

  /// Retrieves a document by doctype and name.
  ///
  /// Takes a [GetRequest] object as input and returns a [Map].
  Future<Map<String, dynamic>> get(GetRequest getRequest);

  Future<Map<String, dynamic>> call({
    required String method,
    required String type,
    Map<String, dynamic>? args,
    String? url,
  });

  /// Retrieves a dashboard chart.
  ///
  /// Takes a [Map] of [String, dynamic] as input and returns a [Map].
  Future<Map<String, dynamic>> getDashboardChart(Map<String, dynamic> payload);

  /// Executes a report run with the provided payload.
  ///
  /// Takes a [payload] containing report parameters and returns a [Map] with the report results.
  Future<Map<String, dynamic>> getReportRun(Map<String, dynamic> payload);

  /// Sends an email with the provided parameters.
  ///
  /// Takes a [SendEmailRequest] object as input and returns a [SendEmailResponse].
  Future<SendEmailResponse> sendEmail({
    required String recipients,
    required String subject,
    required String content,
    required String doctype,
    required String name,
    required String sendEmail,
    required String printFormat,
    required String senderFullName,
    required String lang,
  });

  /// Retrieves a report view with the provided request.
  ///
  /// Takes a [ReportViewRequest] object as input and returns a [ReportViewResponse].
  Future<ReportViewResponse> getReportView(ReportViewRequest reportViewRequest);

  /// Maps documents with the provided parameters.
  ///
  /// Takes a [List<String>] of source names, a [Map<String, dynamic>] of target document, and a [String] of method as parameters and returns a [Map].
  Future<Map<String, dynamic>> mapDocs({
    required List<String> sourceName,
    required Map<String, dynamic> targetDoc,
    required String method,
  });

  /// Switches the theme with the provided parameter.
  ///
  /// Takes a [String] of theme as parameter and returns a [Map].
  Future<Map<String, dynamic>> switchTheme({required String theme});

  /// Searches for a widget with the provided parameters.
  ///
  /// Takes a [String] of doctype, a [String] of txt, a [String] of query, a [Map<String, dynamic>] of filters, a [List<String>] of filter fields, a [String] of search field, a [String] of start, and a [String] of page length as parameters and returns a [Map].
  Future<Map<String, dynamic>> searchWidget({
    required String doctype,
    required String txt,
    required String query,
    required Map<String, dynamic> filters,
    List<String>? filterFields,
    String? searchField,
    String start = '0',
    String pageLength = '10',
  });

  /// Runs a document method with the provided parameters.
  ///
  /// Takes a [Map<String, dynamic>] of data and a [String] of method as parameters and returns a [Map].
  Future<Map<String, dynamic>> runDocMethod({
    required Map<String, dynamic> data,
    required String method,
  });

  // ===========================================================================
  // Token auth
  // ===========================================================================

  /// Enables API-key / API-secret authentication.
  ///
  /// Sets an `Authorization: token <apiKey>:<apiSecret>` header on every
  /// request. Call with both `null` to clear and fall back to cookie auth.
  void setApiToken({String? apiKey, String? apiSecret});

  // ===========================================================================
  // Client CRUD parity (frappe.client.*)
  // ===========================================================================

  /// Inserts a new document. Wraps `frappe.client.insert`.
  Future<Map<String, dynamic>> insert(Map<String, dynamic> doc);

  /// Inserts up to 200 documents in a single request.
  /// Wraps `frappe.client.insert_many`.
  Future<Map<String, dynamic>> insertMany(List<Map<String, dynamic>> docs);

  /// Updates one or more fields on a document.
  ///
  /// Pass [fieldname] as a `String` for a single field, or a `Map` for many.
  /// Wraps `frappe.client.set_value`.
  Future<Map<String, dynamic>> setValue({
    required String doctype,
    required String name,
    required Object fieldname,
    Object? value,
  });

  /// Updates many documents in a single request.
  /// Wraps `frappe.client.bulk_update`.
  Future<Map<String, dynamic>> bulkUpdate(List<Map<String, dynamic>> docs);

  /// Renames a document, optionally merging into an existing record.
  /// Wraps `frappe.client.rename_doc`.
  Future<Map<String, dynamic>> renameDoc({
    required String doctype,
    required String oldName,
    required String newName,
    bool merge = false,
  });

  /// Submits a document. Wraps `frappe.client.submit`.
  Future<Map<String, dynamic>> submit(Map<String, dynamic> doc);

  /// Cancels a submitted document. Wraps `frappe.client.cancel`.
  Future<Map<String, dynamic>> cancel({
    required String doctype,
    required String name,
  });

  /// Reads a single field from a Single doctype.
  /// Wraps `frappe.client.get_single_value`.
  Future<Map<String, dynamic>> getSingleValue({
    required String doctype,
    required String field,
  });

  /// Checks whether the current user has the requested permission.
  /// Wraps `frappe.client.has_permission`.
  Future<Map<String, dynamic>> hasPermission({
    required String doctype,
    required String docname,
    String permType = 'read',
  });

  /// Reads a password field. System Manager only.
  /// Wraps `frappe.client.get_password`.
  Future<Map<String, dynamic>> getPassword({
    required String doctype,
    required String name,
    required String fieldname,
  });

  // ===========================================================================
  // Files
  // ===========================================================================

  /// Uploads bytes to Frappe's File doctype.
  ///
  /// When [doctype], [docname] and [fieldname] are supplied, the resulting
  /// file is attached to that field. Wraps `/api/method/upload_file`.
  Future<Map<String, dynamic>> uploadFile({
    required List<int> fileBytes,
    required String fileName,
    String? doctype,
    String? docname,
    String? fieldname,
    bool isPrivate = false,
    String? folder,
    bool optimize = false,
  });

  /// Downloads file bytes from a `/files/...` or `/private/files/...` URL.
  Future<List<int>> downloadFile(String fileUrl);

  // ===========================================================================
  // Collaboration: assignments, comments, tags, share
  // ===========================================================================

  /// Assigns a doc to one or more users.
  /// Wraps `frappe.desk.form.assign_to.add`.
  Future<Map<String, dynamic>> assignTo({
    required List<String> assignTo,
    required String doctype,
    required String name,
    String? description,
    String? priority,
    String? dateOfAssignment,
    bool notify = false,
  });

  /// Removes an assignment from a doc.
  /// Wraps `frappe.desk.form.assign_to.remove`.
  Future<Map<String, dynamic>> removeAssign({
    required String doctype,
    required String name,
    required String assignTo,
  });

  /// Adds a comment to a doc.
  /// Wraps `frappe.desk.form.utils.add_comment`.
  Future<Map<String, dynamic>> addComment({
    required String referenceDoctype,
    required String referenceName,
    required String content,
    String? commentEmail,
    String? commentBy,
  });

  /// Adds a tag to a doc.
  /// Wraps `frappe.desk.doctype.tag.tag.add_tag`.
  Future<Map<String, dynamic>> addTag({
    required String tag,
    required String doctype,
    required String docname,
  });

  /// Removes a tag from a doc.
  /// Wraps `frappe.desk.doctype.tag.tag.remove_tag`.
  Future<Map<String, dynamic>> removeTag({
    required String tag,
    required String doctype,
    required String docname,
  });

  /// Shares a doc with a user. Wraps `frappe.share.add`.
  Future<Map<String, dynamic>> shareAdd({
    required String doctype,
    required String name,
    required String user,
    bool read = true,
    bool write = false,
    bool share = false,
    bool everyone = false,
    bool notify = false,
  });

  /// Removes a share. Wraps `frappe.share.remove`.
  Future<Map<String, dynamic>> shareRemove({
    required String doctype,
    required String name,
    required String user,
  });

  // ===========================================================================
  // Workflow
  // ===========================================================================

  /// Applies a workflow action to a document.
  /// Wraps `frappe.model.workflow.apply_workflow`.
  Future<Map<String, dynamic>> applyWorkflow({
    required Map<String, dynamic> doc,
    required String action,
  });

  /// Lists workflow transitions available for the doc.
  /// Wraps `frappe.model.workflow.get_transitions`.
  Future<Map<String, dynamic>> getWorkflowTransitions(
    Map<String, dynamic> doc,
  );

  // ===========================================================================
  // Print / PDF
  // ===========================================================================

  /// Downloads a PDF rendered with a print format.
  /// Wraps `frappe.utils.print_format.download_pdf`.
  Future<List<int>> downloadPdf({
    required String doctype,
    required String name,
    String format = 'Standard',
    bool noLetterhead = false,
    String? lang,
    String? letterhead,
  });

  /// Returns rendered print HTML + style for a doc.
  /// Wraps `frappe.www.printview.get_html_and_style`.
  Future<Map<String, dynamic>> getPrintHtml({
    required String doctype,
    required String name,
    String format = 'Standard',
    bool noLetterhead = false,
    String? lang,
    String? letterhead,
  });

  // ===========================================================================
  // Desk list view (raw Map responses)
  // ===========================================================================

  /// Wraps `frappe.desk.reportview.get` — the endpoint Desk uses to
  /// populate a list view. Returns the raw response Map; the rows live
  /// at `message.values` and the column names at `message.keys`.
  ///
  /// [fields] should be fully-qualified (`` `tab<Doctype>`.`<field>` ``).
  /// [filters] is a list of `[doctype, field, op, value]` tuples.
  Future<Map<String, dynamic>> reportviewGet({
    required String doctype,
    required List<String> fields,
    required List<List<dynamic>> filters,
    required String orderBy,
    required int start,
    required int pageLength,
    String view = 'List',
    String groupBy = '',
    bool withCommentCount = true,
  });

  /// Wraps `frappe.desk.reportview.get_count` — total count for a Desk
  /// list view. Returns the raw response Map (`{message: <int>}`).
  Future<Map<String, dynamic>> reportviewGetCount({
    required String doctype,
    required List<List<dynamic>> filters,
    List<String> fields = const [],
    bool distinct = false,
    int limit = 1001,
  });

  /// Wraps `frappe.desk.notifications.get_open_count` — per-connection
  /// link counts. Returns the raw response Map; the badge data lives at
  /// `message.count.external_links_found`.
  Future<Map<String, dynamic>> getOpenCount({
    required String doctype,
    required String name,
    required List<String> items,
  });

  /// Wraps `erpnext.stock.dashboard.item_dashboard.get_data` — the
  /// warehouse-stock summary rendered above the Item form. Returns the
  /// raw response Map (`{message: [<rows>]}`).
  Future<Map<String, dynamic>> getItemDashboardData({
    required String itemCode,
    int start = 0,
    String sortBy = 'projected_qty',
    String sortOrder = 'asc',
  });
}
