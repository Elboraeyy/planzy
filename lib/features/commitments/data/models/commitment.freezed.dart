// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commitment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Commitment _$CommitmentFromJson(Map<String, dynamic> json) {
  return _Commitment.fromJson(json);
}

/// @nodoc
mixin _$Commitment {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  RepeatType get repeatType => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  bool get reminderEnabled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommitmentCopyWith<Commitment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommitmentCopyWith<$Res> {
  factory $CommitmentCopyWith(
          Commitment value, $Res Function(Commitment) then) =
      _$CommitmentCopyWithImpl<$Res, Commitment>;
  @useResult
  $Res call(
      {String id,
      String title,
      double amount,
      RepeatType repeatType,
      DateTime startDate,
      DateTime? endDate,
      String category,
      bool reminderEnabled});
}

/// @nodoc
class _$CommitmentCopyWithImpl<$Res, $Val extends Commitment>
    implements $CommitmentCopyWith<$Res> {
  _$CommitmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = null,
    Object? repeatType = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? category = null,
    Object? reminderEnabled = null,
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
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      repeatType: null == repeatType
          ? _value.repeatType
          : repeatType // ignore: cast_nullable_to_non_nullable
              as RepeatType,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      reminderEnabled: null == reminderEnabled
          ? _value.reminderEnabled
          : reminderEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommitmentImplCopyWith<$Res>
    implements $CommitmentCopyWith<$Res> {
  factory _$$CommitmentImplCopyWith(
          _$CommitmentImpl value, $Res Function(_$CommitmentImpl) then) =
      __$$CommitmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      double amount,
      RepeatType repeatType,
      DateTime startDate,
      DateTime? endDate,
      String category,
      bool reminderEnabled});
}

/// @nodoc
class __$$CommitmentImplCopyWithImpl<$Res>
    extends _$CommitmentCopyWithImpl<$Res, _$CommitmentImpl>
    implements _$$CommitmentImplCopyWith<$Res> {
  __$$CommitmentImplCopyWithImpl(
      _$CommitmentImpl _value, $Res Function(_$CommitmentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = null,
    Object? repeatType = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? category = null,
    Object? reminderEnabled = null,
  }) {
    return _then(_$CommitmentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      repeatType: null == repeatType
          ? _value.repeatType
          : repeatType // ignore: cast_nullable_to_non_nullable
              as RepeatType,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      reminderEnabled: null == reminderEnabled
          ? _value.reminderEnabled
          : reminderEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommitmentImpl implements _Commitment {
  const _$CommitmentImpl(
      {required this.id,
      required this.title,
      required this.amount,
      required this.repeatType,
      required this.startDate,
      this.endDate,
      required this.category,
      this.reminderEnabled = true});

  factory _$CommitmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommitmentImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final double amount;
  @override
  final RepeatType repeatType;
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  final String category;
  @override
  @JsonKey()
  final bool reminderEnabled;

  @override
  String toString() {
    return 'Commitment(id: $id, title: $title, amount: $amount, repeatType: $repeatType, startDate: $startDate, endDate: $endDate, category: $category, reminderEnabled: $reminderEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommitmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.repeatType, repeatType) ||
                other.repeatType == repeatType) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.reminderEnabled, reminderEnabled) ||
                other.reminderEnabled == reminderEnabled));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, amount, repeatType,
      startDate, endDate, category, reminderEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommitmentImplCopyWith<_$CommitmentImpl> get copyWith =>
      __$$CommitmentImplCopyWithImpl<_$CommitmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommitmentImplToJson(
      this,
    );
  }
}

abstract class _Commitment implements Commitment {
  const factory _Commitment(
      {required final String id,
      required final String title,
      required final double amount,
      required final RepeatType repeatType,
      required final DateTime startDate,
      final DateTime? endDate,
      required final String category,
      final bool reminderEnabled}) = _$CommitmentImpl;

  factory _Commitment.fromJson(Map<String, dynamic> json) =
      _$CommitmentImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  double get amount;
  @override
  RepeatType get repeatType;
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;
  @override
  String get category;
  @override
  bool get reminderEnabled;
  @override
  @JsonKey(ignore: true)
  _$$CommitmentImplCopyWith<_$CommitmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
