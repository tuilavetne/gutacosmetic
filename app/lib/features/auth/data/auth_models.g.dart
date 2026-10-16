// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthResult _$AuthResultFromJson(Map<String, dynamic> json) => _AuthResult(
  user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
  token: json['token'] as String,
);

Map<String, dynamic> _$AuthResultToJson(_AuthResult instance) =>
    <String, dynamic>{'user': instance.user.toJson(), 'token': instance.token};

_OtpChallenge _$OtpChallengeFromJson(Map<String, dynamic> json) =>
    _OtpChallenge(
      challengeId: json['challengeId'] as String,
      channel: json['channel'] as String? ?? 'EMAIL',
      deliveryTarget: json['deliveryTarget'] as String? ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 300,
      developmentOtp: json['developmentOtp'] as String?,
    );

Map<String, dynamic> _$OtpChallengeToJson(_OtpChallenge instance) =>
    <String, dynamic>{
      'challengeId': instance.challengeId,
      'channel': instance.channel,
      'deliveryTarget': instance.deliveryTarget,
      'expiresIn': instance.expiresIn,
      'developmentOtp': ?instance.developmentOtp,
    };

_PasswordResetToken _$PasswordResetTokenFromJson(Map<String, dynamic> json) =>
    _PasswordResetToken(
      resetToken: json['resetToken'] as String,
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 600,
    );

Map<String, dynamic> _$PasswordResetTokenToJson(_PasswordResetToken instance) =>
    <String, dynamic>{
      'resetToken': instance.resetToken,
      'expiresIn': instance.expiresIn,
    };
