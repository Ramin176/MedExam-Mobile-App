// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecture.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LectureAdapter extends TypeAdapter<Lecture> {
  @override
  final int typeId = 5;

  @override
  Lecture read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lecture(
      id: fields[0] as int,
      title: fields[1] as String,
      type: fields[2] as String,
      filePath: fields[3] as String,
      description: fields[4] as String?,
      isFree: fields[5] as bool,
      localPath: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Lecture obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.isFree)
      ..writeByte(6)
      ..write(obj.localPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LectureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
