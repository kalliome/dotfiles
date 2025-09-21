---
description: Attach current Claude Code session to a cc-plan plan for coordinated project work
allowed-tools: Bash(cc-plan:*), Bash(pwd:*)
model: claude-opus-4-1-20250805
---

# Plan Attach Command

Attach your current Claude Code session to an existing plan in cc-plan for coordinated project work.

## User's Request
$ARGUMENTS

## Instructions

1. **Check for Plan ID in Arguments:**
   If a specific plan ID is provided in the arguments, attach directly to that plan:
   ```bash
   cc-plan session set-active --project-path "$(pwd)" --session-id "$CLAUDE_SESSION_ID" --plan-id "[plan-id-from-arguments]"
   ```

   Confirm the attachment and display the plan details:
   ```bash
   cc-plan plan get --plan-id "[plan-id-from-arguments]"
   ```

2. **List Available Plans (if no plan ID provided):**
   If no plan ID is specified, show available plans for the current project:
   ```bash
   cc-plan plan list --project-path "$(pwd)"
   ```

3. **Handle No Plans Found:**
   If no plans are found for the current project:
   - Inform the user that no plans exist for this project
   - Suggest creating a new plan using the `/plan` command
   - Offer to attach to the project without a specific plan:
   ```bash
   cc-plan session set-active --project-path "$(pwd)" --session-id "$CLAUDE_SESSION_ID"
   ```

4. **Display Plan Options:**
   When listing plans, show:
   - Plan ID
   - Plan title/description
   - Creation date
   - Associated project path

   Provide clear instructions:
   - `/plan-attach <plan-id>` - Attach to specific plan
   - `/plan-attach` - Show available plans
   - Use `/plan` to create a new plan if needed

5. **Confirm Attachment:**
   After successful attachment, display:
   - Confirmation message with plan details
   - Brief summary of the attached plan
   - Next steps or recommendations for working with the plan

## Usage Examples

**Direct attachment:**
`/plan-attach user-auth-system`

**List and choose:**
`/plan-attach`

**Auto-attach to project:**
When no specific plan ID is provided and user confirms, attach session to current project path for general project work.
