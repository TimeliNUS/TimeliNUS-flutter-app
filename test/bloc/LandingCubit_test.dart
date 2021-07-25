import 'package:TimeliNUS/blocs/screens/landing/landingCubit.dart';
import 'package:TimeliNUS/blocs/screens/landing/landingState.dart';
import 'package:TimeliNUS/models/form/confirmedPassword.dart';
import 'package:TimeliNUS/models/form/email.dart';
import 'package:TimeliNUS/models/form/password.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mockito/mockito.dart';

import '../integration/services/firebase/firebase_auth_test.dart';

class MockAuthenticationRepository extends Mock implements AuthenticationRepository {}

class MockLandingBloc extends MockCubit<LandingState> implements LandingCubit {}

void main() {
  AuthenticationRepository authenticationRepository;
  LandingCubit landingCubit;
  DateTime currentDate = DateTime.now();
  setupCloudFirestoreMocks();
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    authenticationRepository = MockAuthenticationRepository();
    when(authenticationRepository.signUp(
            email: anyNamed('email'), password: anyNamed('password'), name: anyNamed('name')))
        .thenAnswer((ans) => Future.value(null));
    when(authenticationRepository.logInWithGoogle()).thenAnswer((ans) => Future.value(null));
    landingCubit = LandingCubit(authenticationRepository);
  });

  group('LandingCubit', () {
    test('throws AssertionError if Authentication Repository is null', () {
      expect(
        () => LandingCubit(null),
        throwsA(isAssertionError),
      );
    });
    group('LandingCubit state', () {
      blocTest(
        'change email',
        build: () => landingCubit,
        act: (LandingCubit bloc) => bloc.emailChanged('test'),
        expect: () => [
          LandingState(email: Email.dirty('test'), status: FormzStatus.invalid),
        ],
      );
      blocTest(
        'change password',
        build: () => landingCubit,
        act: (LandingCubit bloc) => bloc.passwordChanged('test'),
        expect: () => [
          LandingState(
              password: Password.dirty('test'),
              confirmedPassword: ConfirmedPassword.dirty(password: ''),
              status: FormzStatus.invalid),
        ],
      );

      blocTest(
        'change confirmPassword',
        build: () => landingCubit,
        act: (LandingCubit bloc) => bloc.confirmedPasswordChanged('test'),
        expect: () => [
          LandingState(
              // password: Password.dirty(''),
              confirmedPassword: ConfirmedPassword.dirty(password: '', value: 'test'),
              status: FormzStatus.invalid),
        ],
      );

      blocTest(
        'toggle Remember',
        build: () => landingCubit,
        act: (LandingCubit bloc) => bloc.toggleRemembered(),
        expect: () => [
          LandingState(remembered: true, status: FormzStatus.pure),
        ],
      );

      blocTest(
        'change username',
        build: () => landingCubit,
        act: (LandingCubit bloc) => bloc.changeUserName('test'),
        expect: () => [
          LandingState(name: 'test', status: FormzStatus.pure),
        ],
      );

      blocTest(
        'change landingState',
        build: () => landingCubit,
        act: (LandingCubit bloc) => bloc.changeLandingState(LandingStatus.isLoggingIn),
        expect: () => [
          LandingState(landingStatus: LandingStatus.isLoggingIn, status: FormzStatus.pure),
        ],
      );
      blocTest(
        'submit form',
        build: () => landingCubit,
        act: (LandingCubit bloc) => bloc
          ..emailChanged('testing@gmail.com')
          ..passwordChanged('testing123')
          ..confirmedPasswordChanged('testing123')
          ..signUpFormSubmitted(),
        expect: () => [
          LandingState(
              email: Email.dirty('testing@gmail.com'),
              confirmedPassword: ConfirmedPassword.pure(),
              status: FormzStatus.invalid),
          LandingState(
              email: Email.dirty('testing@gmail.com'),
              password: Password.dirty('testing123'),
              confirmedPassword: ConfirmedPassword.dirty(password: '', value: ''),
              status: FormzStatus.valid),
          LandingState(
              email: Email.dirty('testing@gmail.com'),
              password: Password.dirty('testing123'),
              confirmedPassword: ConfirmedPassword.dirty(password: 'testing123', value: 'testing123'),
              status: FormzStatus.valid),
          LandingState(
              email: Email.dirty('testing@gmail.com'),
              password: Password.dirty('testing123'),
              confirmedPassword: ConfirmedPassword.dirty(password: 'testing123', value: 'testing123'),
              status: FormzStatus.submissionInProgress),
          LandingState(
              email: Email.dirty('testing@gmail.com'),
              password: Password.dirty('testing123'),
              confirmedPassword: ConfirmedPassword.dirty(password: 'testing123', value: 'testing123'),
              status: FormzStatus.submissionSuccess),
        ],
      );
      blocTest(
        'login with Google',
        build: () => landingCubit,
        act: (LandingCubit bloc) => bloc..logInWithGoogle(),
        expect: () => [
          LandingState(status: FormzStatus.submissionInProgress),
          LandingState(status: FormzStatus.submissionSuccess),
        ],
      );
    });
  });
}
