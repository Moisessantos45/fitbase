import 'package:fitbase/domain/gym_model.dart';

class GymMapper {
  static Map<String, dynamic>? toNullableMap(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  static Map<String, dynamic> toSafeMap(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return {};
  }

  static GymScheduleItem fromSchedule(Map<String, dynamic> map) {
    return GymScheduleItem(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      gymId: int.tryParse(map['gym_id']?.toString() ?? '') ?? 0,
      dayOfWeek: int.tryParse(map['day_of_week']?.toString() ?? '') ?? 0,
      openMinutes: int.tryParse(map['open_minutes']?.toString() ?? '') ?? 0,
      closeMinutes: int.tryParse(map['close_minutes']?.toString() ?? '') ?? 0,
      isClosed: map['is_closed'] == true ||
          map['is_closed']?.toString().toLowerCase() == 'true',
    );
  }

  static GymPhotoItem fromPhoto(Map<String, dynamic> map) {
    return GymPhotoItem(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      fileId: int.tryParse(map['file_id']?.toString() ?? '') ?? 0,
      slug: map['slug']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
      mimeType: map['mime_type']?.toString() ?? '',
      size: int.tryParse(map['size']?.toString() ?? '') ?? 0,
      createdAt: map['created_at']?.toString() ?? '',
    );
  }

  static GymModel fromMap(Map<String, dynamic> map) {
    final schedulesRaw = map['schedules'] ?? map['gym_schedules'];
    final schedulesList = <GymScheduleItem>[];
    if (schedulesRaw is List) {
      for (final item in schedulesRaw) {
        final itemMap = toNullableMap(item);
        if (itemMap != null) {
          schedulesList.add(fromSchedule(itemMap));
        }
      }
    }

    final photosRaw = map['photos'] ?? map['gym_photos'];
    final photosList = <GymPhotoItem>[];
    if (photosRaw is List) {
      for (final item in photosRaw) {
        final itemMap = toNullableMap(item);
        if (itemMap != null) {
          photosList.add(fromPhoto(itemMap));
        }
      }
    }

    return GymModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      ownerId: int.tryParse(map['owner_id']?.toString() ?? '') ?? 0,
      backgroundId: int.tryParse(map['background_id']?.toString() ?? '') ?? 0,
      backgroundUrl: map['background_url']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      latitude: double.tryParse(map['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(map['longitude']?.toString() ?? '') ?? 0.0,
      isOpen: map['is_open'] == true ||
          map['is_open']?.toString().toLowerCase() == 'true',
      schedules: schedulesList,
      photos: photosList,
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
    );
  }

  static Map<String, dynamic> toMap(GymModel gym) {
    return {
      'id': gym.id,
      'name': gym.name,
      'address': gym.address,
      'phone': gym.phone,
      'email': gym.email,
      'latitude': gym.latitude,
      'longitude': gym.longitude,
    };
  }
}
