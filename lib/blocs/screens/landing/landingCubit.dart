import 'package:TimeliNUS/models/form/confirmedPassword.dart';
import 'package:TimeliNUS/models/form/email.dart';
import 'package:TimeliNUS/models/form/password.dart';
import 'package:TimeliNUS/blocs/screens/landing/landingState.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';

class LandingCubit extends Cubit<LandingState> {
  LandingCubit(this._authenticationRepository) : super(LandingState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([
        email,
        state.password,
        // state.confirmedPassword,
      ]),
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    final confirmedPassword = ConfirmedPassword.dirty(
      password: password.value,
      value: state.confirmedPassword.value,
    );
    emit(state.copyWith(
      password: password,
      confirmedPassword: confirmedPassword,
      status: Formz.validate([
        state.email,
        password,
        // if (state.landingStatus == LandingStatus.isSigningUp)
        //   state.confirmedPassword
      ]),
    ));
  }

  void confirmedPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(
      password: state.password.value,
      value: value,
    );
    emit(state.copyWith(
      confirmedPassword: confirmedPassword,
      status: Formz.validate([
        state.email,
        state.password,
        confirmedPassword,
      ]),
    ));
  }

  void toggleRemembered() async {
    emit(state.copyWith(remembered: !state.remembered));
  }

  void changeUserName(String value) {
    emit(state.copyWith(name: value));
  }

  void changeLandingState(LandingStatus status) {
    emit(state.copyWith(
        landingStatus: status, email: Email.pure(), password: Password.pure()));
  }

  Future<void> signUpFormSubmitted() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
        name: state.name,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } catch (err) {
      emit(state.copyWith(
          status: FormzStatus.submissionFailure, errMsg: err.toString()));
    }
  }

  Future<void> logInWithCredentials() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } catch (err) {
      emit(state.copyWith(
          status: FormzStatus.submissionFailure, errMsg: err.toString()));
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on Exception catch (err) {
      emit(state.copyWith(
          status: FormzStatus.submissionFailure, errMsg: err.toString()));
    } on NoSuchMethodError {
      emit(state.copyWith(status: FormzStatus.pure));
    }
  }

  @override
  void onChange(Change<LandingState> change) {
    super.onChange(change);
  }

  // Stream<LandingState> get landingState async* {
  //   return state;
  // }
}
