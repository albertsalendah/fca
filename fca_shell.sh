#!/bin/bash

# How to Use : 
## Create a Feature
#### ./fca_shell.sh create <feature_name>
## Install Dependencies
#### ./fca_shell.sh install
## Check Logs
#### cat fca_shell.log

LOG_FILE="fca_shell.log"

# Function to log messages (new logs appear at the top)
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

# Function to create a feature
create_feature() {
  FEATURE_NAME=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  FEATURE_CLASS_NAME=$(echo "$1" | sed -r 's/(^|-)(\w)/\U\2/g')
  FEATURE_PATH="lib/features/$FEATURE_NAME"

  log "Starting feature creation: $FEATURE_NAME"

  FOLDERS=(
    "lib/core/errors"
    "lib/core/usecases"
    "lib/core/utils/services"
    "$FEATURE_PATH/data/datasources"
    "$FEATURE_PATH/data/models"
    "$FEATURE_PATH/data/repositories"
    "$FEATURE_PATH/domain/entities"
    "$FEATURE_PATH/domain/repositories"
    "$FEATURE_PATH/domain/usecases"
    "$FEATURE_PATH/presentation/blocs"
    "$FEATURE_PATH/presentation/pages"
  )

  # Create folders
  for FOLDER in "${FOLDERS[@]}"; do
    mkdir -p "$FOLDER"
    log "Created: $FOLDER"
  done

  # Core files
  if [ ! -f lib/core/errors/failure.dart ]; then
    cat <<EOT >lib/core/errors/failure.dart
abstract class Failure {
  final String message;
  Failure(this.message);
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

  if [ ! -f lib/core/usecases/usecase.dart ]; then
    cat <<EOT >lib/core/usecases/usecase.dart
abstract class UseCase<Output, Input> {
  Future<Output> call(Input params);
}
EOT
    log "Created: lib/core/usecases/usecase.dart"
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
class ${FEATURE_CLASS_NAME}RemoteDataSource {
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
class ${FEATURE_CLASS_NAME}RepositoryImpl {
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
abstract class ${FEATURE_CLASS_NAME}Repository {
  // TODO: Define repository methods
}
EOT
  log "Created: $FEATURE_PATH/domain/repositories/${FEATURE_NAME}_repository.dart"

  cat <<EOT >$FEATURE_PATH/domain/usecases/get_${FEATURE_NAME}.dart
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

  cat <<EOT >$FEATURE_PATH/presentation/pages/${FEATURE_NAME}_page.dart
import 'package:flutter/material.dart';
EOT
  log "Created: $FEATURE_PATH/presentation/pages/${FEATURE_NAME}_page.dart"

  log "Feature structure for '$FEATURE_NAME' created successfully!"
}

# Function to install dependencies
install_dependencies() {
  DEPENDENCIES=("flutter_bloc" "go_router" "get_it" "dio" "fpdart")

  log "Starting dependency installation..."

  for DEP in "${DEPENDENCIES[@]}"; do
    if flutter pub deps | grep -q "$DEP"; then
      log "$DEP is already installed."
    else
      log "Installing $DEP..."
      flutter pub add "$DEP" >> "$LOG_FILE" 2>&1
      if [ $? -eq 0 ]; then
        log "Successfully installed: $DEP"
      else
        log "Error installing: $DEP"
      fi
    fi
  done

  log "Dependency installation complete!"
}

# Main script logic
if [ "$1" == "create" ]; then
  if [ -z "$2" ]; then
    log "Error: No feature name provided. Usage: ./fca_shell.sh create <feature_name>"
    exit 1
  fi
  create_feature "$2"
elif [ "$1" == "install" ]; then
  install_dependencies
else
  log "Error: Invalid command. Use './fca_shell.sh create <feature_name>' or './fca_shell.sh install'"
  exit 1
fi
