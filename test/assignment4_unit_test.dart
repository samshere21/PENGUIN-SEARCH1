import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:penguin_search/report.dart';

// Creates fresh test data without using a database or network.
ItemReport sampleReport({
  String id = 'report-1',
  String ownerId = 'samir',
  String title = 'Blue backpack',
  String description = 'Found near the entrance.',
  String location = 'Maag Library',
  DateTime? returnedAt,
}) {
  return ItemReport(
    id: id,
    ownerId: ownerId,
    title: title,
    description: description,
    location: location,
    category: 'Other',
    kind: ReportKind.found,
    occurredAt: DateTime(2026, 11, 19),
    createdAt: DateTime(2026, 11, 20, 9),
    // Validation checks photo presence; these bytes are not displayed.
    photo: Uint8List.fromList([1, 2, 3]),
    returnedAt: returnedAt,
  );
}

void main() {
  group('Unit 1: Search', () {
    late List<ItemReport> reports;

    setUp(() {
      reports = [
        sampleReport(
          id: 'active-backpack',
          title: 'Blue Backpack',
        ),
        sampleReport(
          id: 'active-headphones',
          title: 'Black headphones',
        ),
        sampleReport(
          id: 'returned-backpack',
          title: 'Red backpack',
          returnedAt: DateTime(2026, 11, 20, 10),
        ),
      ];
    });

    test('U1.1 Finds only matching active reports', () {
      final results = searchReports(
        reports,
        query: 'backpack',
      );

      expect(
        results.map((report) => report.id).toList(),
        ['active-backpack'],
      );
    });

    test('U1.2 Blank search returns all active reports', () {
      final results = searchReports(
        reports,
        query: '   ',
      );

      expect(
        results.map((report) => report.id),
        unorderedEquals([
          'active-backpack',
          'active-headphones',
        ]),
      );
    });

    test('U1.3 Unmatched keyword returns an empty list', () {
      final results = searchReports(
        reports,
        query: 'calculator',
      );

      expect(results, isEmpty);
    });
  });

  group('Unit 2: Validation', () {
    test('U2.1 Accepts valid required fields and a photo', () {
      final report = sampleReport();

      expect(
        () => validateReport(report),
        returnsNormally,
      );
    });

    test('U2.2 Rejects a whitespace-only title', () {
      final report = sampleReport(title: '   ');

      expect(
        () => validateReport(report),
        throwsArgumentError,
      );
    });

    test('U2.3 Rejects an empty location', () {
      final report = sampleReport(location: '');

      expect(
        () => validateReport(report),
        throwsArgumentError,
      );
    });
  });

  group('Unit 3: Mark Returned', () {
    test('U3.1 Marks an active report returned at the given time', () {
      final report = sampleReport();
      final returnTime = DateTime(2026, 11, 20, 12);

      expect(report.isReturned, isFalse);
      expect(report.returnedAt, isNull);

      final result = markReportReturned(
        report,
        at: returnTime,
      );

      expect(result, isTrue);
      expect(report.isReturned, isTrue);
      expect(report.returnedAt, returnTime);
    });

    test('U3.2 Rejects a repeated return without changing its time', () {
      final originalTime = DateTime(2026, 11, 20, 12);
      final report = sampleReport(returnedAt: originalTime);

      final result = markReportReturned(
        report,
        at: DateTime(2026, 11, 21, 15),
      );

      expect(result, isFalse);
      expect(report.isReturned, isTrue);
      expect(report.returnedAt, originalTime);
    });

    test('U3.3 Preserves report details when marking returned', () {
      final report = sampleReport(
        id: 'umbrella-1',
        ownerId: 'diego',
        title: 'Umbrella',
        description: 'Black umbrella near the library entrance.',
      );
      final originalPhoto = report.photo;

      final result = markReportReturned(
        report,
        at: DateTime(2026, 11, 20, 12),
      );

      expect(result, isTrue);
      expect(report.isReturned, isTrue);
      expect(report.id, 'umbrella-1');
      expect(report.title, 'Umbrella');
      expect(report.ownerId, 'diego');
      expect(
        report.description,
        'Black umbrella near the library entrance.',
      );
      expect(report.location, 'Maag Library');
      expect(report.photo, same(originalPhoto));
    });
  });

  group('Unit 4: Ownership Guard', () {
    test('U4.1 Allows the report creator', () {
      final report = sampleReport(ownerId: 'samir');

      expect(canModifyReport(report, 'samir'), isTrue);
    });

    test('U4.2 Rejects empty and whitespace user IDs', () {
      final report = sampleReport(ownerId: 'samir');

      expect(canModifyReport(report, ''), isFalse);
      expect(canModifyReport(report, '   '), isFalse);

      // Even matching blank IDs must not grant permission.
      final emptyOwnerReport = sampleReport(ownerId: '');
      final blankOwnerReport = sampleReport(ownerId: '   ');

      expect(canModifyReport(emptyOwnerReport, ''), isFalse);
      expect(canModifyReport(blankOwnerReport, '   '), isFalse);
    });

    test('U4.3 Rejects a different user', () {
      final report = sampleReport(ownerId: 'samir');

      expect(canModifyReport(report, 'prashant'), isFalse);
      expect(report.isReturned, isFalse);
    });
  });
}