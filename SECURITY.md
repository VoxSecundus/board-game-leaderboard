# Security Policy

## Supported Versions

Only the latest version on the `master` branch receives security fixes.

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Email a report to **millard64@hotmail.co.uk** with:

- A description of the vulnerability
- Steps to reproduce it
- The potential impact

You can expect an acknowledgement within 7 days and a fix or mitigation plan within 30 days.

## Scope

In scope:

- Authentication bypass
- Insecure Direct Object Reference (IDOR)
- File upload exploits
- Cross-site scripting (XSS) or CSRF within the application

Out of scope:

- Vulnerabilities in Ruby, Rails, SQLite, or other upstream dependencies — please report those to the relevant upstream project
- Issues only exploitable by someone who already has the app password
- Denial-of-service attacks against a self-hosted instance
