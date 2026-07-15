import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager_bloc/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/get_current_user.dart';
import '../../features/authentication/domain/usecases/login_user.dart';
import '../../features/authentication/domain/usecases/logout_user.dart';
import '../../features/authentication/domain/usecases/register_user.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/datasources/task_remote_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/add_task.dart';
import '../../features/tasks/domain/usecases/delete_task.dart';
import '../../features/tasks/domain/usecases/get_task_page.dart';
import '../../features/tasks/domain/usecases/sync_tasks.dart';
import '../../features/tasks/domain/usecases/toggle_task_status.dart';
import '../../features/tasks/domain/usecases/update_task.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../constants/hive_constants.dart';
import '../network/network_info.dart';
import '../network/network_info_impl.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerFactory<SplashBloc>(
    () => SplashBloc(getCurrentUser: sl<GetCurrentUser>()),
  );
  // External services
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<InternetConnection>(InternetConnection.new);
  sl.registerLazySingleton<Box<dynamic>>(
    () => Hive.box<dynamic>(HiveConstants.authBox),
    instanceName: HiveConstants.authBox,
  );
  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnection>()),
  );
  // Authentication data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sl<Box<dynamic>>(instanceName: HiveConstants.authBox),
    ),
  );
  // Authentication repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  // Authentication use cases
  sl.registerLazySingleton<LoginUser>(() => LoginUser(sl<AuthRepository>()));
  sl.registerLazySingleton<RegisterUser>(
    () => RegisterUser(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUser>(() => LogoutUser(sl<AuthRepository>()));
  // BLoCs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUser: sl<LoginUser>(),
      registerUser: sl<RegisterUser>(),
      getCurrentUser: sl<GetCurrentUser>(),
      logoutUser: sl<LogoutUser>(),
    ),
  );

  //Task
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<Box<dynamic>>(
    () => Hive.box<dynamic>(HiveConstants.taskBox),
    instanceName: HiveConstants.taskBox,
  );
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(
      sl<Box<dynamic>>(instanceName: HiveConstants.taskBox),
    ),
  );
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      localDataSource: sl<TaskLocalDataSource>(),
      remoteDataSource: sl<TaskRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<GetTaskPage>(
    () => GetTaskPage(sl<TaskRepository>()),
  );
  sl.registerLazySingleton<SyncTasks>(() => SyncTasks(sl<TaskRepository>()));
  sl.registerLazySingleton<AddTask>(() => AddTask(sl<TaskRepository>()));
  sl.registerLazySingleton<UpdateTask>(() => UpdateTask(sl<TaskRepository>()));
  sl.registerLazySingleton<ToggleTaskStatus>(
    () => ToggleTaskStatus(sl<TaskRepository>()),
  );
  sl.registerLazySingleton<DeleteTask>(() => DeleteTask(sl<TaskRepository>()));
  sl.registerFactory<TaskBloc>(
    () => TaskBloc(
      getTaskPage: sl<GetTaskPage>(),
      syncTasks: sl<SyncTasks>(),
      addTask: sl<AddTask>(),
      updateTask: sl<UpdateTask>(),
      toggleTaskStatus: sl<ToggleTaskStatus>(),
      deleteTask: sl<DeleteTask>(),
    ),
  );
}
