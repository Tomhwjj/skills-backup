---
name: restart-tomcat
description: Restart local Tomcat 8.0.48 server. Use when the user says "restart tomcat", "重启tomcat", "重启", "restart server", or after modifying Java/Servlet/JSP code that needs Tomcat reload. Kills the 8080 process, compiles and deploys hwjweb23 + SamSplitSystem projects from Eclipse workspace, then starts Tomcat.
---

# Restart Tomcat

Restart the local Apache Tomcat 8.0.48 server managed by Eclipse WTP.

## Usage

Run the bundled PowerShell script from the user's project directory:

```powershell
. ~/.agents/skills/restart-tomcat/scripts/restart-tomcat.ps1
```

## What it does

1. Kill any existing process on port 8080
2. Compile all Java files from `hwjweb23/src/` and `SamSplitSystem/src/`
3. Copy compiled classes (com, javabean, servlet) + JSP + common/ to the WTP deployment directory
4. Start Tomcat in the background
5. Wait until port 8080 is listening, then report ready

No arguments needed — paths are hardcoded for this machine.
