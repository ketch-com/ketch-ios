#!/usr/bin/env python3
"""Switch Examples/KetchSDKSample between SPM from GitHub and the local ketch-ios checkout."""

from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

PACKAGE_REF_ID = "D07A58632E5D3B500071EF50"
DEFAULT_REPO_URL = "https://github.com/ketch-com/ketch-ios.git"


def parse_semver_tag(tag: str) -> tuple[int, int, int] | None:
    """Return (major, minor, patch) for tags like 4.6.0 or v4.6.0; else None."""
    m = re.fullmatch(r"v?(\d+)\.(\d+)\.(\d+)", tag.strip())
    if not m:
        return None
    return int(m.group(1)), int(m.group(2)), int(m.group(3))


def latest_git_tag(repo_url: str) -> str:
    """Highest X.Y.Z tag on the remote (SwiftPM source of truth, not CocoaPods)."""
    proc = subprocess.run(
        ["git", "ls-remote", "--tags", repo_url],
        check=False,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        raise SystemExit(
            f"git ls-remote failed ({proc.returncode}) for {repo_url!r}:\n{proc.stderr.strip()}"
        )

    best_tag: str | None = None
    best_key: tuple[int, int, int] | None = None

    for line in proc.stdout.splitlines():
        parts = line.split()
        if len(parts) != 2:
            continue
        ref = parts[1]
        if not ref.startswith("refs/tags/"):
            continue
        raw = ref[len("refs/tags/") :]
        if raw.endswith("^{}"):
            continue
        key = parse_semver_tag(raw)
        if key is None:
            continue
        if best_key is None or key > best_key:
            best_key = key
            best_tag = raw

    if not best_tag:
        raise SystemExit(
            f"No semver tags found on {repo_url!r}. "
            "Set KETCH_IOS_SPM_VERSION to pin a version, or KETCH_IOS_SPM_BRANCH to track a branch."
        )
    return best_tag


def local_section() -> str:
    return f"""/* Begin XCLocalSwiftPackageReference section */
\t\t{PACKAGE_REF_ID} /* XCLocalSwiftPackageReference "../.." */ = {{
\t\t\tisa = XCLocalSwiftPackageReference;
\t\t\trelativePath = "../..";
\t\t}};
/* End XCLocalSwiftPackageReference section */"""


def remote_section_exact(version: str, repo_url: str) -> str:
    return f"""/* Begin XCRemoteSwiftPackageReference section */
\t\t{PACKAGE_REF_ID} /* XCRemoteSwiftPackageReference "ketch-ios" */ = {{
\t\t\tisa = XCRemoteSwiftPackageReference;
\t\t\trepositoryURL = "{repo_url}";
\t\t\trequirement = {{
\t\t\t\tkind = exactVersion;
\t\t\t\tversion = {version};
\t\t\t}};
\t\t}};
/* End XCRemoteSwiftPackageReference section */"""


def remote_section_branch(branch: str, repo_url: str) -> str:
    safe = branch.replace("\\", "\\\\").replace('"', '\\"')
    return f"""/* Begin XCRemoteSwiftPackageReference section */
\t\t{PACKAGE_REF_ID} /* XCRemoteSwiftPackageReference "ketch-ios" */ = {{
\t\t\tisa = XCRemoteSwiftPackageReference;
\t\t\trepositoryURL = "{repo_url}";
\t\t\trequirement = {{
\t\t\t\tkind = branch;
\t\t\t\tbranch = "{safe}";
\t\t\t}};
\t\t}};
/* End XCRemoteSwiftPackageReference section */"""


def replace_package_block(content: str, new_block: str) -> str:
    patterns = [
        r"/\* Begin XCLocalSwiftPackageReference section \*/.*?/\* End XCLocalSwiftPackageReference section \*/",
        r"/\* Begin XCRemoteSwiftPackageReference section \*/.*?/\* End XCRemoteSwiftPackageReference section \*/",
    ]
    for pat in patterns:
        if re.search(pat, content, flags=re.DOTALL):
            return re.sub(pat, new_block, content, count=1, flags=re.DOTALL)
    raise SystemExit("No Swift package reference block found in project.pbxproj")


def sync_package_references_line(content: str, mode: str) -> str:
    line_re = re.compile(
        rf"^(\t\t\t\t{PACKAGE_REF_ID} /\* )([^*]+)( \*/,)$",
        flags=re.MULTILINE,
    )
    if not line_re.search(content):
        raise SystemExit("Could not find packageReferences entry for KetchSDK package")

    if mode == "local":
        middle = 'XCLocalSwiftPackageReference "../.."'
    elif mode == "remote":
        middle = 'XCRemoteSwiftPackageReference "ketch-ios"'
    else:
        raise SystemExit(f"Unknown mode: {mode}")

    return line_re.sub(lambda m: m.group(1) + middle + m.group(3), content, count=1)


def remote_block_for_env(repo_url: str) -> tuple[str, str]:
    """Returns (pbxproj_block, human_summary)."""
    branch = os.environ.get("KETCH_IOS_SPM_BRANCH", "").strip()
    if branch:
        return remote_section_branch(branch, repo_url), f"branch={branch!r}"

    version = (
        os.environ.get("KETCH_IOS_SPM_VERSION", "").strip()
        or os.environ.get("KETCH_IOS_SPM_EXACT_VERSION", "").strip()
    )
    if version:
        return remote_section_exact(version, repo_url), f"exactVersion={version!r}"

    tag = latest_git_tag(repo_url)
    return remote_section_exact(tag, repo_url), f"exactVersion={tag!r} (latest semver tag)"


def main() -> None:
    if len(sys.argv) != 4:
        raise SystemExit(
            "Usage: configure-sample-package.py <local|remote> <path-to-project.pbxproj> <repo-root>"
        )

    mode = sys.argv[1]
    pbx_path = Path(sys.argv[2])
    _ = Path(sys.argv[3])  # repo root (kept for CLI compatibility)

    if mode not in ("local", "remote"):
        raise SystemExit("mode must be local or remote")

    if not pbx_path.is_file():
        raise SystemExit(f"Missing project file: {pbx_path}")

    repo_url = os.environ.get("KETCH_IOS_SPM_REPO_URL", DEFAULT_REPO_URL)

    original = pbx_path.read_text(encoding="utf-8")
    if mode == "local":
        updated = replace_package_block(original, local_section())
        summary = "local package (../..)"
    else:
        block, summary = remote_block_for_env(repo_url)
        updated = replace_package_block(original, block)

    updated = sync_package_references_line(updated, mode)

    if updated != original:
        pbx_path.write_text(updated, encoding="utf-8")
        if mode == "local":
            print(f"Updated {pbx_path} to use local KetchSDK package (../..).")
        else:
            print(f"Updated {pbx_path} to use remote KetchSDK package ({summary}, repo={repo_url!r}).")
    else:
        print(f"No changes needed for {pbx_path} ({mode}).")


if __name__ == "__main__":
    main()
