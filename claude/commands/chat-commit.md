---
description: Commit changes made during this chat session with project-specific commit guidelines
allowed-tools: Bash(git:*), Bash(cat:*), Bash(grep:*), Read(*), Glob(*)
model: claude-sonnet-4-5-20250929
---

# Chat Commit Command

Commit changes made during this chat session, following project-specific commit guidelines and conventions.

## User's Request
$ARGUMENTS

## Instructions

1. **Check Project-Specific Commit Guidelines:**
   First, look for commit guidelines in common locations:
   - Check CLAUDE.md files (both global and project-specific)
   - Check for CONTRIBUTING.md, COMMIT_CONVENTION.md, or similar files
   - Look for `.gitmessage` or commit message templates
   - Check if there's a `.git/hooks/commit-msg` hook with requirements

   ```bash
   # Check for CLAUDE.md instructions
   if [ -f "CLAUDE.md" ]; then cat CLAUDE.md | grep -i "commit\|git" -A 5 -B 2; fi

   # Check for contributing guidelines
   find . -maxdepth 2 -iname "*contributing*" -o -iname "*commit*convention*" 2>/dev/null
   ```

2. **Check for Special Branch Handling:**
   Determine if the current branch has special commit requirements:

   ```bash
   git branch --show-current
   ```

   - If on `gitbutler/workspace` branch: DO NOT commit automatically (per CLAUDE.md instructions)
   - If on feature branch: Include branch context in commit message
   - If on main/master: Ensure commit message is thorough and well-formatted

3. **Analyze Changes:**
   Review what was changed during this chat session:

   ```bash
   # Check status
   git status

   # View changes
   git diff
   git diff --staged

   # Check recent commit history for message style
   git log --oneline -10
   git log -3 --pretty=format:"%s%n%b"
   ```

4. **Determine Change Type:**
   Based on the diff and changes, categorize the commit:
   - `feat:` - New feature or functionality
   - `fix:` - Bug fix
   - `refactor:` - Code refactoring without functional changes
   - `docs:` - Documentation changes
   - `test:` - Test additions or modifications
   - `chore:` - Build, configuration, or maintenance tasks
   - `style:` - Code style/formatting changes
   - `perf:` - Performance improvements

5. **Draft Commit Message:**
   Create a commit message following these principles:
   - Follow project-specific conventions (from step 1)
   - Match the style of recent commits (from step 3)
   - Use conventional commits format if the project uses it
   - Focus on the "why" not just the "what"
   - Keep the first line concise (50-72 characters)
   - Add detailed explanation in body if needed
   - Include co-authorship attribution:
     ```

     > Generated with [Claude Code](https://claude.com/claude-code)

     Co-Authored-By: Claude <noreply@anthropic.com>
     ```

6. **Handle Arguments:**
   If the user provided custom arguments:
   - Use custom commit message if provided: `/chat-commit "custom message"`
   - Use `--amend` if explicitly requested: `/chat-commit --amend`
   - Use `--no-verify` only if explicitly requested (and warn about it)
   - Support `--dry-run` to preview without committing

7. **Stage and Commit Changes:**
   ```bash
   # Add relevant changes (exclude sensitive files like .env, credentials.json)
   git add .

   # Create commit with heredoc for proper formatting
   git commit -m "$(cat <<'EOF'
   [Your commit message here]

   > Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"

   # Verify commit
   git log -1
   git status
   ```

8. **Handle Special Cases:**

   **GitButler Workspace:**
   - If on `gitbutler/workspace` branch, skip automatic commit
   - Inform user: "Currently on gitbutler/workspace branch. Per project guidelines, skipping automatic commit. Please use GitButler UI to commit changes."

   **No Changes to Commit:**
   - Check if there are any changes
   - If none, inform user: "No changes detected to commit."

   **Pre-commit Hook Modifications:**
   - If pre-commit hooks modify files:
   - Check if safe to amend (verify authorship and not pushed)
   - Either amend or create a new commit for hook changes

   **Sensitive Files:**
   - Warn if attempting to commit files like:
     - `.env`, `.env.local`, `.env.*`
     - `credentials.json`, `secrets.*`
     - Private keys, tokens, passwords
   - Ask for confirmation before proceeding

9. **Post-Commit Actions:**
   After successful commit:
   - Display commit summary
   - Show what was committed
   - Do NOT push automatically (unless user explicitly requested)
   - Remind user to push if needed: `git push` or `git push -u origin [branch]`

10. **Error Handling:**

    **Merge Conflicts:**
    - Detect if in merge/rebase state
    - Guide user to resolve conflicts first

    **Commit Failures:**
    - Show clear error messages
    - Suggest solutions (e.g., fix pre-commit hook issues)

    **Permission Issues:**
    - Check if git repository is writable
    - Verify git config is set up

## Usage Examples

**Simple commit (auto-generate message):**
`/chat-commit`

**Commit with custom message:**
`/chat-commit "Add user authentication feature"`

**Amend previous commit:**
`/chat-commit --amend`

**Preview without committing:**
`/chat-commit --dry-run`

**Commit specific files only:**
`/chat-commit src/auth.ts src/utils.ts`

## Response Format

**Success Response:**
```
 Changes committed successfully

Commit: a1b2c3d
Message: feat: Add user authentication with OAuth2 support

Files changed:
  M src/auth/oauth.ts
  M src/middleware/auth.ts
  A tests/auth.test.ts

=¡ Next steps:
" Review the commit: git show
" Push changes: git push
```

**GitButler Workspace Response:**
```
  Currently on gitbutler/workspace branch

Per project guidelines, automatic commits are disabled on this branch.
Please use the GitButler UI to commit your changes.

Changes ready to commit:
  M src/auth.ts
  M src/utils.ts
```

**No Changes Response:**
```
9 No changes detected to commit

Working directory is clean. All changes have already been committed.
```

**Error Response:**
```
L Failed to commit changes

Error: [error message]

Troubleshooting:
" Ensure you have write permissions
" Check if git user.name and user.email are configured
" Resolve any merge conflicts if present
" Review pre-commit hook failures
```

## Important Reminders

- ALWAYS check for project-specific commit guidelines in CLAUDE.md
- NEVER commit on `gitbutler/workspace` branch
- NEVER commit sensitive files (.env, credentials, etc.)
- ALWAYS include Claude co-authorship attribution
- ALWAYS match the project's existing commit message style
- NEVER push automatically unless explicitly requested
- ALWAYS respond in English regardless of user's language
