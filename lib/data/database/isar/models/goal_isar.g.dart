// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGoalIsarCollection on Isar {
  IsarCollection<GoalIsar> get goalIsars => this.collection();
}

const GoalIsarSchema = CollectionSchema(
  name: r'GoalIsar',
  id: 6915484170167033734,
  properties: {
    r'priority': PropertySchema(
      id: 0,
      name: r'priority',
      type: IsarType.byte,
      enumMap: _GoalIsarpriorityEnumValueMap,
    ),
    r'savedAmount': PropertySchema(
      id: 1,
      name: r'savedAmount',
      type: IsarType.double,
    ),
    r'targetAmount': PropertySchema(
      id: 2,
      name: r'targetAmount',
      type: IsarType.double,
    ),
    r'targetDate': PropertySchema(
      id: 3,
      name: r'targetDate',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(
      id: 4,
      name: r'title',
      type: IsarType.string,
    ),
    r'uniqueId': PropertySchema(
      id: 5,
      name: r'uniqueId',
      type: IsarType.string,
    )
  },
  estimateSize: _goalIsarEstimateSize,
  serialize: _goalIsarSerialize,
  deserialize: _goalIsarDeserialize,
  deserializeProp: _goalIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'uniqueId': IndexSchema(
      id: -6275468996282682414,
      name: r'uniqueId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uniqueId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _goalIsarGetId,
  getLinks: _goalIsarGetLinks,
  attach: _goalIsarAttach,
  version: '3.1.0+1',
);

int _goalIsarEstimateSize(
  GoalIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.uniqueId.length * 3;
  return bytesCount;
}

void _goalIsarSerialize(
  GoalIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.priority.index);
  writer.writeDouble(offsets[1], object.savedAmount);
  writer.writeDouble(offsets[2], object.targetAmount);
  writer.writeDateTime(offsets[3], object.targetDate);
  writer.writeString(offsets[4], object.title);
  writer.writeString(offsets[5], object.uniqueId);
}

GoalIsar _goalIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GoalIsar();
  object.id = id;
  object.priority =
      _GoalIsarpriorityValueEnumMap[reader.readByteOrNull(offsets[0])] ??
          GoalPriority.low;
  object.savedAmount = reader.readDouble(offsets[1]);
  object.targetAmount = reader.readDouble(offsets[2]);
  object.targetDate = reader.readDateTime(offsets[3]);
  object.title = reader.readString(offsets[4]);
  object.uniqueId = reader.readString(offsets[5]);
  return object;
}

P _goalIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_GoalIsarpriorityValueEnumMap[reader.readByteOrNull(offset)] ??
          GoalPriority.low) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _GoalIsarpriorityEnumValueMap = {
  'low': 0,
  'medium': 1,
  'high': 2,
};
const _GoalIsarpriorityValueEnumMap = {
  0: GoalPriority.low,
  1: GoalPriority.medium,
  2: GoalPriority.high,
};

Id _goalIsarGetId(GoalIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _goalIsarGetLinks(GoalIsar object) {
  return [];
}

void _goalIsarAttach(IsarCollection<dynamic> col, Id id, GoalIsar object) {
  object.id = id;
}

extension GoalIsarByIndex on IsarCollection<GoalIsar> {
  Future<GoalIsar?> getByUniqueId(String uniqueId) {
    return getByIndex(r'uniqueId', [uniqueId]);
  }

  GoalIsar? getByUniqueIdSync(String uniqueId) {
    return getByIndexSync(r'uniqueId', [uniqueId]);
  }

  Future<bool> deleteByUniqueId(String uniqueId) {
    return deleteByIndex(r'uniqueId', [uniqueId]);
  }

  bool deleteByUniqueIdSync(String uniqueId) {
    return deleteByIndexSync(r'uniqueId', [uniqueId]);
  }

  Future<List<GoalIsar?>> getAllByUniqueId(List<String> uniqueIdValues) {
    final values = uniqueIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'uniqueId', values);
  }

  List<GoalIsar?> getAllByUniqueIdSync(List<String> uniqueIdValues) {
    final values = uniqueIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uniqueId', values);
  }

  Future<int> deleteAllByUniqueId(List<String> uniqueIdValues) {
    final values = uniqueIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uniqueId', values);
  }

  int deleteAllByUniqueIdSync(List<String> uniqueIdValues) {
    final values = uniqueIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uniqueId', values);
  }

  Future<Id> putByUniqueId(GoalIsar object) {
    return putByIndex(r'uniqueId', object);
  }

  Id putByUniqueIdSync(GoalIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'uniqueId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUniqueId(List<GoalIsar> objects) {
    return putAllByIndex(r'uniqueId', objects);
  }

  List<Id> putAllByUniqueIdSync(List<GoalIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uniqueId', objects, saveLinks: saveLinks);
  }
}

extension GoalIsarQueryWhereSort on QueryBuilder<GoalIsar, GoalIsar, QWhere> {
  QueryBuilder<GoalIsar, GoalIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GoalIsarQueryWhere on QueryBuilder<GoalIsar, GoalIsar, QWhereClause> {
  QueryBuilder<GoalIsar, GoalIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterWhereClause> uniqueIdEqualTo(
      String uniqueId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uniqueId',
        value: [uniqueId],
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterWhereClause> uniqueIdNotEqualTo(
      String uniqueId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueId',
              lower: [],
              upper: [uniqueId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueId',
              lower: [uniqueId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueId',
              lower: [uniqueId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueId',
              lower: [],
              upper: [uniqueId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension GoalIsarQueryFilter
    on QueryBuilder<GoalIsar, GoalIsar, QFilterCondition> {
  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> priorityEqualTo(
      GoalPriority value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> priorityGreaterThan(
    GoalPriority value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> priorityLessThan(
    GoalPriority value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> priorityBetween(
    GoalPriority lower,
    GoalPriority upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> savedAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition>
      savedAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'savedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> savedAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'savedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> savedAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'savedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> targetAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition>
      targetAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> targetAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> targetAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> targetDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> targetDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> targetDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> targetDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> uniqueIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> uniqueIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uniqueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> uniqueIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uniqueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> uniqueIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uniqueId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> uniqueIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uniqueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> uniqueIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uniqueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> uniqueIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uniqueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> uniqueIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uniqueId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> uniqueIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueId',
        value: '',
      ));
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterFilterCondition> uniqueIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uniqueId',
        value: '',
      ));
    });
  }
}

extension GoalIsarQueryObject
    on QueryBuilder<GoalIsar, GoalIsar, QFilterCondition> {}

extension GoalIsarQueryLinks
    on QueryBuilder<GoalIsar, GoalIsar, QFilterCondition> {}

extension GoalIsarQuerySortBy on QueryBuilder<GoalIsar, GoalIsar, QSortBy> {
  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> sortBySavedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAmount', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> sortBySavedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAmount', Sort.desc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> sortByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> sortByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.desc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> sortByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> sortByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> sortByUniqueId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueId', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> sortByUniqueIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueId', Sort.desc);
    });
  }
}

extension GoalIsarQuerySortThenBy
    on QueryBuilder<GoalIsar, GoalIsar, QSortThenBy> {
  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenBySavedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAmount', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenBySavedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAmount', Sort.desc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.desc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenByUniqueId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueId', Sort.asc);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QAfterSortBy> thenByUniqueIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueId', Sort.desc);
    });
  }
}

extension GoalIsarQueryWhereDistinct
    on QueryBuilder<GoalIsar, GoalIsar, QDistinct> {
  QueryBuilder<GoalIsar, GoalIsar, QDistinct> distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QDistinct> distinctBySavedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAmount');
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QDistinct> distinctByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetAmount');
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QDistinct> distinctByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetDate');
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GoalIsar, GoalIsar, QDistinct> distinctByUniqueId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uniqueId', caseSensitive: caseSensitive);
    });
  }
}

extension GoalIsarQueryProperty
    on QueryBuilder<GoalIsar, GoalIsar, QQueryProperty> {
  QueryBuilder<GoalIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GoalIsar, GoalPriority, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<GoalIsar, double, QQueryOperations> savedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAmount');
    });
  }

  QueryBuilder<GoalIsar, double, QQueryOperations> targetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetAmount');
    });
  }

  QueryBuilder<GoalIsar, DateTime, QQueryOperations> targetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetDate');
    });
  }

  QueryBuilder<GoalIsar, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<GoalIsar, String, QQueryOperations> uniqueIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uniqueId');
    });
  }
}
