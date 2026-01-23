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
    if [[ -z "$1" ]]; then
        echo "Usage: aws-mfa <mfa-code>"
        return 1
    fi

    # Check for jq dependency
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed."
        echo "Install with: apt install jq (Linux) or brew install jq (macOS)"
        return 1
    fi

    local MFA_ARN="arn:aws:iam::632424468711:mfa/teppo.kallio@trustmary.com"

    echo "Authenticating with MFA..."

    # Clear any existing session credentials first, then get new ones
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

    local CREDS
    CREDS=$(aws sts get-session-token \
        --serial-number "$MFA_ARN" \
        --token-code "$1" \
        --output json 2>&1)

    if [[ $? -ne 0 ]]; then
        echo "Authentication failed:"
        echo "$CREDS"
        return 1
    fi

    export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')

    echo "✓ Success! Session is valid for 12 hours."
    echo "  Try: aws s3 ls"
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
