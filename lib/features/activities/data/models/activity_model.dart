import 'package:corelog/core/database/database.dart' as db;
import 'package:corelog/features/activities/domain/entities/activity.dart';
import 'package:drift/drift.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.name,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.description,
  });

  factory ActivityModel.fromData(db.Activity data) {
    return ActivityModel(
      id: data.id,
      name: data.name,
      description: data.description,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  factory ActivityModel.fromEntity(Activity activity) {
    return ActivityModel(
      id: activity.id,
      name: activity.name,
      description: activity.description,
      isActive: activity.isActive,
      createdAt: activity.createdAt,
      updatedAt: activity.updatedAt,
    );
  }

  db.ActivitiesCompanion toCompanion() {
    return db.ActivitiesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  db.ActivitiesCompanion toCreateCompanion() {
    return db.ActivitiesCompanion.insert(
      name: name,
      description: Value(description),
      isActive: Value(isActive),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}