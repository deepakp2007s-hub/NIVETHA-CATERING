
from __future__ import annotations

import ast
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from datetime import datetime, timezone


ROOT = Path(__file__).resolve().parent
APP_DIR = ROOT / "app"
TEST_DIR = ROOT / "tests"
REPORT_DIR = ROOT / "audit_reports"

EXCLUDED_DIRS = {
    ".venv",
    "venv",
    "__pycache__",
    ".git",
    ".pytest_cache",
    "node_modules",
    "audit_reports",
}

ISSUES: list[dict] = []
FILE_REPORTS: list[dict] = []


def add_issue(level: str, file: Path, message: str) -> None:
    try:
        display_path = str(file.relative_to(ROOT))
    except ValueError:
        display_path = str(file)

    ISSUES.append({
        "level": level,
        "file": display_path,
        "message": message,
    })


def python_files(directory: Path):
    if not directory.exists():
        return

    for file in directory.rglob("*.py"):
        if any(part in EXCLUDED_DIRS for part in file.parts):
            continue

        yield file


def run_command(command: list[str], timeout: int = 180) -> dict:
    try:
        result = subprocess.run(
            command,
            cwd=ROOT,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )

        return {
            "command": " ".join(command),
            "returncode": result.returncode,
            "stdout": result.stdout[-12000:],
            "stderr": result.stderr[-12000:],
        }

    except FileNotFoundError:
        return {
            "command": " ".join(command),
            "returncode": -1,
            "stdout": "",
            "stderr": "Command or executable not found.",
        }

    except subprocess.TimeoutExpired:
        return {
            "command": " ".join(command),
            "returncode": -1,
            "stdout": "",
            "stderr": f"Command timed out after {timeout} seconds.",
        }


def check_syntax(file: Path) -> None:
    try:
        source = file.read_text(encoding="utf-8-sig")
        ast.parse(source, filename=str(file))

    except SyntaxError as exc:
        add_issue(
            "CRITICAL",
            file,
            f"Syntax error at line {exc.lineno}: {exc.msg}",
        )

    except (OSError, UnicodeError) as exc:
        add_issue("ERROR", file, f"Cannot read file: {exc}")


def check_security_patterns(file: Path) -> None:
    try:
        source = file.read_text(encoding="utf-8-sig")
    except (OSError, UnicodeError):
        return

    patterns = [
        (
            r"\beval\s*\(",
            "Potentially unsafe eval() usage.",
        ),
        (
            r"\bexec\s*\(",
            "Potentially unsafe exec() usage.",
        ),
        (
            r"\bpickle\.loads\s*\(",
            "Unsafe pickle deserialization requires review.",
        ),
        (
            r"\bverify\s*=\s*False\b",
            "TLS certificate verification appears disabled.",
        ),
        (
            r"\ballow_origins\s*=\s*\[\s*['\"]\*['\"]",
            "Wildcard CORS origin requires review.",
        ),
        (
            r"\bpassword\s*=\s*['\"][^'\"]{6,}['\"]",
            "Possible hardcoded password. Verify manually.",
        ),
        (
            r"\b(?:SECRET_KEY|JWT_SECRET|API_KEY)\s*=\s*['\"][^'\"]{8,}['\"]",
            "Possible hardcoded secret. Verify manually.",
        ),
    ]

    for pattern, message in patterns:
        for match in re.finditer(pattern, source, re.IGNORECASE):
            line = source.count("\n", 0, match.start()) + 1

            add_issue(
                "WARNING",
                file,
                f"Line {line}: {message}",
            )


def inspect_file(file: Path) -> None:
    try:
        source = file.read_text(encoding="utf-8-sig")
        tree = ast.parse(source, filename=str(file))

        functions = [
            node.name
            for node in ast.walk(tree)
            if isinstance(
                node,
                (ast.FunctionDef, ast.AsyncFunctionDef),
            )
        ]

        classes = [
            node.name
            for node in ast.walk(tree)
            if isinstance(node, ast.ClassDef)
        ]

        imports = [
            node.module or ""
            for node in ast.walk(tree)
            if isinstance(node, ast.ImportFrom)
        ]

        routes = []

        for node in ast.walk(tree):
            if not isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                continue

            for decorator in node.decorator_list:
                if isinstance(decorator, ast.Call):
                    func = decorator.func

                    if isinstance(func, ast.Attribute):
                        method = func.attr.upper()

                        if method in {
                            "GET",
                            "POST",
                            "PUT",
                            "PATCH",
                            "DELETE",
                        }:
                            routes.append({
                                "method": method,
                                "handler": node.name,
                                "line": node.lineno,
                            })

        FILE_REPORTS.append({
            "file": str(file.relative_to(ROOT)),
            "lines": len(source.splitlines()),
            "functions": functions,
            "classes": classes,
            "imports": imports,
            "routes": routes,
        })

        check_syntax(file)
        check_security_patterns(file)

    except (SyntaxError, OSError, UnicodeError) as exc:
        add_issue("ERROR", file, str(exc))


def check_project_structure() -> None:
    required_files = [
        "app/main.py",
        "app/core/config.py",
        "app/core/security.py",
        "app/db/mongo.py",
        "app/api/auth.py",
        "app/api/customers.py",
        "app/api/profiles.py",
        "app/api/foods.py",
        "app/api/bookings.py",
        "app/api/reviews.py",
        "app/api/notifications.py",
        "app/api/reports.py",
        "app/api/health.py",
        "tests/conftest.py",
        "tests/test_api.py",
    ]

    for relative_path in required_files:
        file = ROOT / relative_path

        if not file.is_file():
            add_issue(
                "ERROR",
                file,
                "Required project file is missing.",
            )


def audit_python_files() -> None:
    files = list(python_files(APP_DIR))

    if not files:
        add_issue("CRITICAL", APP_DIR, "No application Python files found.")
        return

    for file in files:
        inspect_file(file)

    print(f"Scanned {len(files)} application Python files.")


def run_static_analysis() -> dict:
    print("\nRunning Ruff...")
    ruff = run_command([
        sys.executable,
        "-m",
        "ruff",
        "check",
        "app",
        "tests",
        "--output-format",
        "json",
    ])

    print("\nRunning Bandit...")
    bandit = run_command([
        sys.executable,
        "-m",
        "bandit",
        "-r",
        "app",
        "-f",
        "json",
        "-q",
    ])

    return {
        "ruff": ruff,
        "bandit": bandit,
    }


def run_pytest() -> dict:
    print("\nRunning backend tests...")

    return run_command([
        sys.executable,
        "-m",
        "pytest",
        "-v",
    ], timeout=300)


def summarize() -> dict:
    counts = {
        "CRITICAL": 0,
        "ERROR": 0,
        "WARNING": 0,
    }

    for issue in ISSUES:
        counts[issue["level"]] = (
            counts.get(issue["level"], 0) + 1
        )

    return {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "project": ROOT.name,
        "python_version": sys.version,
        "summary": counts,
        "files": FILE_REPORTS,
        "issues": ISSUES,
    }


def main() -> int:
    print("=" * 60)
    print("NIVETHA CATERING BACKEND AUDIT")
    print("=" * 60)

    if not APP_DIR.is_dir():
        print("ERROR: Run this script from the backend project.")
        return 1

    REPORT_DIR.mkdir(exist_ok=True)

    print("\nChecking project structure...")
    check_project_structure()

    print("\nScanning Python files...")
    audit_python_files()

    print("\nRunning static analysis...")
    static_results = run_static_analysis()

    print("\nRunning tests...")
    test_results = run_pytest()

    report = summarize()

    report["static_analysis"] = static_results
    report["pytest"] = test_results

    report_path = REPORT_DIR / "backend_audit.json"

    report_path.write_text(
        json.dumps(report, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )

    print("\n" + "=" * 60)
    print("AUDIT SUMMARY")
    print("=" * 60)

    print(f"Critical issues : {report['summary']['CRITICAL']}")
    print(f"Errors          : {report['summary']['ERROR']}")
    print(f"Warnings        : {report['summary']['WARNING']}")

    print("\nPytest exit code:", test_results["returncode"])
    print("Ruff exit code:", static_results["ruff"]["returncode"])
    print("Bandit exit code:", static_results["bandit"]["returncode"])

    print("\nReport saved to:")
    print(report_path)

    if report["summary"]["CRITICAL"] or report["summary"]["ERROR"]:
        return 1

    if test_results["returncode"] != 0:
        return 1

    if static_results["ruff"]["returncode"] not in {0, 1}:
        return 1

    if static_results["bandit"]["returncode"] not in {0, 1}:
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
