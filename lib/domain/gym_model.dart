class GymScheduleItem {
  final int id;
  final int gymId;
  final int dayOfWeek;
  final int openMinutes;
  final int closeMinutes;
  final bool isClosed;

  const GymScheduleItem({
    this.id = 0,
    this.gymId = 0,
    this.dayOfWeek = 0,
    this.openMinutes = 0,
    this.closeMinutes = 0,
    this.isClosed = false,
  });

  String get dayName {
    switch (dayOfWeek) {
      case 0:
        return 'Domingo';
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      default:
        return 'Día $dayOfWeek';
    }
  }

  String get formattedHours {
    if (isClosed) return 'Cerrado';
    final openHour = (openMinutes ~/ 60).toString().padLeft(2, '0');
    final openMin = (openMinutes % 60).toString().padLeft(2, '0');
    final closeHour = (closeMinutes ~/ 60).toString().padLeft(2, '0');
    final closeMin = (closeMinutes % 60).toString().padLeft(2, '0');
    return '$openHour:$openMin - $closeHour:$closeMin';
  }

  GymScheduleItem copyWith({
    int? id,
    int? gymId,
    int? dayOfWeek,
    int? openMinutes,
    int? closeMinutes,
    bool? isClosed,
  }) {
    return GymScheduleItem(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      openMinutes: openMinutes ?? this.openMinutes,
      closeMinutes: closeMinutes ?? this.closeMinutes,
      isClosed: isClosed ?? this.isClosed,
    );
  }
}

class GymPhotoItem {
  final int id;
  final int fileId;
  final String slug;
  final String url;
  final String mimeType;
  final int size;
  final String createdAt;

  const GymPhotoItem({
    this.id = 0,
    this.fileId = 0,
    this.slug = '',
    this.url = '',
    this.mimeType = '',
    this.size = 0,
    this.createdAt = '',
  });

  GymPhotoItem copyWith({
    int? id,
    int? fileId,
    String? slug,
    String? url,
    String? mimeType,
    int? size,
    String? createdAt,
  }) {
    return GymPhotoItem(
      id: id ?? this.id,
      fileId: fileId ?? this.fileId,
      slug: slug ?? this.slug,
      url: url ?? this.url,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class GymModel {
  final int id;
  final int ownerId;
  final int backgroundId;
  final String backgroundUrl;
  final String name;
  final String address;
  final String phone;
  final String email;
  final double latitude;
  final double longitude;
  final bool isOpen;
  final double distanceMeters;
  final List<GymScheduleItem> schedules;
  final List<GymPhotoItem> photos;
  final String createdAt;
  final String updatedAt;

  const GymModel({
    this.id = 0,
    this.ownerId = 0,
    this.backgroundId = 0,
    this.backgroundUrl = '',
    this.name = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isOpen = false,
    this.distanceMeters = 0.0,
    this.schedules = const [],
    this.photos = const [],
    this.createdAt = '',
    this.updatedAt = '',
  });

  GymModel copyWith({
    int? id,
    int? ownerId,
    int? backgroundId,
    String? backgroundUrl,
    String? name,
    String? address,
    String? phone,
    String? email,
    double? latitude,
    double? longitude,
    bool? isOpen,
    double? distanceMeters,
    List<GymScheduleItem>? schedules,
    List<GymPhotoItem>? photos,
    String? createdAt,
    String? updatedAt,
  }) {
    return GymModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      backgroundId: backgroundId ?? this.backgroundId,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOpen: isOpen ?? this.isOpen,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      schedules: schedules ?? this.schedules,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
