// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadedBaseItemAdapter extends TypeAdapter<DownloadedBaseItem> {
  @override
  final int typeId = 0;

  @override
  DownloadedBaseItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadedBaseItem(
      id: fields[0] as String,
      length: fields[5] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      posterPath: fields[3] as String,
      videoPath: fields[4] as String,
      taskId: fields[7] as String,
      isAdult: fields[8] as bool,
      status: fields[6] as String,
      validTill: fields[10] as int,
    )..progress = fields[9] as double;
  }

  @override
  void write(BinaryWriter writer, DownloadedBaseItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.posterPath)
      ..writeByte(4)
      ..write(obj.videoPath)
      ..writeByte(5)
      ..write(obj.length)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.taskId)
      ..writeByte(8)
      ..write(obj.isAdult)
      ..writeByte(9)
      ..write(obj.progress)
      ..writeByte(10)
      ..write(obj.validTill);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadedBaseItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
