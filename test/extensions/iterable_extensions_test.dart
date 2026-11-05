import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/extensions/iterable_extensions.dart';

void main() {
  group('Iterable Extensions', () {
    test('countWhere returns the number of elements that satisfy the predicate',
        () {
      final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      expect(list.countWhere((e) => e.isEven), 5);
    });

    test('countNotNull returns the number of elements that are not null', () {
      final list = [1, 2, null, 4, 5, 6, 7, 8, 9, 10];
      expect(list.countNotNull(), 9);
    });

    test('asyncMap returns a list after mapping each element asynchronously',
        () async {
      final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final result = await list.asyncMap(mapper: (e) async => e * 2);
      expect(result, [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]);
    });

    test(
        'withoutDuplicate returns a new list after removing duplicates from the original list',
        () {
      final list = [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10
      ];
      expect(list.withoutDuplicate(), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('random returns a random item from the list', () {
      final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      expect(list.random, isA<int>());
    });

    test('random returns null if the list is empty', () {
      final list = <int>[];
      expect(list.random, null);
    });

    group('firstOrNull', () {
      test('firstOrNull returns the first element if the list is not empty',
          () {
        final list = [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ];
        expect(list.firstOrNull(), 1);
      });

      test('firstOrNull returns null if the list is empty', () {
        final list = <int>[];
        expect(list.firstOrNull(), null);
      });
    });

    group('firstOr', () {
      test('firstOr returns the first element if the list is not empty', () {
        final list = [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ];
        expect(list.firstOr(0), 1);
      });

      test('firstOr returns the default value if the list is empty', () {
        final list = <int>[];
        expect(list.firstOr(0), 0);
      });
    });

    group('atOrNull', () {
      test(
          'atOrNull returns the element at the given index if the index is valid',
          () {
        final list = [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ];
        expect(list.atOrNull(3), 4);
      });

      test('atOrNull returns null if the index is out of bounds of the list',
          () {
        final list = [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ];
        expect(list.atOrNull(10), null);
      });
    });

    group('atOr', () {
      test('atOr returns the element at the given index if the index is valid',
          () {
        final list = [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ];
        expect(list.atOr(3, 0), 4);
      });

      test(
          'atOr returns the default value if the index is out of bounds of the list',
          () {
        final list = [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ];
        expect(list.atOr(10, 0), 0);
      });
    });

    group('isIndexValid', () {
      test('isIndexValid returns true if the index is valid', () {
        final list = [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ];
        expect(list.isIndexValid(3), true);
      });

      test(
          'isIndexValid returns false if the index is out of bounds of the list',
          () {
        final list = [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ];
        expect(list.isIndexValid(10), false);
      });
    });

    group('firstWhereOrNull', () {
      test(
          'firstWhereOrNull returns the first element that satisfies the predicate',
          () {
        final list = [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ];
        expect(list.firstWhereOrNull((e) => e.isEven), 2);
      });

      test(
          'firstWhereOrNull returns null if no element satisfies the predicate',
          () {
        final list = [
          1,
          3,
          5,
          7,
        ];
        expect(list.firstWhereOrNull((e) => e.isEven), null);
      });
    });

    group('lastWhereOrNull', () {
      test(
          'lastWhereOrNull returns the last element that satisfies the predicate',
          () {
        final list = [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ];
        expect(list.lastWhereOrNull((e) => e.isEven), 8);
      });

      test('lastWhereOrNull returns null if no element satisfies the predicate',
          () {
        final list = [
          1,
          3,
          5,
          7,
        ];
        expect(list.lastWhereOrNull((e) => e.isEven), null);
      });
    });

    group('firstWhereOr', () {
      test(
          'firstWhereOr returns the first element that satisfies the predicate',
          () {
        final list = [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ];
        expect(list.firstWhereOr((e) => e.isEven, 0), 2);
      });

      test(
          'firstWhereOr returns the default value if no element satisfies the predicate',
          () {
        final list = [
          1,
          3,
          5,
          7,
        ];
        expect(list.firstWhereOr((e) => e.isEven, 0), 0);
      });
    });

    group('lastWhereOr', () {
      test('lastWhereOr returns the last element that satisfies the predicate',
          () {
        final list = [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ];
        expect(list.lastWhereOr((e) => e.isEven, 0), 8);
      });

      test(
          'lastWhereOr returns the default value if no element satisfies the predicate',
          () {
        final list = [
          1,
          3,
          5,
          7,
        ];
        expect(list.lastWhereOr((e) => e.isEven, 0), 0);
      });
    });

    test(
        'mapWithIndex returns a new list after mapping each element with it\'s index',
        () {
      final list = [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
      ];
      final result = list.mapWithIndex((index, element) => '$index: $element');
      expect(result,
          ['0: 1', '1: 2', '2: 3', '3: 4', '4: 5', '5: 6', '6: 7', '7: 8']);
    });

    test(
        'flatten returns a new list after flattening the original list of lists',
        () {
      final list = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
      ];
      expect(list.flatten(), [1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });

    test(
        'flatMap returns a new list after flattening the original list of lists and then mapping each element',
        () {
      final list = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
      ];
      final result = list.flatMap(mapper: (e) => e * 2);
      expect(result, [2, 4, 6, 8, 10, 12, 14, 16, 18]);
    });

    test(
        'asyncFlatMap returns a new list after flattening the original list of lists and then mapping each element asynchronously',
        () async {
      final list = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
      ];
      final result = await list.flatMapAsync(mapper: (e) async => e * 2);
      expect(result, [2, 4, 6, 8, 10, 12, 14, 16, 18]);
    });
  });

  group('lastOr and chunked', () {
    test('lastOrNull and lastOr', () {
      expect([1, 2, 3].lastOrNull(), 3);
      expect(<int>[].lastOrNull(), isNull);
      expect([1, 2, 3].lastOr(9), 3);
      expect(<int>[].lastOr(9), 9);
    });

    test('mapWithIndex passes the index', () {
      expect(['a', 'b'].mapWithIndex((i, e) => '$i$e'), ['0a', '1b']);
    });

    test('chunked splits into lists of the given size', () {
      expect([1, 2, 3, 4, 5].chunked(2), [
        [1, 2],
        [3, 4],
        [5],
      ]);
      expect([1, 2].chunked(5), [
        [1, 2],
      ]);
      expect(<int>[].chunked(3), isEmpty);
      expect(() => [1].chunked(0), throwsArgumentError);
      expect(() => [1].chunked(-1), throwsArgumentError);
    });
  });

  group('groupBy and sorting', () {
    test('groupBy groups elements by key', () {
      expect([1, 2, 3, 4, 5].groupBy((e) => e.isEven), {
        false: [1, 3, 5],
        true: [2, 4],
      });
      expect(<int>[].groupBy((e) => e), isEmpty);
    });

    test('sortedBy and sortedByDescending do not change the source', () {
      final words = ['pear', 'fig', 'banana'];
      expect(words.sortedBy((w) => w.length), ['fig', 'pear', 'banana']);
      expect(words.sortedByDescending((w) => w.length), [
        'banana',
        'pear',
        'fig',
      ]);
      expect(words, ['pear', 'fig', 'banana']);
    });
  });

  group('nested iterables', () {
    final nested = [
      [1, 2],
      [3],
      <int>[],
    ];

    test('flatten', () {
      expect(nested.flatten(), [1, 2, 3]);
    });

    test('flatMap maps the flattened elements', () {
      expect(nested.flatMap(mapper: (e) => e * 10).toList(), [10, 20, 30]);
    });

    test('flatMapAsync and asyncFlatMap map asynchronously', () async {
      expect(await nested.flatMapAsync(mapper: (e) async => e + 1), [2, 3, 4]);
      // ignore: deprecated_member_use_from_same_package
      expect(await nested.asyncFlatMap((e) async => e + 1), [2, 3, 4]);
    });
  });

  group('number iterables', () {
    test('sum', () {
      expect([1, 2, 3].sum, 6);
      expect([1.5, 2.5].sum, 4);
      expect(<int>[].sum, 0);
    });

    test('average', () {
      expect([1, 2, 3, 4].average, 2.5);
      expect(<int>[].average, 0);
    });
  });
}
