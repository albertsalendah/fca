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
  local default_deps=("flutter_bloc" "go_router" "get_it" "dio" "fpdart")

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
    "lib/core/errors"
<<<<<<< HEAD
    "lib/core/usecase"
=======
    "lib/core/usecases"
>>>>>>> origin/main
    "lib/core/utils/services"
    "$FEATURE_PATH/data/datasources"
    "$FEATURE_PATH/data/models"
    "$FEATURE_PATH/data/repositories"
    "$FEATURE_PATH/domain/entities"
    "$FEATURE_PATH/domain/repositories"
    "$FEATURE_PATH/domain/usecases"
<<<<<<< HEAD
    "$FEATURE_PATH/presentation/bloc"
=======
    "$FEATURE_PATH/presentation/blocs"
>>>>>>> origin/main
    "$FEATURE_PATH/presentation/pages"
    "$FEATURE_PATH/presentation/widgets"
  )

  for FOLDER in "${FOLDERS[@]}"; do
    mkdir -p "$FOLDER"
    log "Created: $FOLDER"
  done

  # Core files
  if [ ! -f lib/core/errors/failure.dart ]; then
    cat <<EOT >lib/core/errors/failure.dart
<<<<<<< HEAD
class Failure {
  final String message;
  Failure([this.message = 'An unexpected error occured' ]);
=======
abstract class Failure {
  final String message;
  Failure(this.message);
>>>>>>> origin/main
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
<<<<<<< HEAD
  
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
=======

  if [ ! -f lib/core/usecases/usecase.dart ]; then
    cat <<EOT >lib/core/usecases/usecase.dart
abstract class UseCase<Output, Input> {
  Future<Output> call(Input params);
}
EOT
    log "Created: lib/core/usecases/usecase.dart"
>>>>>>> origin/main
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
<<<<<<< HEAD
abstract interface class ${FEATURE_CLASS_NAME}RemoteDataSource {
  // TODO: Implement remote data source
}

class ${FEATURE_CLASS_NAME}RemoteDataSourceImpl implements ${FEATURE_CLASS_NAME}RemoteDataSource {
  
}
=======
class ${FEATURE_CLASS_NAME}RemoteDataSource {
  // TODO: Implement remote data source
}
>>>>>>> origin/main
EOT
  log "Created: $FEATURE_PATH/data/datasources/${FEATURE_NAME}_remote_data_source.dart"

  cat <<EOT >$FEATURE_PATH/data/models/${FEATURE_NAME}_model.dart
class ${FEATURE_CLASS_NAME}Model {
  // TODO: Define model
}
EOT
  log "Created: $FEATURE_PATH/data/models/${FEATURE_NAME}_model.dart"

  cat <<EOT >$FEATURE_PATH/data/repositories/${FEATURE_NAME}_repository_impl.dart
<<<<<<< HEAD
import '../../domain/repositories/${FEATURE_NAME}_repository.dart';
class ${FEATURE_CLASS_NAME}RepositoryImpl implements ${FEATURE_CLASS_NAME}Repository {
=======
class ${FEATURE_CLASS_NAME}RepositoryImpl {
>>>>>>> origin/main
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
<<<<<<< HEAD
abstract interface class ${FEATURE_CLASS_NAME}Repository {
=======
abstract class ${FEATURE_CLASS_NAME}Repository {
>>>>>>> origin/main
  // TODO: Define repository methods
}
EOT
  log "Created: $FEATURE_PATH/domain/repositories/${FEATURE_NAME}_repository.dart"

  cat <<EOT >$FEATURE_PATH/domain/usecases/get_${FEATURE_NAME}.dart
<<<<<<< HEAD
  import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

class Get${FEATURE_CLASS_NAME} extends UseCase<String, ${FEATURE_CLASS_NAME}Params> {
  @override
  Future<Either<Failure, String>> call(${FEATURE_CLASS_NAME}Params params) async {
    // TODO: implement call
    throw UnimplementedError();
  }
}

class ${FEATURE_CLASS_NAME}Params {
  final String name;
  final String email;
  final String password;

  ${FEATURE_CLASS_NAME}Params(
      {required this.name, required this.email, required this.password});
}
EOT
  log "Created: $FEATURE_PATH/domain/usecases/get_${FEATURE_NAME}.dart"

  cat <<EOT >$FEATURE_PATH/presentation/bloc/${FEATURE_NAME}_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
EOT
  log "Created: $FEATURE_PATH/presentation/bloc/${FEATURE_NAME}_bloc.dart"
=======
import '../../../../core/usecases/usecase.dart';

class Get${FEATURE_CLASS_NAME} extends UseCase<void, void> {
  @override
  Future<void> call(void params) async {
    // TODO: Implement use case logic
  }
}
EOT
  log "Created: $FEATURE_PATH/domain/usecases/get_${FEATURE_NAME}.dart"

  cat <<EOT >$FEATURE_PATH/presentation/blocs/${FEATURE_NAME}_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
EOT
  log "Created: $FEATURE_PATH/presentation/blocs/${FEATURE_NAME}_bloc.dart"
>>>>>>> origin/main

  cat <<EOT >$FEATURE_PATH/presentation/pages/${FEATURE_NAME}_page.dart
import 'package:flutter/material.dart';
EOT
  log "Created: $FEATURE_PATH/presentation/pages/${FEATURE_NAME}_page.dart"

  log "Feature structure for '$FEATURE_NAME' created successfully!"
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
  *)
    log "Error: Invalid command. Use './fca_shell.sh create <feature_name>' or './fca_shell.sh install [dependencies]'"
    exit 1
    ;;
esac
