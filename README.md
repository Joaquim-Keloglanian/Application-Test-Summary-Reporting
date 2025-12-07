# SecSoftTest (iShop) — Run & Troubleshoot Guide

🔧 This README describes exact steps to build, run, and test the SecSoftTest (iShop) web application locally using the Maven tomcat7 plugin on Windows (Git Bash or PowerShell). It also documents fixes made (servlet mapping and servlet API compatibility) and common troubleshooting steps.

---

## Prerequisites

- Java JDK (recommended: 15) installed and `JAVA_HOME` set and in PATH.
- Apache Maven 3.x installed and available on PATH.
- Git (if you need to clone the repository).
- A free port for running Tomcat (default: 8080).

Note: This project runs on Tomcat 7 (Servlet API `javax.servlet`) in the maven plugin. To use Jakarta Servlet `jakarta.servlet.*` (Tomcat 10+), see the "Jakarta vs Javax" section.

---

## Prepare and build

1) Open Git Bash, PowerShell, or CMD and change to the app root (where the `pom.xml` is):

```bash
# Example path - adapt to your workspace
cd "Lab-4-Application-Security-Testing-2025/SecTestSoft2025/SecTestSoft2025"
```

2) If the app server is running on port 8080, stop it or pick a different port (see Troubleshooting section).

3) Build (create WAR):

```bash
mvn clean package -DskipTests
```

You should see a WAR built at:
```
target/SecSoftTest-0.0.1-SNAPSHOT.war
```

---

## Run with Maven Tomcat plugin (Embedded)

There are two ways to run the embedded Tomcat plugin:

A) Use the tomcat plugin defined in `pom.xml` (recommended):

```bash
mvn tomcat7:run
```

B) If you have prefix resolution problems, use full coordinates:

```bash
mvn org.apache.tomcat.maven:tomcat7-maven-plugin:2.2:run
```

- To stop the plugin gracefully if started in the foreground: press `Ctrl+C` in that terminal
- To run on a different port (if you'd prefer 8081): edit the `pom.xml` plugin configuration (add `<port>8081</port>`) or change the plugin execution parameter if applicable.

---

## Quick verification (curl)

- Check the welcome page (login HTML):

```bash
curl -I http://localhost:8080/ishop/login.html
```

- Log in with form POST (the webapp returns JSON on success):

```bash
curl -i -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=alfred.sapine@ggmail.com&password=password" \
  http://localhost:8080/ishop/Logins
```

- To persist session cookies:

```bash
curl -c cookies.txt -i -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "username=...&password=..." http://localhost:8080/ishop/Logins
```

---

## Important fixes and code details

1) Servlet mapping

- The login form (`login.html`) posts to `action="Logins"`.
- To ensure the servlet catches that, `web.xml` was updated to map `/Logins` to the `Logins` servlet.
- Also removed the `@WebServlet` annotation from `Logins.java` (we rely on `web.xml`) to avoid duplicate mappings (Tomcat 7 throws an error if both exist).

2) Servlet API compatibility

- Tomcat 7 uses `javax.servlet.*`. This project originally used `jakarta.servlet.*` imports (Tomcat 10+), so we changed the dependency to `javax.servlet-api:3.0.1` and updated `Logins.java` to use `javax.servlet.*` imports.
- If you want to use Tomcat 10/Jakarta Servlet instead, revert the `pom.xml` and code changes and run using a Tomcat 10 environment or plugin.

---

## Changing the WAR name (optional)

If you want the produced WAR to be `target/ishop.war` automatically, set `<finalName>shop</finalName>` in the `pom.xml` build section, e.g.:

```xml
<build>
  <finalName>ishop</finalName>
  ...
</build>
```

Then run `mvn package` and you'll find `target/ishop.war`.

---

## Change the Tomcat plugin port

Edit the `pom.xml` plugin configuration for `tomcat7-maven-plugin` adding a `<port>` entry:

```xml
<plugin>
  <groupId>org.apache.tomcat.maven</groupId>
  <artifactId>tomcat7-maven-plugin</artifactId>
  <version>2.2</version>
  <configuration>
    <port>8081</port>
    <path>/ishop</path>
    ...
  </configuration>
</plugin>
```

Restart with `mvn tomcat7:run` and browse http://localhost:8081/ishop.

---

## Troubleshooting

1) Address already in use (BindException) on 8080

- Check who is using the port:

```bash
netstat -aon | findstr :8080
# Example output shows PID (e.g. 5816) listening on 8080
```

- Find the process for the PID (Windows CMD):

```cmd
tasklist /FI "PID eq 5816"
```

- Kill the process if safe:

```cmd
taskkill /PID 5816 /F
```

- Or stop the Windows service that is using 8080 via Services (services.msc) or `sc stop <serviceName>`.

2) 404 on login URL

- Confirm the correct mapping: use `http://localhost:8080/ishop/Logins` because `web.xml` maps it to `/Logins`.

3) 500 with ClassNotFoundException: jakarta.servlet.http.HttpServlet

- This indicates a mismatched API: either change imports to `javax.servlet.*` (Tomcat 7) or run under Tomcat 10+ that supports `jakarta.servlet.*`.

4) Duplicate servlet mapping error complaining both mapped to `/Logins`

- Remove one of the mappings: either the `@WebServlet` annotation in `Logins.java` or the `web.xml` entry. We use `web.xml` mapping and removed the `@WebServlet` annotation in the code in this project.

5) Clean build fails because `target/tomcat/logs/access_log...` is not deletable

- Stop the running Tomcat instance that holds the logs, then re-run `mvn clean`.

6) `No plugin found for prefix 'tomcat7'` error

- Use full plugin coordinates to run the plugin: 

```bash
mvn org.apache.tomcat.maven:tomcat7-maven-plugin:2.2:run
```

This bypasses prefix lookup issues.

---

## Security notes ⚠️

- Don't use simple passwords like `password` in production or deploy unpatched or debug configurations with real data.
- The repository contains a `Logins` example that uses SQL with string concatenation — watch out for SQL injection in other contexts; tests were done with the existing setup.

---

## Useful developer commands (Windows - Git Bash / PowerShell / CMD)

```bash
# Go to project
cd "Lab-4-Application-Security-Testing-2025/SecTestSoft2025/SecTestSoft2025"

# Build
mvn clean package -DskipTests

# Run (if plugin prefix works)
mvn tomcat7:run

# Run using plugin should prefix fail
mvn org.apache.tomcat.maven:tomcat7-maven-plugin:2.2:run

# Stop the running process
# If you started Tomcat in a terminal: Ctrl+C
# If you must kill a PID with PowerShell / CMD:
netstat -aon | findstr :8080
tasklist /FI "PID eq <PID>"
taskkill /PID <PID> /F

# Test login endpoint
curl -i -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "username=alfred.sapine@ggmail.com&password=password" http://localhost:8080/ishop/Logins

# Capture cookie and JSON response
curl -c cookies.txt -i -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "username=alfred.sapine@ggmail.com&password=password" http://localhost:8080/ishop/Logins
```

---

If you want, I can:
- Add `<finalName>ishop</finalName>` to `pom.xml`
- Add `<port>` to the tomcat plugin in `pom.xml` for a default port change
- Revert to Jakarta imports and provide steps for Tomcat 10 plugin/runtime

Tell me what you prefer and I’ll make the changes and test them.