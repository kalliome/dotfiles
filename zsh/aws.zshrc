# AWS Helper Functions
# ====================
# Portable AWS utilities for shell environments
#
# Requirements:
#   - AWS CLI v2
#   - jq (JSON processor)
#
# Optional environment variables:
#   AWS_MFA_SERIAL - Set to skip MFA device auto-detection
#                    e.g., arn:aws:iam::123456789012:mfa/username

# AWS MFA Authentication
# ----------------------
# Usage: aws-mfa <mfa-code> [profile] [duration-seconds]
#
# Examples:
#   aws-mfa 123456                    # Use default profile, 12 hour session
#   aws-mfa 123456 my-profile         # Use specific profile
#   aws-mfa 123456 default 3600       # 1 hour session

aws-mfa() {
    local MFA_CODE="$1"
    local PROFILE="${2:-default}"
    local DURATION="${3:-43200}"  # 12 hours default (max for get-session-token)

    if [[ -z "$MFA_CODE" ]]; then
        echo "Usage: aws-mfa <mfa-code> [profile] [duration-seconds]"
        echo ""
        echo "Arguments:"
        echo "  mfa-code         Your 6-digit MFA code from authenticator app"
        echo "  profile          AWS profile name (default: 'default')"
        echo "  duration         Session duration in seconds (default: 43200 = 12 hours)"
        echo ""
        echo "Environment variables:"
        echo "  AWS_MFA_SERIAL   Set this to skip MFA device auto-detection"
        return 1
    fi

    # Check for jq dependency
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed."
        echo "Install with: apt install jq (Linux) or brew install jq (macOS)"
        return 1
    fi

    # Get the MFA device ARN - prefer env var, fall back to auto-detection
    local MFA_SERIAL="${AWS_MFA_SERIAL:-$(aws iam list-mfa-devices --profile "$PROFILE" --query 'MFADevices[0].SerialNumber' --output text 2>/dev/null)}"

    if [[ -z "$MFA_SERIAL" || "$MFA_SERIAL" == "None" ]]; then
        echo "Error: Could not find MFA device."
        echo "Either set AWS_MFA_SERIAL environment variable or check your AWS profile."
        echo ""
        echo "To find your MFA serial:"
        echo "  aws iam list-mfa-devices --profile $PROFILE"
        return 1
    fi

    echo "Using MFA device: $MFA_SERIAL"
    echo "Requesting session token..."

    # Get session token with MFA
    local CREDS
    CREDS=$(aws sts get-session-token \
        --profile "$PROFILE" \
        --serial-number "$MFA_SERIAL" \
        --token-code "$MFA_CODE" \
        --duration-seconds "$DURATION" \
        --output json 2>&1)

    if [[ $? -ne 0 ]]; then
        echo "Error getting session token:"
        echo "$CREDS"
        return 1
    fi

    # Export the temporary credentials
    export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')

    local EXPIRATION=$(echo "$CREDS" | jq -r '.Credentials.Expiration')

    echo ""
    echo "✓ MFA authenticated successfully!"
    echo "  Session expires: $EXPIRATION"
    echo "  Credentials exported to environment variables."
    echo ""
    echo "  Run 'aws-mfa-clear' to clear the session."
}

# Clear AWS MFA session credentials
aws-mfa-clear() {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    echo "✓ AWS session credentials cleared."
}

# Check current AWS MFA session status
aws-mfa-status() {
    if [[ -n "$AWS_SESSION_TOKEN" ]]; then
        echo "AWS MFA session is active."
        echo ""
        echo "Current identity:"
        aws sts get-caller-identity 2>/dev/null || echo "  (unable to verify - session may have expired)"
    else
        echo "No AWS MFA session active."
        echo "Run 'aws-mfa <code>' to authenticate."
    fi
}
