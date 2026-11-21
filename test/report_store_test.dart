import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:penguin_search/report.dart';

void main() {
  ItemReport sample({Uint8List? photo}) => ItemReport(
    id: 'test', ownerId: demoUserId, title: 'Blue notebook',
    description: 'Math notes', location: 'Library', category: 'Books',
    kind: ReportKind.found, occurredAt: DateTime(2026, 10, 16),
    createdAt: DateTime(2026, 10, 16), photo: photo);

  test('return archives without losing the original report', () {
    final store = ReportStore(seed: false);
    addTearDown(store.dispose);
    store.add(sample(photo: Uint8List.fromList([1])));
    expect(store.markReturned('test', demoUserId), isTrue);
    expect(store.search(), isEmpty);
    expect(store.search(history: true).single.title, 'Blue notebook');
    expect(store.reports.length, 1);
    expect(store.markReturned('test', demoUserId), isFalse);
  });
  test('unrelated users cannot archive reports', () {
    final store = ReportStore(seed: false);
    addTearDown(store.dispose);
    store.add(sample(photo: Uint8List.fromList([1])));
    expect(store.markReturned('test', 'stranger'), isFalse);
    expect(store.search().length, 1);
  });
  test('new reports require a photo', () {
    final store = ReportStore(seed: false);
    addTearDown(store.dispose);
    expect(() => store.add(sample()), throwsArgumentError);
    expect(store.reports, isEmpty);
  });
  test('filters combine, ignore case, and match item date', () {
    final store = ReportStore(seed: false);
    addTearDown(store.dispose);
    store.add(sample(photo: Uint8List.fromList([1])));
    expect(store.search(query: ' MATH ', category: 'Books', location: 'LIB',
      kind: ReportKind.found, date: DateTime(2026, 10, 16)).length, 1);
    expect(store.search(kind: ReportKind.lost), isEmpty);
    expect(store.search(date: DateTime(2026, 10, 15)), isEmpty);
  });
}
