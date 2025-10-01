#!/bin/bash

# --- Function to get user input ---
get_input() {
    local prompt="$1"
    local var_name="$2"
    
    # Prompt the user until a non-empty value is provided
    while true; do
        read -r -p "$prompt" input
        if [[ -n "$input" ]]; then
            # Use 'printf -v' to assign the value to the variable name passed as a string
            printf -v "$var_name" "%s" "$input"
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
}

# --- 1. Get the JAR File Name ---
echo "--- Minecraft Server Startup Script ---"
get_input "Enter the name of the server JAR file (e.g., server.jar): " JAR_FILE

# --- 2. Get the Memory Amount and Unit ---
while true; do
    get_input "Enter the amount of memory (e.g., 2, 4, 8): " MEMORY_AMOUNT
    get_input "Enter the memory unit (mb or gb): " MEMORY_UNIT

    # Convert unit to uppercase for easier comparison
    UNIT_UPPER=$(echo "$MEMORY_UNIT" | tr '[:lower:]' '[:upper:]')

    # Basic input validation
    if ! [[ "$MEMORY_AMOUNT" =~ ^[0-9]+$ ]]; then
        echo "Error: Memory amount must be a number."
    elif [[ "$UNIT_UPPER" != "MB" && "$UNIT_UPPER" != "GB" ]]; then
        echo "Error: Memory unit must be 'mb' or 'gb'."
    else
        break # Exit loop if input is valid
    fi
done

# --- 3. Construct the Memory Allocation Flag ---
if [[ "$UNIT_UPPER" == "GB" ]]; then
    # For GB, Java uses 'G' (e.g., 4G)
    MEMORY_FLAG="-Xmx${MEMORY_AMOUNT}G"
    echo "Allocating ${MEMORY_AMOUNT} Gigabytes of RAM."
elif [[ "$UNIT_UPPER" == "MB" ]]; then
    # For MB, Java uses 'M' (e.g., 512M)
    MEMORY_FLAG="-Xmx${MEMORY_AMOUNT}M"
    echo "Allocating ${MEMORY_AMOUNT} Megabytes of RAM."
fi

# --- 4. Check for JAR file existence ---
if [ ! -f "$JAR_FILE" ]; then
    echo "Error: The file '$JAR_FILE' was not found in the current directory."
    echo "Please ensure the JAR file is correctly named and located here."
    exit 1
fi

# --- 5. Run the JAR File ---
echo "--- Starting Minecraft Server ---"
echo "Command: java $MEMORY_FLAG -Xms1024M -jar $JAR_FILE nogui"

# Run the server. '-Xms' sets the initial memory, here fixed to 1024M for stability.
java "$MEMORY_FLAG" -Xms1024M -jar "$JAR_FILE" nogui

echo "--- Server stopped. ---"