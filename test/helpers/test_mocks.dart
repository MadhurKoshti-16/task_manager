import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_bloc/core/network/network_info.dart';
import 'package:task_manager_bloc/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:task_manager_bloc/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:task_manager_bloc/features/authentication/domain/repositories/auth_repository.dart';
import 'package:task_manager_bloc/features/authentication/domain/usecases/get_current_user.dart';
import 'package:task_manager_bloc/features/authentication/domain/usecases/login_user.dart';
import 'package:task_manager_bloc/features/authentication/domain/usecases/logout_user.dart';
import 'package:task_manager_bloc/features/authentication/domain/usecases/register_user.dart';
import 'package:task_manager_bloc/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:task_manager_bloc/features/authentication/presentation/bloc/auth_event.dart';
import 'package:task_manager_bloc/features/authentication/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockLoginUser extends Mock implements LoginUser {}

class MockRegisterUser extends Mock implements RegisterUser {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockLogoutUser extends Mock implements LogoutUser {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
