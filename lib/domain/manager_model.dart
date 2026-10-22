class ManagerItem {
  final int id;
  final int gymId;
  final int authId;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String avatarUrl;
  final String gymName;

  const ManagerItem({
    this.id = 0,
    this.gymId = 0,
    this.authId = 0,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
    this.avatarUrl = '',
    this.gymName = '',
  });
}

class ManagerDetail {
  final int id;
  final int authId;
  final String firstName;
  final String lastName;
  final String phone;
  final String avatarUrl;

  const ManagerDetail({
    this.id = 0,
    this.authId = 0,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.avatarUrl = '',
  });
}

class ManagerForm {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;

  const ManagerForm({
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
    this.password = '',
  });

  ManagerForm copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? password,
  }) {
    return ManagerForm(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class PaginationManager {
  final int page;
  final int pageSize;
  final String search;
  final int total;
  final int totalPages;

  const PaginationManager({
    this.page = 1,
    this.pageSize = 10,
    this.search = '',
    this.total = 0,
    this.totalPages = 1,
  });

  PaginationManager copyWith({
    int? page,
    int? pageSize,
    String? search,
    int? total,
    int? totalPages,
  }) {
    return PaginationManager(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class ManagerState {
  final List<ManagerItem> managers;
  final ManagerDetail? managerMe;
  final ManagerForm managerForm;
  final PaginationManager pagination;
  final bool loading;

  const ManagerState({
    this.managers = const [],
    this.managerMe,
    this.managerForm = const ManagerForm(),
    this.pagination = const PaginationManager(),
    this.loading = false,
  });

  ManagerState copyWith({
    List<ManagerItem>? managers,
    ManagerDetail? managerMe,
    ManagerForm? managerForm,
    PaginationManager? pagination,
    bool? loading,
  }) {
    return ManagerState(
      managers: managers ?? this.managers,
      managerMe: managerMe ?? this.managerMe,
      managerForm: managerForm ?? this.managerForm,
      pagination: pagination ?? this.pagination,
      loading: loading ?? this.loading,
    );
  }
}
