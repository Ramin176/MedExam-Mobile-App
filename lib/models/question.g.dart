// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionAdapter extends TypeAdapter<Question> {
  @override
  final int typeId = 0;

  @override
  Question read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Question(
      id: fields[0] as int,
      questionText: fields[1] as String,
      image: fields[2] as String?,
      optionA: fields[3] as String,
      optionB: fields[4] as String,
      optionC: fields[5] as String,
      optionD: fields[6] as String,
      correctAnswer: fields[7] as String,
      type: fields[8] as String,
      explanation: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Question obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.questionText)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.optionA)
      ..writeByte(4)
      ..write(obj.optionB)
      ..writeByte(5)
      ..write(obj.optionC)
      ..writeByte(6)
      ..write(obj.optionD)
      ..writeByte(7)
      ..write(obj.correctAnswer)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.explanation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
