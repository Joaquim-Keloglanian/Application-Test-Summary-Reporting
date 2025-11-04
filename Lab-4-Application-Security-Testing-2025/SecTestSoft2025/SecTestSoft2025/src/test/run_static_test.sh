#!/usr/bin/env bash
set -euo pipefail

# run_static_tests.sh
# Runs a set of static analysis tools for the module and collects results under `results/`.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
MODULE_POM="$MODULE_DIR/pom.xml"
RESULTS_DIR="$SCRIPT_DIR/results"

mkdir -p "$RESULTS_DIR"

echo "Module directory: $MODULE_DIR"
echo "Results directory: $RESULTS_DIR"

run_mvn() {
  echo "\nRunning: mvn $*"
  mvn -f "$MODULE_POM" "$@" || echo "mvn $* failed (continuing)"
}

echo "1) Run PMD"
run_mvn pmd:pmd -DskipTests
if [ -d "$MODULE_DIR/target/site" ]; then
  cp -r "$MODULE_DIR/target/site" "$RESULTS_DIR/" || true
fi

echo "2) Run SpotBugs"
run_mvn spotbugs:spotbugs -DskipTests
cp -f "$MODULE_DIR/target/spotbugsXml.xml" "$RESULTS_DIR/" 2>/dev/null || true
cp -f "$MODULE_DIR/target/spotbugs.html" "$RESULTS_DIR/" 2>/dev/null || true

echo "3) Run Checkstyle"
run_mvn checkstyle:checkstyle -DskipTests
cp -f "$MODULE_DIR/target/site/checkstyle.html" "$RESULTS_DIR/" 2>/dev/null || true

echo "4) Run OWASP Dependency-Check"
run_mvn org.owasp:dependency-check-maven:check -DskipTests
cp -f "$MODULE_DIR/target/dependency-check-report.html" "$RESULTS_DIR/" 2>/dev/null || true

echo "5) Save Maven dependency tree"
run_mvn dependency:tree -DskipTests -DoutputType=text -DoutputFile="$RESULTS_DIR/dependency-tree.txt"

echo "6) Grep for risky patterns (SQL exec, request params, password)"
cd "$MODULE_DIR"
{
  git grep -n "Statement\|executeQuery\|executeUpdate\|createStatement" || true
  git grep -n "request.getParameter\|getParameter" || true
  git grep -n "password\|passwd\|secret\|token\|api_key" || true
} > "$RESULTS_DIR/patterns-grep.txt" || true

echo "7) Try truffleHog/detect-secrets (if installed)"
if command -v trufflehog >/dev/null 2>&1; then
  trufflehog filesystem --entropy=True "$MODULE_DIR" > "$RESULTS_DIR/trufflehog.txt" || true
elif command -v detect-secrets >/dev/null 2>&1; then
  (cd "$MODULE_DIR" && detect-secrets scan > "$RESULTS_DIR/detect-secrets.txt") || true
else
  echo "No secret scanner found (trufflehog/detect-secrets)." > "$RESULTS_DIR/secret-scanner-not-found.txt"
fi

echo "Static scans complete. Results are in: $RESULTS_DIR"
echo "Tip: archive the results directory and attach it to the static testing report."
#!/usr/bin/env bash
set -euo pipefail

# run_static_tests.sh
# Runs a set of static analysis tools for the module and collects results under `results/`.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
MODULE_POM="$MODULE_DIR/pom.xml"
RESULTS_DIR="$SCRIPT_DIR/results"

mkdir -p "$RESULTS_DIR"

echo "Module directory: $MODULE_DIR"
echo "Results directory: $RESULTS_DIR"

run_mvn() {
  echo "\nRunning: mvn $*"
  mvn -f "$MODULE_POM" "$@" || echo "mvn $* failed (continuing)"
}

echo "1) Run PMD"
run_mvn pmd:pmd -DskipTests
if [ -d "$MODULE_DIR/target/site" ]; then
  cp -r "$MODULE_DIR/target/site" "$RESULTS_DIR/" || true
fi

echo "2) Run SpotBugs"
run_mvn spotbugs:spotbugs -DskipTests
cp -f "$MODULE_DIR/target/spotbugsXml.xml" "$RESULTS_DIR/" 2>/dev/null || true
cp -f "$MODULE_DIR/target/spotbugs.html" "$RESULTS_DIR/" 2>/dev/null || true

echo "3) Run Checkstyle"
run_mvn checkstyle:checkstyle -DskipTests
cp -f "$MODULE_DIR/target/site/checkstyle.html" "$RESULTS_DIR/" 2>/dev/null || true

echo "4) Run OWASP Dependency-Check"
run_mvn org.owasp:dependency-check-maven:check -DskipTests
cp -f "$MODULE_DIR/target/dependency-check-report.html" "$RESULTS_DIR/" 2>/dev/null || true

echo "5) Save Maven dependency tree"
run_mvn dependency:tree -DskipTests -DoutputType=text -DoutputFile="$RESULTS_DIR/dependency-tree.txt"

echo "6) Grep for risky patterns (SQL exec, request params, password)"
cd "$MODULE_DIR"
{
  git grep -n "Statement\|executeQuery\|executeUpdate\|createStatement" || true
  git grep -n "request.getParameter\|getParameter" || true
  git grep -n "password\|passwd\|secret\|token\|api_key" || true
} > "$RESULTS_DIR/patterns-grep.txt" || true

echo "7) Try truffleHog/detect-secrets (if installed)"
if command -v trufflehog >/dev/null 2>&1; then
  trufflehog filesystem --entropy=True "$MODULE_DIR" > "$RESULTS_DIR/trufflehog.txt" || true
elif command -v detect-secrets >/dev/null 2>&1; then
  (cd "$MODULE_DIR" && detect-secrets scan > "$RESULTS_DIR/detect-secrets.txt") || true
else
  echo "No secret scanner found (trufflehog/detect-secrets)." > "$RESULTS_DIR/secret-scanner-not-found.txt"
fi

echo "Static scans complete. Results are in: $RESULTS_DIR"
echo "Tip: archive the results directory and attach it to the static testing report."
