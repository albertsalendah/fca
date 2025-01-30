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

# Function to create a feature
create_feature() {
  FEATURE_NAME=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  FEATURE_CLASS_NAME=$(echo "$1" | sed -r 's/(^|-)(\w)/\U\2/g')
  FEATURE_PATH="lib/features/$FEATURE_NAME"

  log "Starting feature creation: $FEATURE_NAME"

  FOLDERS=(
	"lib/config/routes"
	"lib/config/theme"
    "lib/core/errors"
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

  # Core files
  if [ ! -f lib/core/errors/failure.dart ]; then
    cat <<EOT >lib/core/errors/failure.dart
class Failure {
  final String message;
  Failure([this.message = 'An unexpected error occured']);
}
class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
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

abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
EOT
    log "Created: lib/core/usecase/usecase.dart"
  fi  	

  if [ ! -f lib/core/utils/constants.dart ]; then
    cat <<EOT >lib/core/utils/constants.dart
const String baseUrl = "https://api.example.com";
EOT
    log "Created: lib/core/utils/constants.dart"
  fi

  if [ ! -f lib/core/utils/services/dio_service.dart ]; then
    cat <<EOT >lib/core/utils/services/dio_service.dart
import 'package:dio/dio.dart';
import '/core/utils/constants.dart';

class DioService {
  static final Dio dio = Dio(
    BaseOptions(baseUrl: baseUrl),
  );
}
EOT
    log "Created: lib/core/utils/services/dio_service.dart"
  fi

  # Feature-specific files
  cat <<EOT >$FEATURE_PATH/data/datasources/${FEATURE_NAME}_remote_data_source.dart
abstract interface class ${FEATURE_CLASS_NAME}RemoteDataSource {
  
}

class ${FEATURE_CLASS_NAME}RemoteDataSourceImpl implements ${FEATURE_CLASS_NAME}RemoteDataSource {
  // TODO: Implement remote data source
}
EOT
  log "Created: $FEATURE_PATH/data/datasources/${FEATURE_NAME}_remote_data_source.dart"

  cat <<EOT >$FEATURE_PATH/data/models/${FEATURE_NAME}_model.dart
class ${FEATURE_CLASS_NAME}Model {
  // TODO: Define model
}
EOT
  log "Created: $FEATURE_PATH/data/models/${FEATURE_NAME}_model.dart"

  cat <<EOT >$FEATURE_PATH/data/repositories/${FEATURE_NAME}_repository_impl.dart
import '../../domain/repositories/${FEATURE_NAME}_repository.dart';
class ${FEATURE_CLASS_NAME}RepositoryImpl implements ${FEATURE_CLASS_NAME}Repository {
  // TODO: Implement repository
}
EOT
  log "Created: $FEATURE_PATH/data/repositories/${FEATURE_NAME}_repository_impl.dart"

  cat <<EOT >$FEATURE_PATH/domain/entities/${FEATURE_NAME}.dart
class ${FEATURE_CLASS_NAME} {
  // TODO: Define entity
}
EOT
  log "Created: $FEATURE_PATH/domain/entities/${FEATURE_NAME}.dart"

  cat <<EOT >$FEATURE_PATH/domain/repositories/${FEATURE_NAME}_repository.dart
abstract interface class ${FEATURE_CLASS_NAME}Repository {
}
EOT
  log "Created: $FEATURE_PATH/domain/repositories/${FEATURE_NAME}_repository.dart"

  cat <<EOT >$FEATURE_PATH/domain/usecases/get_${FEATURE_NAME}.dart
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

class Get${FEATURE_CLASS_NAME} implements UseCase<String, ${FEATURE_CLASS_NAME}Params> {
  @override
  Future<Either<Failure, String>> call(${FEATURE_CLASS_NAME}Params params) async {
    // TODO: implement call
    throw UnimplementedError();
  }
}

class ${FEATURE_CLASS_NAME}Params {
  final String test1;
  final String test2;
  final String test3;

  ${FEATURE_CLASS_NAME}Params(
      {required this.test1, required this.test2, required this.test3});
}
EOT
  log "Created: $FEATURE_PATH/domain/usecases/get_${FEATURE_NAME}.dart"

  cat <<EOT >$FEATURE_PATH/presentation/bloc/${FEATURE_NAME}_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
EOT
  log "Created: $FEATURE_PATH/presentation/bloc/${FEATURE_NAME}_bloc.dart"

  cat <<EOT >$FEATURE_PATH/presentation/pages/${FEATURE_NAME}_page.dart
import 'package:flutter/material.dart';
EOT
  log "Created: $FEATURE_PATH/presentation/pages/${FEATURE_NAME}_page.dart"

  log "Feature structure for '$FEATURE_NAME' created successfully!"
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

  if [ ! -f "$MAIN_DART_FILE" ]; then
    log "lib/main.dart not found. Creating a new one..."
    mkdir -p lib  # Ensure the lib folder exists
    cat <<EOT >$MAIN_DART_FILE
import 'core/routes/routes.dart';
import 'core/theme/theme.dart';
import 'package:blog_app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
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
  else
    log "Modifying existing lib/main.dart to include dotenv support."
    # Insert dotenv import if not present
    if ! grep -q "flutter_dotenv/flutter_dotenv.dart" "$MAIN_DART_FILE"; then
      sed -i '1i import "package:flutter_dotenv/flutter_dotenv.dart";' "$MAIN_DART_FILE"
    fi

    # Insert dotenv initialization before runApp()
    if ! grep -q "await dotenv.load();" "$MAIN_DART_FILE"; then
      sed -i '/void main()/a\  await dotenv.load();' "$MAIN_DART_FILE"
    fi

    log "Updated lib/main.dart with dotenv support."
  fi
}

# Main script logic
case "$1" in
  "install")
    shift
    install_dependencies "$@"
    ;;
  "create")
    if [ -z "$2" ]; then
      log "Error: No feature name provided. Usage: ./fca_shell.sh create <feature_name>"
      exit 1
    fi
    create_feature "$2"
    ;;
  ".env")
    create_env_file
    ;;
  "main")
    modify_main_dart
    ;;
  *)
    log "Error: Invalid command. Use './fca_shell.sh create <feature_name>', './fca_shell.sh install [dependencies]', or './fca_shell.sh .env'"
    exit 1
    ;;
esac
