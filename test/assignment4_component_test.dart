import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:penguin_search/report.dart';

ItemReport componentReport({
  required String id,
  String ownerId = 'samir',
  String title = 'Red YSU Hoodie',
  String location = 'Maag Library',
  String category = 'Other',
}) {
  return ItemReport(
    id: id,
    ownerId: ownerId,
    title: title,
    description: 'Found near the main entrance.',
    location: location,
    category: category,
    kind: ReportKind.found,
    occurredAt: DateTime(2026, 11, 19),
    createdAt: DateTime(2026, 11, 20, 9),
    photo: Uint8List.fromList([1, 2, 3]),
  );
}

void main() {
  late ReportStore store;

  // Every test gets a fresh, empty store.
  setUp(() {
    store = ReportStore(seed: false);
  });

  tearDown(() {
    store.dispose();
  });

  group('Component 1: Create & Search', () {
    test('C1.1 Saves a valid report and retrieves it through search', () {
      final report = componentReport(
        id: 'hoodie-1',
        title: 'Red YSU Hoodie',
        category: 'Clothing',
      );

      store.add(report);

      expect(store.reports, hasLength(1));

      final results = store.search(query: 'hoodie');

      expect(
        results.map((report) => report.id).toList(),
        ['hoodie-1'],
      );
      expect(results.single.title, 'Red YSU Hoodie');
      expect(results.single.ownerId, 'samir');
      expect(results.single.category, 'Clothing');
      expect(results.single.location, 'Maag Library');
      expect(results.single.isReturned, isFalse);
    });

    test('C1.2 Rejects invalid input without saving a report', () {
      final report = componentReport(
        id: 'invalid-1',
        title: '   ',
      );

      expect(
        () => store.add(report),
        throwsArgumentError,
      );

      expect(store.reports, isEmpty);
      expect(store.search(), isEmpty);
      expect(store.search(history: true), isEmpty);
    });

    test('C1.3 Filters stored reports by campus location', () {
      store.add(
        componentReport(
          id: 'library-item',
          title: 'Notebook',
          location: 'Maag Library',
          category: 'Books',
        ),
      );

      store.add(
        componentReport(
          id: 'center-item',
          title: 'Keys',
          location: 'Kilcawley Center',
          category: 'Keys',
        ),
      );

      final results = store.search(location: 'Maag Library');

      expect(
        results.map((report) => report.id).toList(),
        ['library-item'],
      );
      expect(results.single.location, 'Maag Library');

      // Filtering must not remove records from storage.
      expect(store.reports, hasLength(2));
    });
  });

  group('Component 2: Ownership & Return', () {
    test('C2.1 Creator returns a report and it appears in history', () {
      store.add(
        componentReport(
          id: 'wallet-1',
          ownerId: 'samir',
          title: 'Leather Wallet',
        ),
      );

      expect(store.search(), hasLength(1));
      expect(store.search(history: true), isEmpty);

      final result = store.markReturned('wallet-1', 'samir');

      expect(result, isTrue);
      expect(store.search(), isEmpty);

      final history = store.search(history: true);

      expect(
        history.map((report) => report.id).toList(),
        ['wallet-1'],
      );
      expect(history.single.title, 'Leather Wallet');
      expect(history.single.ownerId, 'samir');
      expect(history.single.isReturned, isTrue);
      expect(history.single.returnedAt, isNotNull);

      // Returning retains the report rather than deleting it.
      expect(store.reports, hasLength(1));
    });

    test('C2.2 Non-creator cannot return another user’s report', () {
      store.add(
        componentReport(
          id: 'wallet-1',
          ownerId: 'samir',
          title: 'Leather Wallet',
        ),
      );

      final result = store.markReturned('wallet-1', 'diego');

      expect(result, isFalse);

      final activeReports = store.search();

      expect(
        activeReports.map((report) => report.id).toList(),
        ['wallet-1'],
      );
      expect(activeReports.single.title, 'Leather Wallet');
      expect(activeReports.single.ownerId, 'samir');
      expect(activeReports.single.isReturned, isFalse);
      expect(activeReports.single.returnedAt, isNull);
      expect(store.search(history: true), isEmpty);
      expect(store.reports, hasLength(1));
    });

    test('C2.3 Repeated return keeps one unchanged history record', () {
      store.add(
        componentReport(
          id: 'wallet-1',
          ownerId: 'samir',
          title: 'Leather Wallet',
        ),
      );

      final firstResult = store.markReturned('wallet-1', 'samir');

      expect(firstResult, isTrue);

      final originalReturnTime = store.reports.single.returnedAt;
      expect(originalReturnTime, isNotNull);

      final secondResult = store.markReturned('wallet-1', 'samir');

      expect(secondResult, isFalse);
      expect(store.search(), isEmpty);
      expect(store.reports, hasLength(1));

      final history = store.search(history: true);

      expect(
        history.map((report) => report.id).toList(),
        ['wallet-1'],
      );
      expect(history.single.returnedAt, originalReturnTime);
      expect(history.single.title, 'Leather Wallet');
    });
  });
}