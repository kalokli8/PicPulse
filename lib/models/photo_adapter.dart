import 'package:hive/hive.dart';
import 'photo.dart';

class PhotoAdapter extends TypeAdapter<Photo> {
  @override
  final int typeId = 0;

  @override
  Photo read(BinaryReader reader) {
    return Photo(
      id: reader.readString(),
      url: reader.readString(),
      description: reader.readString(),
      location: reader.readString(),
      createdBy: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
      takenAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, Photo obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.url);
    writer.writeString(obj.description);
    writer.writeString(obj.location);
    writer.writeString(obj.createdBy);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeString(obj.takenAt.toIso8601String());
  }
}
