// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gpt_commit_messages.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Arguments {
  bool get commitAtEnd => throw _privateConstructorUsedError;
  int get numMessages => throw _privateConstructorUsedError;
  String get openAiApiKey => throw _privateConstructorUsedError;
  bool get signOff => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ArgumentsCopyWith<Arguments> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArgumentsCopyWith<$Res> {
  factory $ArgumentsCopyWith(Arguments value, $Res Function(Arguments) then) =
      _$ArgumentsCopyWithImpl<$Res, Arguments>;
  @useResult
  $Res call(
      {bool commitAtEnd, int numMessages, String openAiApiKey, bool signOff});
}

/// @nodoc
class _$ArgumentsCopyWithImpl<$Res, $Val extends Arguments>
    implements $ArgumentsCopyWith<$Res> {
  _$ArgumentsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? commitAtEnd = null,
    Object? numMessages = null,
    Object? openAiApiKey = null,
    Object? signOff = null,
  }) {
    return _then(_value.copyWith(
      commitAtEnd: null == commitAtEnd
          ? _value.commitAtEnd
          : commitAtEnd // ignore: cast_nullable_to_non_nullable
              as bool,
      numMessages: null == numMessages
          ? _value.numMessages
          : numMessages // ignore: cast_nullable_to_non_nullable
              as int,
      openAiApiKey: null == openAiApiKey
          ? _value.openAiApiKey
          : openAiApiKey // ignore: cast_nullable_to_non_nullable
              as String,
      signOff: null == signOff
          ? _value.signOff
          : signOff // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ArgumentsCopyWith<$Res> implements $ArgumentsCopyWith<$Res> {
  factory _$$_ArgumentsCopyWith(
          _$_Arguments value, $Res Function(_$_Arguments) then) =
      __$$_ArgumentsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool commitAtEnd, int numMessages, String openAiApiKey, bool signOff});
}

/// @nodoc
class __$$_ArgumentsCopyWithImpl<$Res>
    extends _$ArgumentsCopyWithImpl<$Res, _$_Arguments>
    implements _$$_ArgumentsCopyWith<$Res> {
  __$$_ArgumentsCopyWithImpl(
      _$_Arguments _value, $Res Function(_$_Arguments) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? commitAtEnd = null,
    Object? numMessages = null,
    Object? openAiApiKey = null,
    Object? signOff = null,
  }) {
    return _then(_$_Arguments(
      commitAtEnd: null == commitAtEnd
          ? _value.commitAtEnd
          : commitAtEnd // ignore: cast_nullable_to_non_nullable
              as bool,
      numMessages: null == numMessages
          ? _value.numMessages
          : numMessages // ignore: cast_nullable_to_non_nullable
              as int,
      openAiApiKey: null == openAiApiKey
          ? _value.openAiApiKey
          : openAiApiKey // ignore: cast_nullable_to_non_nullable
              as String,
      signOff: null == signOff
          ? _value.signOff
          : signOff // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_Arguments implements _Arguments {
  const _$_Arguments(
      {required this.commitAtEnd,
      required this.numMessages,
      required this.openAiApiKey,
      required this.signOff});

  @override
  final bool commitAtEnd;
  @override
  final int numMessages;
  @override
  final String openAiApiKey;
  @override
  final bool signOff;

  @override
  String toString() {
    return 'Arguments(commitAtEnd: $commitAtEnd, numMessages: $numMessages, openAiApiKey: $openAiApiKey, signOff: $signOff)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Arguments &&
            (identical(other.commitAtEnd, commitAtEnd) ||
                other.commitAtEnd == commitAtEnd) &&
            (identical(other.numMessages, numMessages) ||
                other.numMessages == numMessages) &&
            (identical(other.openAiApiKey, openAiApiKey) ||
                other.openAiApiKey == openAiApiKey) &&
            (identical(other.signOff, signOff) || other.signOff == signOff));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, commitAtEnd, numMessages, openAiApiKey, signOff);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ArgumentsCopyWith<_$_Arguments> get copyWith =>
      __$$_ArgumentsCopyWithImpl<_$_Arguments>(this, _$identity);
}

abstract class _Arguments implements Arguments {
  const factory _Arguments(
      {required final bool commitAtEnd,
      required final int numMessages,
      required final String openAiApiKey,
      required final bool signOff}) = _$_Arguments;

  @override
  bool get commitAtEnd;
  @override
  int get numMessages;
  @override
  String get openAiApiKey;
  @override
  bool get signOff;
  @override
  @JsonKey(ignore: true)
  _$$_ArgumentsCopyWith<_$_Arguments> get copyWith =>
      throw _privateConstructorUsedError;
}
