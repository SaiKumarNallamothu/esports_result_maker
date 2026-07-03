// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TeamAdapter extends TypeAdapter<Team> {
  @override
  final int typeId = 0;

  @override
  Team read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Team(
      id: fields[0] as String,
      name: fields[1] as String,
      logoPath: fields[2] as String?,
      group: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Team obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.logoPath)
      ..writeByte(3)
      ..write(obj.group);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PointSystemAdapter extends TypeAdapter<PointSystem> {
  @override
  final int typeId = 1;

  @override
  PointSystem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PointSystem(
      id: fields[0] as String,
      name: fields[1] as String,
      positionPoints: (fields[2] as Map).cast<int, int>(),
      finishPoints: fields[3] as int,
      tiebreakerHierarchy: (fields[4] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PointSystem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.positionPoints)
      ..writeByte(3)
      ..write(obj.finishPoints)
      ..writeByte(4)
      ..write(obj.tiebreakerHierarchy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointSystemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MatchResultAdapter extends TypeAdapter<MatchResult> {
  @override
  final int typeId = 2;

  @override
  MatchResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchResult(
      teamId: fields[0] as String,
      placement: fields[1] as int,
      finishes: fields[2] as int,
      bonusPoints: fields[3] as int,
      penaltyPoints: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MatchResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.teamId)
      ..writeByte(1)
      ..write(obj.placement)
      ..writeByte(2)
      ..write(obj.finishes)
      ..writeByte(3)
      ..write(obj.bonusPoints)
      ..writeByte(4)
      ..write(obj.penaltyPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TournamentAdapter extends TypeAdapter<Tournament> {
  @override
  final int typeId = 3;

  @override
  Tournament read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tournament(
      id: fields[0] as String,
      name: fields[1] as String,
      numberOfMatches: fields[2] as int,
      numberOfTeams: fields[3] as int,
      teams: (fields[4] as List).cast<Team>(),
      matches: (fields[5] as List).cast<Match>(),
      pointSystem: fields[6] as PointSystem,
      createdAt: fields[7] as DateTime,
      format: fields[8] as String,
      numberOfGroups: fields[9] as int?,
      gameCategory: fields[10] as String,
      groupNames: (fields[11] as List?)?.cast<String>(),
      qualifyCount: fields[12] as int?,
      teamsPerMatch: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Tournament obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.numberOfMatches)
      ..writeByte(3)
      ..write(obj.numberOfTeams)
      ..writeByte(4)
      ..write(obj.teams)
      ..writeByte(5)
      ..write(obj.matches)
      ..writeByte(6)
      ..write(obj.pointSystem)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.format)
      ..writeByte(9)
      ..write(obj.numberOfGroups)
      ..writeByte(10)
      ..write(obj.gameCategory)
      ..writeByte(11)
      ..write(obj.groupNames)
      ..writeByte(12)
      ..write(obj.qualifyCount)
      ..writeByte(13)
      ..write(obj.teamsPerMatch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MatchAdapter extends TypeAdapter<Match> {
  @override
  final int typeId = 4;

  @override
  Match read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Match(
      matchNumber: fields[0] as int,
      results: (fields[1] as List).cast<MatchResult>(),
      playingGroups: (fields[2] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Match obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.matchNumber)
      ..writeByte(1)
      ..write(obj.results)
      ..writeByte(2)
      ..write(obj.playingGroups);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
