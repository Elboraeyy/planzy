// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) {
  return _Subscription.fromJson(json);
}

/// @nodoc
mixin _$Subscription {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  SubscriptionCycle get cycle => throw _privateConstructorUsedError;
  SubscriptionCategory get category => throw _privateConstructorUsedError;
  DateTime get nextRenewalDate => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError; // Reminder
  int get reminderDaysBefore =>
      throw _privateConstructorUsedError; // Auto-deduct
  bool get autoDeduct => throw _privateConstructorUsedError;
  String? get linkedAccountId => throw _privateConstructorUsedError; // Notes
  String? get notes => throw _privateConstructorUsedError; // Visual
  String? get iconEmoji => throw _privateConstructorUsedError;
  String? get colorHex => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubscriptionCopyWith<Subscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionCopyWith<$Res> {
  factory $SubscriptionCopyWith(
          Subscription value, $Res Function(Subscription) then) =
      _$SubscriptionCopyWithImpl<$Res, Subscription>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      double amount,
      String currency,
      SubscriptionCycle cycle,
      SubscriptionCategory category,
      DateTime nextRenewalDate,
      bool isActive,
      int reminderDaysBefore,
      bool autoDeduct,
      String? linkedAccountId,
      String? notes,
      String? iconEmoji,
      String? colorHex,
      DateTime createdAt});
}

/// @nodoc
class _$SubscriptionCopyWithImpl<$Res, $Val extends Subscription>
    implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? amount = null,
    Object? currency = null,
    Object? cycle = null,
    Object? category = null,
    Object? nextRenewalDate = null,
    Object? isActive = null,
    Object? reminderDaysBefore = null,
    Object? autoDeduct = null,
    Object? linkedAccountId = freezed,
    Object? notes = freezed,
    Object? iconEmoji = freezed,
    Object? colorHex = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      cycle: null == cycle
          ? _value.cycle
          : cycle // ignore: cast_nullable_to_non_nullable
              as SubscriptionCycle,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as SubscriptionCategory,
      nextRenewalDate: null == nextRenewalDate
          ? _value.nextRenewalDate
          : nextRenewalDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderDaysBefore: null == reminderDaysBefore
          ? _value.reminderDaysBefore
          : reminderDaysBefore // ignore: cast_nullable_to_non_nullable
              as int,
      autoDeduct: null == autoDeduct
          ? _value.autoDeduct
          : autoDeduct // ignore: cast_nullable_to_non_nullable
              as bool,
      linkedAccountId: freezed == linkedAccountId
          ? _value.linkedAccountId
          : linkedAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      iconEmoji: freezed == iconEmoji
          ? _value.iconEmoji
          : iconEmoji // ignore: cast_nullable_to_non_nullable
              as String?,
      colorHex: freezed == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionImplCopyWith<$Res>
    implements $SubscriptionCopyWith<$Res> {
  factory _$$SubscriptionImplCopyWith(
          _$SubscriptionImpl value, $Res Function(_$SubscriptionImpl) then) =
      __$$SubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      double amount,
      String currency,
      SubscriptionCycle cycle,
      SubscriptionCategory category,
      DateTime nextRenewalDate,
      bool isActive,
      int reminderDaysBefore,
      bool autoDeduct,
      String? linkedAccountId,
      String? notes,
      String? iconEmoji,
      String? colorHex,
      DateTime createdAt});
}

/// @nodoc
class __$$SubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionCopyWithImpl<$Res, _$SubscriptionImpl>
    implements _$$SubscriptionImplCopyWith<$Res> {
  __$$SubscriptionImplCopyWithImpl(
      _$SubscriptionImpl _value, $Res Function(_$SubscriptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? amount = null,
    Object? currency = null,
    Object? cycle = null,
    Object? category = null,
    Object? nextRenewalDate = null,
    Object? isActive = null,
    Object? reminderDaysBefore = null,
    Object? autoDeduct = null,
    Object? linkedAccountId = freezed,
    Object? notes = freezed,
    Object? iconEmoji = freezed,
    Object? colorHex = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$SubscriptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      cycle: null == cycle
          ? _value.cycle
          : cycle // ignore: cast_nullable_to_non_nullable
              as SubscriptionCycle,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as SubscriptionCategory,
      nextRenewalDate: null == nextRenewalDate
          ? _value.nextRenewalDate
          : nextRenewalDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderDaysBefore: null == reminderDaysBefore
          ? _value.reminderDaysBefore
          : reminderDaysBefore // ignore: cast_nullable_to_non_nullable
              as int,
      autoDeduct: null == autoDeduct
          ? _value.autoDeduct
          : autoDeduct // ignore: cast_nullable_to_non_nullable
              as bool,
      linkedAccountId: freezed == linkedAccountId
          ? _value.linkedAccountId
          : linkedAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      iconEmoji: freezed == iconEmoji
          ? _value.iconEmoji
          : iconEmoji // ignore: cast_nullable_to_non_nullable
              as String?,
      colorHex: freezed == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionImpl implements _Subscription {
  const _$SubscriptionImpl(
      {required this.id,
      required this.userId,
      required this.name,
      required this.amount,
      required this.currency,
      required this.cycle,
      required this.category,
      required this.nextRenewalDate,
      this.isActive = true,
      this.reminderDaysBefore = 3,
      this.autoDeduct = false,
      this.linkedAccountId,
      this.notes,
      this.iconEmoji,
      this.colorHex,
      required this.createdAt});

  factory _$SubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final double amount;
  @override
  final String currency;
  @override
  final SubscriptionCycle cycle;
  @override
  final SubscriptionCategory category;
  @override
  final DateTime nextRenewalDate;
  @override
  @JsonKey()
  final bool isActive;
// Reminder
  @override
  @JsonKey()
  final int reminderDaysBefore;
// Auto-deduct
  @override
  @JsonKey()
  final bool autoDeduct;
  @override
  final String? linkedAccountId;
// Notes
  @override
  final String? notes;
// Visual
  @override
  final String? iconEmoji;
  @override
  final String? colorHex;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Subscription(id: $id, userId: $userId, name: $name, amount: $amount, currency: $currency, cycle: $cycle, category: $category, nextRenewalDate: $nextRenewalDate, isActive: $isActive, reminderDaysBefore: $reminderDaysBefore, autoDeduct: $autoDeduct, linkedAccountId: $linkedAccountId, notes: $notes, iconEmoji: $iconEmoji, colorHex: $colorHex, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.cycle, cycle) || other.cycle == cycle) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.nextRenewalDate, nextRenewalDate) ||
                other.nextRenewalDate == nextRenewalDate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.reminderDaysBefore, reminderDaysBefore) ||
                other.reminderDaysBefore == reminderDaysBefore) &&
            (identical(other.autoDeduct, autoDeduct) ||
                other.autoDeduct == autoDeduct) &&
            (identical(other.linkedAccountId, linkedAccountId) ||
                other.linkedAccountId == linkedAccountId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.iconEmoji, iconEmoji) ||
                other.iconEmoji == iconEmoji) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      amount,
      currency,
      cycle,
      category,
      nextRenewalDate,
      isActive,
      reminderDaysBefore,
      autoDeduct,
      linkedAccountId,
      notes,
      iconEmoji,
      colorHex,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      __$$SubscriptionImplCopyWithImpl<_$SubscriptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionImplToJson(
      this,
    );
  }
}

abstract class _Subscription implements Subscription {
  const factory _Subscription(
      {required final String id,
      required final String userId,
      required final String name,
      required final double amount,
      required final String currency,
      required final SubscriptionCycle cycle,
      required final SubscriptionCategory category,
      required final DateTime nextRenewalDate,
      final bool isActive,
      final int reminderDaysBefore,
      final bool autoDeduct,
      final String? linkedAccountId,
      final String? notes,
      final String? iconEmoji,
      final String? colorHex,
      required final DateTime createdAt}) = _$SubscriptionImpl;

  factory _Subscription.fromJson(Map<String, dynamic> json) =
      _$SubscriptionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  double get amount;
  @override
  String get currency;
  @override
  SubscriptionCycle get cycle;
  @override
  SubscriptionCategory get category;
  @override
  DateTime get nextRenewalDate;
  @override
  bool get isActive;
  @override // Reminder
  int get reminderDaysBefore;
  @override // Auto-deduct
  bool get autoDeduct;
  @override
  String? get linkedAccountId;
  @override // Notes
  String? get notes;
  @override // Visual
  String? get iconEmoji;
  @override
  String? get colorHex;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
