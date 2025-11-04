# Static Testing Helpers for SecTestSoft2025

This directory contains scripts and helpers to run automated static analysis for the SecTestSoft2025 module (login/authentication).

What this provides
- `run_static_test.sh`: A single bash script that runs a set of static scans (PMD, SpotBugs, Checkstyle, OWASP Dependency-Check) and collects results into `results/`.

Where to run
- The script is intended to be run from the repo on a machine with Maven installed and network access (for dependency-check DB download).

Quick start
```bash
cd Lab-4-Application-Security-Testing-2025/SecTestSoft2025/SecTestSoft2025/src/test/static-testing
./run_static_tests.sh
```

Outputs
- All generated reports are placed under `results/` inside this directory. Copy or archive these files for inclusion in the static testing report.

Notes
- Some tools (e.g., `dependency-check`, `trufflehog`) are optional and may need to be installed separately.
- The script tolerates individual tool failures and continues to collect whatever output is produced.
