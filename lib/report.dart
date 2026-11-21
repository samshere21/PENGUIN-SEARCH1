import 'package:flutter/foundation.dart';

enum ReportKind { lost, found }

const categories = [
  'Electronics',
  'Keys',
  'Clothing',
  'Books',
  'Other',
];

const meetingPoint = 'Library front desk, main floor';
const demoUserId = 'demo-student';

class ItemReport {
  ItemReport({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.kind,
    required this.occurredAt,
    required this.createdAt,
    this.photo,
    this.returnedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String location;
  final String category;
  final ReportKind kind;
  final DateTime occurredAt;
  final DateTime createdAt;
  final Uint8List? photo;

  DateTime? returnedAt;

  bool get isReturned => returnedAt != null;
}

// Unit 1: Search reports.
List<ItemReport> searchReports(
  Iterable<ItemReport> reports, {
  String query = '',
  String category = 'All',
  String location = '',
  ReportKind? kind,
  bool history = false,
  DateTime? date,
}) {
  final keyword = query.trim().toLowerCase();
  final locationFilter = location.trim().toLowerCase();

  final results = reports.where((report) {
    final searchableText =
        '${report.title} ${report.description}'.toLowerCase();

    final matchesDate = date == null ||
        (report.occurredAt.year == date.year &&
            report.occurredAt.month == date.month &&
            report.occurredAt.day == date.day);

    return report.isReturned == history &&
        (category == 'All' || report.category == category) &&
        (kind == null || report.kind == kind) &&
        searchableText.contains(keyword) &&
        report.location.toLowerCase().contains(locationFilter) &&
        matchesDate;
  }).toList();

  results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return results;
}

// Unit 2: Validate required report information.
void validateReport(ItemReport report) {
  if (report.title.trim().isEmpty ||
      report.description.trim().isEmpty ||
      report.location.trim().isEmpty ||
      report.photo == null ||
      report.photo!.isEmpty) {
    throw ArgumentError(
      'Name, description, location, and photo are required.',
    );
  }
}

// Unit 3: Change a report to returned.
// The optional time allows tests to check an exact timestamp.
bool markReportReturned(ItemReport report, {DateTime? at}) {
  if (report.isReturned) {
    return false;
  }

  report.returnedAt = at ?? DateTime.now();
  return true;
}

// Unit 4: Check whether the current user owns the report.
// This is a prototype check. Server authorization is still needed
// when the application gains a backend.
bool canModifyReport(ItemReport report, String actorId) {
  return actorId.trim().isNotEmpty && report.ownerId == actorId;
}

/// Stores reports in memory for the local demo.
class ReportStore extends ChangeNotifier {
  ReportStore({bool seed = true}) {
    if (!seed) {
      return;
    }

    final now = DateTime.now();

    _reports.addAll([
      ItemReport(
        id: 'sample-1',
        ownerId: demoUserId,
        title: 'Blue water bottle',
        description:
            'Sample listing: blue bottle with a black lid. No real item.',
        location: 'Library, second floor',
        category: 'Other',
        kind: ReportKind.found,
        occurredAt: now,
        createdAt: now,
      ),
      ItemReport(
        id: 'sample-2',
        ownerId: 'another-demo-student',
        title: 'Black headphones',
        description: 'Sample listing: over-ear headphones in a soft case.',
        location: 'Student center',
        category: 'Electronics',
        kind: ReportKind.lost,
        occurredAt: now.subtract(const Duration(days: 1)),
        createdAt: now,
      ),
    ]);
  }

  final List<ItemReport> _reports = [];

  List<ItemReport> get reports => List.unmodifiable(_reports);

  List<ItemReport> search({
    String query = '',
    String category = 'All',
    String location = '',
    ReportKind? kind,
    bool history = false,
    DateTime? date,
  }) {
    return searchReports(
      _reports,
      query: query,
      category: category,
      location: location,
      kind: kind,
      history: history,
      date: date,
    );
  }

  void add(ItemReport report) {
    validateReport(report);
    _reports.insert(0, report);
    notifyListeners();
  }

  bool markReturned(String id, String actorId) {
    final matches = _reports.where((report) => report.id == id);

    if (matches.isEmpty) {
      return false;
    }

    final report = matches.first;

    if (!canModifyReport(report, actorId)) {
      return false;
    }

    if (!markReportReturned(report)) {
      return false;
    }

    notifyListeners();
    return true;
  }
}