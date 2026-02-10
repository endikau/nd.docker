import json
import os
import subprocess
import sys
import yaml


def run(cmd, cwd=None):
    print(f"[deploy] $ {' '.join(cmd)}")
    subprocess.run(cmd, cwd=cwd, check=True)


def load_payload(payload_path: str):
    with open(payload_path, "r", encoding="utf-8") as f:
        return json.load(f)


def extract_repo(payload):
    repo = (payload.get("repository") or {}).get("full_name")
    if repo:
        return repo
    wr = payload.get("workflow_run") or {}
    repo = (wr.get("repository") or {}).get("full_name")
    if repo:
        return repo
    return None


def extract_ref(payload):
    if "ref" in payload:
        return payload["ref"]
    wr = payload.get("workflow_run") or {}
    hb = wr.get("head_branch")
    if hb:
        return f"refs/heads/{hb}"
    return None


def main():
    arg = sys.argv[1] if len(sys.argv) > 1 else ""
    payload_file = arg.split("=", 1)[1] if arg.startswith("payload=") else arg

    if not payload_file or not os.path.isfile(payload_file):
        print("[deploy] missing payload file arg (expected payload=/path)", file=sys.stderr)
        return 1

    payload = load_payload(payload_file)
    repo = extract_repo(payload)
    ref = extract_ref(payload)

    if not repo:
        print("[deploy] no repository.full_name in payload", file=sys.stderr)
        return 2

    with open("/config/config.yml", "r", encoding="utf-8") as f:
        cfg = yaml.safe_load(f) or {}

    repo_cfg = (cfg.get("repos") or {}).get(repo)
    if not repo_cfg:
        print(f"[deploy] ignored (not allowlisted): {repo}")
        return 0

    branch = repo_cfg.get("branch", "main")
    if ref and ref != f"refs/heads/{branch}":
        print(f"[deploy] ignored (branch mismatch): {ref} != refs/heads/{branch}")
        return 0

    repo_dir = repo_cfg["dir"]
    url = f"https://github.com/{repo}.git"

    print(f"[deploy] repo={repo} branch={branch} dir={repo_dir}")

    git_dir = os.path.join(repo_dir, ".git")
    if not os.path.isdir(git_dir):
        os.makedirs(repo_dir, exist_ok=True)
        run(["git", "clone", "--depth=1", "--branch", branch, url, repo_dir])
    else:
        run(["git", "fetch", "origin", branch], cwd=repo_dir)
        run(["git", "reset", "--hard", f"origin/{branch}"], cwd=repo_dir)
        run(["git", "clean", "-fd"], cwd=repo_dir)

    comp = repo_cfg.get("compose") or {}
    if comp.get("enabled"):
        compose_file = comp.get("file", "compose.yml")
        project_name = comp.get("project_name", repo.replace("/", "_"))
        run(["docker", "compose", "-p", project_name, "-f", compose_file, "pull"], cwd=repo_dir)
        run(["docker", "compose", "-p", project_name, "-f", compose_file, "up", "-d", "--remove-orphans"], cwd=repo_dir)

    print("[deploy] ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
