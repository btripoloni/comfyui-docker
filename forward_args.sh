# This script will forward all arguments to the main.py script, excluding USER_ID and GROUP_ID
#!/bin/bash

# Filter out USER_ID and GROUP_ID arguments
filtered_args=()
for arg in "$@"; do
  if [[ "$arg" != "USER_ID="* && "$arg" != "GROUP_ID="* ]]; then
    filtered_args+=("$arg")
  fi
done

# Forward the filtered arguments to the main.py script
/opt/conda/bin/python main.py "${filtered_args[@]}"
