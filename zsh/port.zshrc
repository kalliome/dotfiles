# Port Management Functions
# =========================
# Utilities for checking and managing network ports
#
# Requirements:
#   - lsof (usually pre-installed on Linux/macOS)
#
# Usage:
#   port <port-number>      # Check what's using a specific port
#   killport <port-number>  # Kill the process using a specific port

# Check what process is using a specific port
# --------------------------------------------
# Usage: port <port-number>
#
# Examples:
#   port 3000        # Check what's using port 3000
#   port 8080        # Check what's using port 8080
port() {
    if [[ -z "$1" ]]; then
        echo "Usage: port <port-number>"
        echo "Example: port 3000"
        return 1
    fi

    local PORT="$1"

    echo "Checking port $PORT..."
    lsof -i ":$PORT"

    if [[ $? -ne 0 ]]; then
        echo "No process found using port $PORT"
        return 1
    fi
}

# Kill the process using a specific port
# ---------------------------------------
# Usage: killport <port-number>
#
# Examples:
#   killport 3000    # Kill process on port 3000
#   killport 8080    # Kill process on port 8080
killport() {
    if [[ -z "$1" ]]; then
        echo "Usage: killport <port-number>"
        echo "Example: killport 3000"
        return 1
    fi

    local PORT="$1"

    # Get the PID(s) using the port
    local PIDS=$(lsof -t -i ":$PORT")

    if [[ -z "$PIDS" ]]; then
        echo "No process found using port $PORT"
        return 1
    fi

    echo "Found process(es) on port $PORT:"
    lsof -i ":$PORT"
    echo ""

    # Kill each PID
    for PID in $PIDS; do
        echo "Killing process $PID..."
        kill "$PID"

        if [[ $? -eq 0 ]]; then
            echo "✓ Successfully killed process $PID"
        else
            echo "✗ Failed to kill process $PID (you may need appropriate permissions)"
            return 1
        fi
    done

    echo ""
    echo "✓ All processes on port $PORT have been terminated"
}
