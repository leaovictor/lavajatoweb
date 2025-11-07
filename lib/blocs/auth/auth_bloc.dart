import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lavajato/domain/entities/user_entity.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<UserEntity?>? _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    _userSubscription = _authRepository.user.listen(
      (user) => add(AuthUserChanged(user)),
    );

    on<AuthUserChanged>((event, emit) {
      if (event.user != null) {
        emit(AuthState.authenticated(event.user!));
      } else {
        emit(const AuthState.unauthenticated());
      }
    });

    on<AuthLogoutRequested>((event, emit) {
      _authRepository.signOut();
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
