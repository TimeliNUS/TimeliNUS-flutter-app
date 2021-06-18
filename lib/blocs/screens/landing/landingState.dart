import 'package:TimeliNUS/models/form/confirmedPassword.dart';
import 'package:TimeliNUS/models/form/email.dart';
import 'package:TimeliNUS/models/form/password.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

enum LandingStatus { isSigningUp, isLoggingIn }

class LandingState extends Equatable {
  const LandingState(
      {this.email = const Email.pure(),
      this.password = const Password.pure(),
      this.status = FormzStatus.pure,
      this.confirmedPassword = const ConfirmedPassword.pure(),
      this.remembered = false,
      this.landingStatus,
      this.errMsg = '',
      this.name = ''});

  final Email email;
  final Password password;
  final FormzStatus status;
  final bool remembered;
  final ConfirmedPassword confirmedPassword;
  final LandingStatus landingStatus;
  final String errMsg;
  final String name;

  @override
  List<Object> get props => [
        email,
        password,
        confirmedPassword,
        status,
        remembered,
        landingStatus,
        errMsg,
        name
      ];

  LandingState copyWith(
      {Email email,
      Password password,
      FormzStatus status,
      ConfirmedPassword confirmedPassword,
      bool remembered,
      LandingStatus landingStatus,
      String errMsg,
      String name}) {
    return LandingState(
        email: email ?? this.email,
        password: password ?? this.password,
        status: status ?? this.status,
        confirmedPassword: confirmedPassword ?? this.confirmedPassword,
        remembered: remembered ?? this.remembered,
        landingStatus: landingStatus ?? this.landingStatus,
        errMsg: errMsg ?? '',
        name: name ?? this.name);
  }
}
