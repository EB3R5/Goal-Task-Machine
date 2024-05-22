#!/bin/zsh

# Define the source and destination directories
SOURCE_DIR="/Users/christian/Documents/GitHub/Goal-Task-Machine/goaltask1/goaltask1"
BACKLOG_DIR="/Users/christian/Documents/GitHub/Goal-Task-Machine/GoalTask Backlog"

# Check if the source directory exists
if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source directory does not exist: $SOURCE_DIR"
  exit 1
fi

# Create the backlog directory if it does not exist
if [[ ! -d "$BACKLOG_DIR" ]]; then
  mkdir -p "$BACKLOG_DIR"
  echo "Created backlog directory: $BACKLOG_DIR"
fi

# Copy all Swift files from the source directory to the backlog directory
cp "$SOURCE_DIR"/*.swift "$BACKLOG_DIR"

# Check if the copy operation was successful
if [[ $? -eq 0 ]]; then
  echo "Swift files copied successfully from $SOURCE_DIR to $BACKLOG_DIR"
else
  echo "Failed to copy Swift files from $SOURCE_DIR to $BACKLOG_DIR"
  exit 1
fi
