---
name: add-email-to-apple-mail
description: Add an email account (Gmail, Outlook, etc.) to Apple Mail programmatically using a .mobileconfig profile and App Password. Bypasses OAuth entirely. Use this skill whenever the user wants to add an email to Apple Mail, configure Mail.app, set up a mail account on macOS, or connect Gmail/Outlook to their Mac's mail client. Also trigger when the user mentions "add my email", "set up mail", or "configure IMAP" in the context of Apple Mail or macOS.
user-invocable: true
---

# Add Email to Apple Mail

Programmatically add an email account to Apple Mail using a `.mobileconfig` profile with an App Password. This bypasses OAuth entirely, making the process fully automatable — the user only needs to click "Install" once in System Settings.

## Why App Passwords instead of OAuth

Apple Mail normally uses OAuth2 for Google/Microsoft accounts, which requires an interactive browser flow inside a system WebView that can't be automated. App Passwords are 16-character credentials that bypass OAuth and work with standard IMAP/SMTP authentication. The tradeoff is that 2FA must be enabled on the account (it usually already is).

## Parameters

Parse these from the user's request:

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `email` | yes | — | The email address to add |
| `display_name` | no | derived from email | Name shown in "From" field |
| `provider` | no | `gmail` | Email provider (determines server settings) |
| `browser_profile` | no | `zenex` | OpenClaw browser profile for Google auth |

## Provider Settings

| Provider | IMAP Server | IMAP Port | SMTP Server | SMTP Port | SSL |
|----------|-------------|-----------|-------------|-----------|-----|
| `gmail` | imap.gmail.com | 993 | smtp.gmail.com | 587 | yes |
| `outlook` | outlook.office365.com | 993 | smtp.office365.com | 587 | yes |
| `yahoo` | imap.mail.yahoo.com | 993 | smtp.mail.yahoo.com | 587 | yes |

## Step 1: Get Google Account Credentials

Use the vault to find the account's Google password (needed to access App Passwords settings):

```
openclaw_vault_search → find entries matching the email
openclaw_vault_get → retrieve the password for accounts.google.com
```

Look for the entry with URL matching `accounts.google.com` — that's the actual Google account password, not a site-specific one.

## Step 2: Generate App Password via OpenClaw

### Critical: Use an existing browser profile

Google blocks sign-in from headless or fresh Chrome profiles with "This browser or app may not be secure." You must use a profile that already has Google sessions (like `zenex`). Do NOT use the `openclaw` profile or start a fresh one for Google auth.

### Login flow

1. Navigate to `https://myaccount.google.com/apppasswords` using the browser profile
2. Google will ask for re-authentication — it may show an account chooser first
3. If the wrong account is shown, click "Switch account" or "Use another account"
4. Enter the email address, click Next
5. Enter the password from vault, click Next
6. You should land on the App Passwords page

### Generate the password

1. Find the "App name" text field and type a descriptive name (e.g. "Apple Mail")
2. Click "Create"
3. **Immediately capture the generated password** using JavaScript evaluation — the password appears in a dialog that can disappear if the tab changes:

```javascript
// Click Create, then poll for the password in the DOM
() => {
  const buttons = document.querySelectorAll('button');
  for (const btn of buttons) {
    if (btn.textContent.trim() === 'Create') { btn.click(); break; }
  }
  return new Promise((resolve) => {
    let attempts = 0;
    const interval = setInterval(() => {
      attempts++;
      const spans = document.querySelectorAll('span, div, p');
      for (const el of spans) {
        const text = el.textContent.trim();
        if (text.match(/^[a-z]{4}\s+[a-z]{4}\s+[a-z]{4}\s+[a-z]{4}$/)) {
          clearInterval(interval);
          resolve(text);
          return;
        }
      }
      if (attempts > 50) { clearInterval(interval); resolve('timeout'); }
    }, 200);
  });
}
```

4. The password format is 4 groups of 4 lowercase letters with spaces (e.g. `noot vwls ehvb wzhv`). When used in config, **remove spaces** → `nootvwlsehvbwzhv`.

### If you miss the password

If the tab switches or the dialog disappears before you capture it, revoke the app password you just created (click the trash icon next to it) and create a new one. Use the JS evaluation approach above to capture it atomically.

## Step 3: Create .mobileconfig Profile

Write an XML plist file to the Desktop. The key payload type is `com.apple.mail.managed`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>EmailAccountDescription</key>
            <string>{{ACCOUNT_DESCRIPTION}}</string>
            <key>EmailAccountName</key>
            <string>{{DISPLAY_NAME}}</string>
            <key>EmailAccountType</key>
            <string>EmailTypeIMAP</string>
            <key>EmailAddress</key>
            <string>{{EMAIL}}</string>
            <key>IncomingMailServerAuthentication</key>
            <string>EmailAuthPassword</string>
            <key>IncomingMailServerHostName</key>
            <string>{{IMAP_HOST}}</string>
            <key>IncomingMailServerPortNumber</key>
            <integer>{{IMAP_PORT}}</integer>
            <key>IncomingMailServerUseSSL</key>
            <true/>
            <key>IncomingMailServerUsername</key>
            <string>{{EMAIL}}</string>
            <key>IncomingPassword</key>
            <string>{{APP_PASSWORD_NO_SPACES}}</string>
            <key>OutgoingMailServerAuthentication</key>
            <string>EmailAuthPassword</string>
            <key>OutgoingMailServerHostName</key>
            <string>{{SMTP_HOST}}</string>
            <key>OutgoingMailServerPortNumber</key>
            <integer>{{SMTP_PORT}}</integer>
            <key>OutgoingMailServerUseSSL</key>
            <true/>
            <key>OutgoingMailServerUsername</key>
            <string>{{EMAIL}}</string>
            <key>OutgoingPassword</key>
            <string>{{APP_PASSWORD_NO_SPACES}}</string>
            <key>PayloadDescription</key>
            <string>Email account for {{EMAIL}}</string>
            <key>PayloadDisplayName</key>
            <string>{{ACCOUNT_DESCRIPTION}}</string>
            <key>PayloadIdentifier</key>
            <string>com.apple.mail.managed.{{SANITIZED_EMAIL}}</string>
            <key>PayloadType</key>
            <string>com.apple.mail.managed</string>
            <key>PayloadUUID</key>
            <string>{{GENERATE_UUID}}</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
        </dict>
    </array>
    <key>PayloadDescription</key>
    <string>Configures email for {{EMAIL}}</string>
    <key>PayloadDisplayName</key>
    <string>{{ACCOUNT_DESCRIPTION}}</string>
    <key>PayloadIdentifier</key>
    <string>com.custom.email-profile.{{SANITIZED_EMAIL}}</string>
    <key>PayloadOrganization</key>
    <string>{{DISPLAY_NAME}}</string>
    <key>PayloadRemovalDisallowed</key>
    <false/>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadUUID</key>
    <string>{{GENERATE_UUID_2}}</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
</dict>
</plist>
```

**Template variables:**
- `{{SANITIZED_EMAIL}}` — email with `@` and `.` replaced by `-` (e.g. `michaelabdo-mail-gmail-com`)
- `{{GENERATE_UUID}}` — use `uuidgen` command to generate unique UUIDs
- `{{ACCOUNT_DESCRIPTION}}` — e.g. "Gmail - michaelabdo.mail"

Generate UUIDs with:
```bash
uuidgen  # run twice, one for each PayloadUUID
```

## Step 4: Install the Profile

```bash
open /Users/Mike/Desktop/Gmail-AppleMail.mobileconfig
```

This opens System Settings → General → Device Management. Tell the user to click **Install** and enter their Mac password.

**This is the one manual step** — macOS requires user consent to install configuration profiles. There's no way to bypass this, and that's a good security property.

## Step 5: Verify

After the user confirms they installed:

```bash
# Check the profile is installed
profiles -L 2>/dev/null | grep -i gmail

# Check Apple Mail has the account
osascript -e 'tell application "Mail" to get name of every account'
```

Both should show the new account. Present the result to the user.

## Cleanup

The `.mobileconfig` file on the Desktop is no longer needed after installation — the profile is stored in macOS's profile manager. Mention this to the user but don't delete it without asking.
