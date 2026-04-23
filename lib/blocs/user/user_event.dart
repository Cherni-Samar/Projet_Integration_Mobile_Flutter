import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserRefreshRequested extends UserEvent {
  const UserRefreshRequested();
}

class UserUpdateRequested extends UserEvent {
  final String? name;
  final String? email;
  final String? currentPassword;
  final String? newPassword;

  const UserUpdateRequested({
    this.name,
    this.email,
    this.currentPassword,
    this.newPassword,
  });

  @override
  List<Object?> get props => [name, email, currentPassword, newPassword];
}
