// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Goal _$GoalFromJson(Map<String, dynamic> json) {
  return _Goal.fromJson(json);
}

/// @nodoc
mixin _$Goal {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get targetAmount => throw _privateConstructorUsedError;
  double get savedAmount => throw _privateConstructorUsedError;
  DateTime get targetDate => throw _privateConstructorUsedError;
  GoalPriority get priority =>
      throw _privateConstructorUsedError; // UI Customization
  String get iconEmoji => throw _privateConstructorUsedError;
  String get themeColor => throw _privateConstructorUsedError; // Vault logic
  String? get linkedAccountId => throw _privateConstructorUsedError;
  GoalReminderInterval get reminderInterval =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GoalCopyWith<Goal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalCopyWith<$Res> {
  factory $GoalCopyWith(Goal value, $Res Function(Goal) then) =
      _$GoalCopyWithImpl<$Res, Goal>;
  @useResult
  $Res call(
      {String id,
      String title,
      double targetAmount,
      double savedAmount,
      DateTime targetDate,
      GoalPriority priority,
      String iconEmoji,
      String themeColor,
      String? linkedAccountId,
      GoalReminderInterval reminderInterval});
}

/// @nodoc
class _$GoalCopyWithImpl<$Res, $Val extends Goal>
    implements $GoalCopyWith<$Res> {
  _$GoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? targetAmount = null,
    Object? savedAmount = null,
    Object? targetDate = null,
    Object? priority = null,
    Object? iconEmoji = null,
    Object? themeColor = null,
    Object? linkedAccountId = freezed,
    Object? reminderInterval = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as double,
      savedAmount: null == savedAmount
          ? _value.savedAmount
          : savedAmount // ignore: cast_nullable_to_non_nullable
              as double,
      targetDate: null == targetDate
          ? _value.targetDate
          : targetDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as GoalPriority,
      iconEmoji: null == iconEmoji
          ? _value.iconEmoji
          : iconEmoji // ignore: cast_nullable_to_non_nullable
              as String,
      themeColor: null == themeColor
          ? _value.themeColor
          : themeColor // ignore: cast_nullable_to_non_nullable
              as String,
      linkedAccountId: freezed == linkedAccountId
          ? _value.linkedAccountId
          : linkedAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      reminderInterval: null == reminderInterval
          ? _value.reminderInterval
          : reminderInterval // ignore: cast_nullable_to_non_nullable
              as GoalReminderInterval,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoalImplCopyWith<$Res> implements $GoalCopyWith<$Res> {
  factory _$$GoalImplCopyWith(
          _$GoalImpl value, $Res Function(_$GoalImpl) then) =
      __$$GoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      double targetAmount,
      double savedAmount,
      DateTime targetDate,
      GoalPriority priority,
      String iconEmoji,
      String themeColor,
      String? linkedAccountId,
      GoalReminderInterval reminderInterval});
}

/// @nodoc
class __$$GoalImplCopyWithImpl<$Res>
    extends _$GoalCopyWithImpl<$Res, _$GoalImpl>
    implements _$$GoalImplCopyWith<$Res> {
  __$$GoalImplCopyWithImpl(_$GoalImpl _value, $Res Function(_$GoalImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? targetAmount = null,
    Object? savedAmount = null,
    Object? targetDate = null,
    Object? priority = null,
    Object? iconEmoji = null,
    Object? themeColor = null,
    Object? linkedAccountId = freezed,
    Object? reminderInterval = null,
  }) {
    return _then(_$GoalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as double,
      savedAmount: null == savedAmount
          ? _value.savedAmount
          : savedAmount // ignore: cast_nullable_to_non_nullable
              as double,
      targetDate: null == targetDate
          ? _value.targetDate
          : targetDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as GoalPriority,
      iconEmoji: null == iconEmoji
          ? _value.iconEmoji
          : iconEmoji // ignore: cast_nullable_to_non_nullable
              as String,
      themeColor: null == themeColor
          ? _value.themeColor
          : themeColor // ignore: cast_nullable_to_non_nullable
              as String,
      linkedAccountId: freezed == linkedAccountId
          ? _value.linkedAccountId
          : linkedAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      reminderInterval: null == reminderInterval
          ? _value.reminderInterval
          : reminderInterval // ignore: cast_nullable_to_non_nullable
              as GoalReminderInterval,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalImpl implements _Goal {
  const _$GoalImpl(
      {required this.id,
      required this.title,
      required this.targetAmount,
      this.savedAmount = 0.0,
      required this.targetDate,
      this.priority = GoalPriority.medium,
      this.iconEmoji = '🎯',
      this.themeColor = '#FFD600',
      this.linkedAccountId,
      this.reminderInterval = GoalReminderInterval.none});

  factory _$GoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final double targetAmount;
  @override
  @JsonKey()
  final double savedAmount;
  @override
  final DateTime targetDate;
  @override
  @JsonKey()
  final GoalPriority priority;
// UI Customization
  @override
  @JsonKey()
  final String iconEmoji;
  @override
  @JsonKey()
  final String themeColor;
// Vault logic
  @override
  final String? linkedAccountId;
  @override
  @JsonKey()
  final GoalReminderInterval reminderInterval;

  @override
  String toString() {
    return 'Goal(id: $id, title: $title, targetAmount: $targetAmount, savedAmount: $savedAmount, targetDate: $targetDate, priority: $priority, iconEmoji: $iconEmoji, themeColor: $themeColor, linkedAccountId: $linkedAccountId, reminderInterval: $reminderInterval)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.targetAmount, targetAmount) ||
                other.targetAmount == targetAmount) &&
            (identical(other.savedAmount, savedAmount) ||
                other.savedAmount == savedAmount) &&
            (identical(other.targetDate, targetDate) ||
                other.targetDate == targetDate) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.iconEmoji, iconEmoji) ||
                other.iconEmoji == iconEmoji) &&
            (identical(other.themeColor, themeColor) ||
                other.themeColor == themeColor) &&
            (identical(other.linkedAccountId, linkedAccountId) ||
                other.linkedAccountId == linkedAccountId) &&
            (identical(other.reminderInterval, reminderInterval) ||
                other.reminderInterval == reminderInterval));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      targetAmount,
      savedAmount,
      targetDate,
      priority,
      iconEmoji,
      themeColor,
      linkedAccountId,
      reminderInterval);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalImplCopyWith<_$GoalImpl> get copyWith =>
      __$$GoalImplCopyWithImpl<_$GoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalImplToJson(
      this,
    );
  }
}

abstract class _Goal implements Goal {
  const factory _Goal(
      {required final String id,
      required final String title,
      required final double targetAmount,
      final double savedAmount,
      required final DateTime targetDate,
      final GoalPriority priority,
      final String iconEmoji,
      final String themeColor,
      final String? linkedAccountId,
      final GoalReminderInterval reminderInterval}) = _$GoalImpl;

  factory _Goal.fromJson(Map<String, dynamic> json) = _$GoalImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  double get targetAmount;
  @override
  double get savedAmount;
  @override
  DateTime get targetDate;
  @override
  GoalPriority get priority;
  @override // UI Customization
  String get iconEmoji;
  @override
  String get themeColor;
  @override // Vault logic
  String? get linkedAccountId;
  @override
  GoalReminderInterval get reminderInterval;
  @override
  @JsonKey(ignore: true)
  _$$GoalImplCopyWith<_$GoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
