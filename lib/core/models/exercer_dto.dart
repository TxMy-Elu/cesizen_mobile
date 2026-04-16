import 'package:cesizen_mobile/core/models/exercice_dto.dart';
import 'package:cesizen_mobile/core/models/user_dto.dart';

class ExercerDto {
  const ExercerDto({
    required this.idExercer,
    required this.exercice,
    required this.completedAt,
    this.user,
  });

  final int idExercer;
  final UserDto? user;
  final ExerciceDto exercice;
  final DateTime? completedAt;

  factory ExercerDto.fromJson(Map<String, dynamic> json) {
    return ExercerDto(
      idExercer: _asInt(json['idExercer']) ?? 0,
      user: json['user'] is Map<String, dynamic>
          ? UserDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      exercice: ExerciceDto.fromJson(
        (json['exercice'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      ),
      completedAt: _asDateTime(json['completedAt']),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _asDateTime(Object? value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text)?.toUtc();
  }
}