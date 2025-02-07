#!/bin/bash

# How to Use Locally From root folder:
# 
## Create a Feature
#### ./fca_shell.sh create <feature_name>
## Install Dependencies
#### ./fca_shell.sh install
#### ./fca_shell.sh install <dependencies_name>
## Check Logs
#### cat fca_shell.log

# How to use with git bash :
## from git bash run
### nano ~/.bashrc
## then add this line at the bottom of the file
### alias fca='curl -s https://raw.githubusercontent.com/your-username/your-repo/main/fca_shell.sh | bash -s'
## Save the file (CTRL + X, then Y, then ENTER).
## Reload the shell to apply the changes:
### source ~/.bashrc

## Create a Feature
# fca create <feature_name>
## Install Dependencies
# fca install
# fca install <dependencies_name>

# Current default dependencies = "flutter_bloc" "go_router" "get_it" "dio" "fpdart"

LOG_FILE="fca_shell.log"

# Function to log messages (latest logs at the top)
log() {
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
  NEW_LOG="$TIMESTAMP - $1"
  if [ ! -f "$LOG_FILE" ]; then
    echo "$NEW_LOG" > "$LOG_FILE"
  else
    TEMP_FILE=$(mktemp)
    echo "$NEW_LOG" > "$TEMP_FILE"
    cat "$LOG_FILE" >> "$TEMP_FILE"
    mv "$TEMP_FILE" "$LOG_FILE"
  fi
  echo "$NEW_LOG"
}

# Function to show help information
show_help() {
  cat <<EOT 
Usage :
  ./fca_shell.sh create <feature_name>   Create a new feature folder
  ./fca_shell.sh create example          Create a new example folders and files
  ./fca_shell.sh install                 Install default dependencies
  ./fca_shell.sh install <dependency>    Install a specific dependency
  ./fca_shell.sh create assets folder    Create assets folder with subfolders (icons, images, fonts)
  ./fca_shell.sh h | help                Show this help message
   cat fca_shell.log                     View logs
EOT
}

# Function to create the assets folder
create_assets() {
  ASSETS_PATH="assets"
  SUBFOLDERS=("icons" "images" "fonts")

  mkdir -p "$ASSETS_PATH"
  log "Created: $ASSETS_PATH"

  for SUBFOLDER in "${SUBFOLDERS[@]}"; do
    mkdir -p "$ASSETS_PATH/$SUBFOLDER"
    log "Created: $ASSETS_PATH/$SUBFOLDER"
  done

  log "Assets structure created successfully!"
}

# Function to install dependencies
install_dependencies() {
  # Default dependencies
  local default_deps=("flutter_dotenv" "flutter_bloc" "go_router" "get_it" "dio" "fpdart")

  # If no extra dependencies are provided, install only the default ones
  if [[ $# -eq 0 ]]; then
    dependencies=("${default_deps[@]}")
  else
    dependencies=("$@") # Install only user-specified dependencies
  fi

  for dep in "${dependencies[@]}"; do
    if ! flutter pub deps | grep -q "$dep"; then
      echo "Installing $dep..."
      flutter pub add "$dep"
      log "Installed dependency: $dep"
    else
      echo "$dep is already installed."
      log "$dep is already installed."
    fi
  done
}

#Function to create a future
create_feature(){
  FEATURE_NAME=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  FEATURE_CLASS_NAME=$(echo "$1" | sed -r 's/(^|-)(\w)/\U\2/g')
  FEATURE_PATH="lib/features/$FEATURE_NAME"

  log "Starting feature creation: $FEATURE_NAME"

  FOLDERS=(
	"lib/config/routes"
	"lib/config/theme"
  "lib/core/common/widgets"
  "lib/core/common/entities"
  "lib/core/errors"
  "lib/core/network"
	"lib/core/usecase"
  "lib/core/utils/services"
    "$FEATURE_PATH/data/datasources"
    "$FEATURE_PATH/data/models"
    "$FEATURE_PATH/data/repositories"
    "$FEATURE_PATH/domain/entities"
    "$FEATURE_PATH/domain/repositories"
    "$FEATURE_PATH/domain/usecases"
	  "$FEATURE_PATH/presentation/bloc"
    "$FEATURE_PATH/presentation/pages"
    "$FEATURE_PATH/presentation/widgets"
  )

  for FOLDER in "${FOLDERS[@]}"; do
    mkdir -p "$FOLDER"
    log "Created: $FOLDER"
  done

  if [ ! -f lib/core/init_dependencies.dart ]; then
   cat <<EOT >lib/core/init_dependencies.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await dotenv.load(fileName: ".env");
}

EOT
  log "Created: lib/core/init_dependencies.dart"
  fi

  log "Feature structure for '$FEATURE_NAME' created successfully!"
}

# Function to create a example
create_example() {
  FEATURE_NAME=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  FEATURE_CLASS_NAME=$(echo "$1" | sed -r 's/(^|-)(\w)/\U\2/g')
  FEATURE_PATH="lib/features/$FEATURE_NAME"

  log "Starting example creation: $FEATURE_NAME"

  FOLDERS=(
	"lib/config/routes"
	"lib/config/theme"
  "lib/core/common/widgets"
  "lib/core/common/entities"
  "lib/core/errors"
  "lib/core/network"
	"lib/core/usecase"
  "lib/core/utils/services"
    "$FEATURE_PATH/data/datasources"
    "$FEATURE_PATH/data/models"
    "$FEATURE_PATH/data/repositories"
    "$FEATURE_PATH/domain/entities"
    "$FEATURE_PATH/domain/repositories"
    "$FEATURE_PATH/domain/usecases"
	  "$FEATURE_PATH/presentation/bloc"
    "$FEATURE_PATH/presentation/pages"
    "$FEATURE_PATH/presentation/widgets"
  )

  for FOLDER in "${FOLDERS[@]}"; do
    mkdir -p "$FOLDER"
    log "Created: $FOLDER"
  done

  # Config files 
  if [ ! -f lib/config/routes/routes.dart ]; then
    cat <<EOT >lib/config/routes/routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes_name.dart';

final GoRouter router = GoRouter(
    initialLocation: "/",
    errorBuilder: (context, state) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text(state.error.toString())),
          ],
        ),
      );
    },
    // redirect: (context, state) {
    // bool isLogin = false;
    // if (isLogin) {
    //   return "/home";
    // } else {
    //   return "/";
    // }
    // },
    routes: [
      GoRoute(
          path: "/",
          name: RoutesName.home,
          builder: (context, state) {
            return const HomePage();
          },
          routes: []),
    ]);
EOT
    log "Created: lib/config/routes/routes.dart"
  fi
  
  if [ ! -f lib/config/routes/routes_name.dart ]; then
    cat <<EOT >lib/config/routes/routes_name.dart
class RoutesName {
  static const String login = 'login_page';
  static const String signup = 'signup_page';
  static const String home = 'home_page';
}
EOT
    log "Created: lib/config/routes/routes_name.dart"
  fi
  
  if [ ! -f lib/config/theme/theme.dart ]; then
    cat <<EOT >lib/config/theme/theme.dart
import 'package:flutter/material.dart';
import 'app_pallet.dart';

class AppTheme {
  //Example theme
  static _border([Color color = AppPallete.borderColor]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: 3),
      );

  static final darkThemeMode = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppPallete.backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPallete.backgroundColor,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.all(27),
        hintStyle: TextStyle(
          color: AppPallete.greyColor,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(AppPallete.gradient2),
      ));
}

EOT
    log "Created: lib/config/theme/theme.dart"
  fi
  
  if [ ! -f lib/config/theme/app_pallet.dart ]; then
    cat <<EOT >lib/config/theme/app_pallet.dart
import 'package:flutter/material.dart';

class AppPallete {
  //Example colors
  static const Color primaryColor = Color.fromRGBO(187, 63, 221, 1);
  static const Color secondaryColor = Color.fromRGBO(251, 109, 169, 1);
  static const Color accentColor = Color.fromRGBO(187, 63, 221, 1);
  static const Color accentColor2 = Color.fromRGBO(187, 63, 221, 1);
  static const Color accentColor3 = Color.fromRGBO(187, 63, 221, 1);
  static const Color accentColor4 = Color.fromRGBO(187, 63, 221, 1);
  static const Color accentColor5 = Color.fromRGBO(187, 63, 221, 1);
  static const Color accentColor6 = Color.fromRGBO(187, 63, 221, 1);
  //=================================================================
  static const Color backgroundColor = Color.fromRGBO(24, 24, 32, 1);
  static const Color gradient1 = Color.fromRGBO(187, 63, 221, 1);
  static const Color gradient2 = Color.fromRGBO(251, 109, 169, 1);
  static const Color gradient3 = Color.fromRGBO(255, 159, 124, 1);
  static const Color borderColor = Color.fromRGBO(52, 51, 67, 1);
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Colors.grey;
  static const Color errorColor = Colors.redAccent;
  static const Color transparentColor = Colors.transparent;
}
EOT
    log "Created: lib/config/theme/app_pallet.dart"
  fi

  # CORE FOLDER FILES
  if [ ! -f lib/core/errors/failure.dart ]; then
    cat <<EOT >lib/core/errors/failure.dart
class Failure {
  final String message;
  Failure([this.message = 'An unexpected error occured']);
}
class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

EOT
    log "Created: lib/core/errors/failure.dart"
  fi
  
  if [ ! -f lib/core/errors/exceptions.dart ]; then
    cat <<EOT >lib/core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}
EOT
    log "Created: lib/core/errors/exceptions.dart"
  fi

  if [ ! -f lib/core/usecase/usecase.dart ]; then
    cat <<EOT >lib/core/usecase/usecase.dart
import 'package:fpdart/fpdart.dart';
import '../errors/failure.dart';

// Type is the return type of the use case if successful, while Params is the parameter type

abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
// use this if there is no need for parameters
class NoParams {}
EOT
    log "Created: lib/core/usecase/usecase.dart"
  fi  	

  if [ ! -f lib/core/utils/constants.dart ]; then
    cat <<EOT >lib/core/utils/constants.dart
const String test_param_1 = 'test_param_1';
EOT
    log "Created: lib/core/utils/constants.dart"
  fi

  if [ ! -f lib/core/network/dio_client.dart ]; then
    cat <<EOT >lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(baseUrl: dotenv.env['API_URL'] ?? ''),
  );
}
EOT
    log "Created: lib/core/network/dio_client.dart"
  fi

  # DATA FOLDER FILES
  # Feature-specific files
  cat <<EOT >$FEATURE_PATH/data/datasources/auth_remote_data_source.dart
import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:dio/dio.dart';

//Example of remote data source

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUp(
      {required String name, required String email, required String password});
  Future<UserModel> signIn({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio client;
  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> signIn(
      {required String email, required String password}) async {
    try {
      final response = await client.post('/login',
          data: {'email': email, 'password': password});
      return response.data != null
          ? UserModel.fromJson(response.data!.toJson())
          : throw const ServerException('Data is null!');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUp(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final response = await client.post('/signup',
          data: {'name': name, 'email': email, 'password': password});
      return response.data != null
          ? UserModel.fromJson(response.data!.toJson())
          : throw const ServerException('Data is null!');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

EOT
  log "Created: $FEATURE_PATH/data/datasources/auth_remote_data_source.dart"

  cat <<EOT >$FEATURE_PATH/data/models/user_model.dart
import '../../domain/entities/user.dart';

// this class has to extends a class from folder entities inside domain folder
// Example ${FEATURE_CLASS_NAME}Model extends ${FEATURE_CLASS_NAME} {}

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
}
EOT
  log "Created: $FEATURE_PATH/data/models/user_model.dart"

  cat <<EOT >$FEATURE_PATH/data/repositories/auth_repository_impl.dart
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/entities/user.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:fpdart/fpdart.dart';

//Example of data repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> signIn(
      {required String email, required String password}) async {
    return _getUser(
      fn: () async =>
          await remoteDataSource.signIn(email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, User>> signUp(
      {required String name,
      required String email,
      required String password}) async {
    return _getUser(
      fn: () async => await remoteDataSource.signUp(
          name: name, email: email, password: password),
    );
  }

  Future<Either<Failure, User>> _getUser(
      {required Future<User> Function() fn}) async {
    try {
      final user = await fn();
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}

EOT
  log "Created: $FEATURE_PATH/data/repositories/auth_repository_impl.dart"

  cat <<EOT >$FEATURE_PATH/domain/entities/user.dart
// Example of entity class 
// example name user, product, order, etc.
class User {
  final String id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });
}

EOT
  log "Created: $FEATURE_PATH/domain/entities/user.dart"

  cat <<EOT >$FEATURE_PATH/domain/repositories/auth_repository.dart
import '../../domain/entities/user.dart';
import '../../../../core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';
//Example of domain repository
abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });
}

EOT
  log "Created: $FEATURE_PATH/domain/repositories/auth_repository.dart"

  cat <<EOT >$FEATURE_PATH/domain/usecases/user_sign_in.dart
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

// Example of use case
class UserSignIn implements UseCase<User, UserSignInParams> {
  final AuthRepository repository;
  const UserSignIn(this.repository);
  @override
  Future<Either<Failure, User>> call(UserSignInParams params) async {
    return await repository.signIn(
        email: params.email, password: params.password);
  }
}

class UserSignInParams {
  final String email;
  final String password;

  UserSignInParams({
    required this.email,
    required this.password,
  });
}

EOT
  log "Created: $FEATURE_PATH/domain/usecases/user_sign_in.dart"

  cat <<EOT >$FEATURE_PATH/domain/usecases/user_sign_up.dart
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

// Example of use case
class UserSignUp implements UseCase<User, UserSignUpParams> {
  final AuthRepository repository;
  const UserSignUp(this.repository);

  @override
  Future<Either<Failure, User>> call(UserSignUpParams params) async {
    return await repository.signUp(
        name: params.name, email: params.email, password: params.password);
  }
}

class UserSignUpParams {
  final String name;
  final String email;
  final String password;

  UserSignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });
}

EOT
  log "Created: $FEATURE_PATH/domain/usecases/user_sign_up.dart"

  cat <<EOT >$FEATURE_PATH/presentation/bloc/auth_bloc.dart
import '../../domain/entities/user.dart';
import '../../domain/usecases/user_sign_in.dart';
import '../../domain/usecases/user_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// Example of blocclass AuthBloc extends Bloc<AuthEvent, AuthState> {
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserSignIn _userSignIn;
  AuthBloc({
    required UserSignUp userSignUp,
    required UserSignIn userSignIn,
  })  : _userSignUp = userSignUp,
        _userSignIn = userSignIn,
        super(AuthInitial()) {
    on<SignUpEvent>(_onAuthSignUp);
    on<SignInEvent>(_onAuthSignIn);
  }

  void _onAuthSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _userSignUp(UserSignUpParams(
            name: event.name, email: event.email, password: event.password))
        .then(
      (response) {
        response.fold(
          (failure) => emit(AuthFailure(failure.message)),
          (user) => emit(AuthSuccess(user)),
        );
      },
    );
  }

  void _onAuthSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _userSignIn(
            UserSignInParams(email: event.email, password: event.password))
        .then(
      (response) {
        response.fold(
          (failure) => emit(AuthFailure(failure.message)),
          (user) => emit(AuthSuccess(user)),
        );
      },
    );
  }
}

EOT
  log "Created: $FEATURE_PATH/presentation/bloc/auth_bloc.dart"

  cat <<EOT >$FEATURE_PATH/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart';

//Example of bloc event
@immutable
sealed class AuthEvent {}

final class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  SignInEvent({
    required this.email,
    required this.password,
  });
}

final class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  SignUpEvent({
    required this.name,
    required this.email,
    required this.password,
  });
}

EOT
  log "Created: $FEATURE_PATH/presentation/bloc/auth_event.dart"

  cat <<EOT >$FEATURE_PATH/presentation/bloc/auth_state.dart
  part of 'auth_bloc.dart';
//Example of bloc state
@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(this.user);
}

final class AuthFailure extends AuthState {
  final String message;
  // const AuthFailure(this.message);
  const AuthFailure([this.message = 'An unexpected error occured']);
}

EOT
  log "Created: $FEATURE_PATH/presentation/bloc/${FEATURE_NAME}_state.dart"  

  cat <<EOT >$FEATURE_PATH/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/routes_name.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscureText = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              //Show snackbar/toast message for error here
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              // Show loading here
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In.',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthField(hintText: 'Email', controller: emailController),
                  const SizedBox(height: 15),
                  AuthField(
                    hintText: 'Password',
                    controller: passwordController,
                    obscureText: obscureText,
                    suffixIcon: IconButton(
                      icon: Icon(obscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                SignInEvent(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                ),
                              );
                        }
                      },
                      child: Text('Login')),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      context.pushNamed(RoutesName.signup);
                    },
                    child: RichText(
                        text: TextSpan(
                      text: 'Don\'t have an account? ',
                      style: Theme.of(context).textTheme.titleMedium,
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        )
                      ],
                    )),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

EOT
  log "Created: $FEATURE_PATH/presentation/pages/login_page.dart"

  cat <<EOT >$FEATURE_PATH/presentation/pages/signup_page.dart
import 'package:flutter/material.dart';
EOT
  log "Created: $FEATURE_PATH/presentation/pages/signup_page.dart"

  cat <<EOT >$FEATURE_PATH/presentation/widgets/auth_field.dart
import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final IconButton? suffixIcon;
  const AuthField(
      {super.key,
      required this.hintText,
      required this.controller,
      this.obscureText = false,
      this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        obscureText: obscureText,
        obscuringCharacter: '*',
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: suffixIcon,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hintText';
          }
          return null;
        });
  }
}

EOT
  log "Created: $FEATURE_PATH/presentation/widgets/auth_field.dart"
  if [ ! -f lib/core/example_init_dependencies.dart ]; then
  cat <<EOT >lib/core/example_init_dependencies.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import '../features/example/data/datasources/auth_remote_data_source.dart';
import '../features/example/data/repositories/auth_repository_impl.dart';
import '../features/example/domain/repositories/auth_repository.dart';
import '../features/example/presentation/bloc/auth_bloc.dart';
import '/features/example/domain/usecases/user_sign_in.dart';
import '/features/example/domain/usecases/user_sign_up.dart';
import 'network/dio_client.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  //Please don't forget to add .env in assets pubspec.yaml
  // assets:
  //   - .env
  await dotenv.load(fileName: ".env");
  serviceLocator.registerLazySingleton(() => DioClient.dio);
}

//Example of dependencies injection
void _initAuth() {
 serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
      ),
    ) // using registerFactory because need to create multiple instance
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserSignUp(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserSignIn(
        serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userSignIn: serviceLocator(),
      ),
    ); // using registerLazySingleton because bloc only need to create one instance
}
EOT
  log "Created: lib/core/example_init_dependencies.dart"
  fi

  log "Example folder structure and files created successfully!"
  }

create_env_file() {
  if [ ! -f .env ]; then
    cat <<EOT >.env
# how to use dotenv.env['VAR_NAME']; 

API_URL="https://api.example.com"
EOT
    log "Created .env file with default API_URL."
  else
    log ".env file already exists."
  fi
}

# Function to modify lib/main.dart
modify_main_dart() {
  MAIN_DART_FILE="lib/main.dart"

  log "Setting up lib/main.dart..."

  # Ensure the lib directory exists
  mkdir -p lib  

  # If main.dart exists, delete it first
  if [ -f "$MAIN_DART_FILE" ]; then
    log "Found existing lib/main.dart. Deleting it..."
    rm "$MAIN_DART_FILE"
  fi

  # Create a new main.dart file with dotenv support
  cat <<EOT >"$MAIN_DART_FILE"
import 'package:flutter/material.dart';
import 'config/routes/routes.dart';
import 'config/theme/theme.dart';
import 'core/init_dependencies.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(MultiBlocProvider(
    providers: [
     // BlocProvider(create: (context) => serviceLocator<${FEATURE_CLASS_NAME}Bloc>()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Demo App',
      theme: AppTheme.darkThemeMode,
      routerConfig: router,
    );
  }
}
EOT

  log "Created lib/main.dart with dotenv support."
}


# Main script logic
case "$1" in
  "install")
    shift
    install_dependencies "$@"
    ;;
  "create")
    if [ "$2" == "assets" ]; then
      create_assets
    elif [ -z "$2" ]; then
      log "Error: No feature name provided. Usage: ./fca_shell.sh create <feature_name>"
      exit 1
    elif [ "$2" == "example" ]; then
      create_example "example"
    else
      create_feature "$2"
    fi
    ;;
  "main"|"create main")
      modify_main_dart
      ;;
  ".env"|"env")
      create_env_file
      ;;
  "h"|"help")
    show_help
    ;;
  *)
    log "Error: Invalid command. Use './fca_shell.sh h' for help."
    exit 1
    ;;
esac