// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Manga.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MangaAdapter extends TypeAdapter<Manga> {
  @override
  final int typeId = 0;

  @override
  Manga read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Manga(
      extensionSource: fields[0] as String,
      mangaName: fields[2] as String,
      mangaCover: fields[1] as String,
      mangaLink: fields[3] as String,
    )
      ..authorName = fields[4] as String
      ..mangaStudio = fields[5] as String
      ..status = fields[6] as String
      ..chapters = (fields[7] as List).cast<Chapter>()
      ..synopsis = fields[8] as String;
  }

  @override
  void write(BinaryWriter writer, Manga obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.extensionSource)
      ..writeByte(1)
      ..write(obj.mangaCover)
      ..writeByte(2)
      ..write(obj.mangaName)
      ..writeByte(3)
      ..write(obj.mangaLink)
      ..writeByte(4)
      ..write(obj.authorName)
      ..writeByte(5)
      ..write(obj.mangaStudio)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.chapters)
      ..writeByte(8)
      ..write(obj.synopsis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
