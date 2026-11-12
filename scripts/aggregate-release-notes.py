#!/usr/bin/env python3
"""Collects the release notes of all amadeOS repositories into one file per amadeOS release.

Usage: scripts/aggregate-release-notes.py [VERSION ...]   (no VERSION: every amadeOS release)

Writes docs/releases/<VERSION>.md and the index docs/releases/README.md.

Every repository in repositories.list has its own version and its own GitHub Releases, whose text
the release workflow of amadeos-ci writes from the Conventional Commits. An amadeOS release contains
the newest release of each repository that existed when Promote finished for that amadeOS release.
Promote releases amadeos and the other repositories within a few minutes, in no fixed order, so a
repository release belongs to amadeOS X.Y.Z when it was published after the previous amadeOS release
plus the grace period and at most the grace period after amadeOS X.Y.Z itself.

docs/releases/highlights/<VERSION>.md, when present, is put at the top as hand-written highlights.

The GitHub API is read without a token (60 requests an hour, enough for one run) or with
GITHUB_TOKEN / GH_TOKEN when set.
The workflow .github/workflows/release-notes.yml runs it for each new release once the grace period is over.
"""
import datetime
import json
import os
import re
import sys
import urllib.error
import urllib.request

OWNER = "amadeos-eu"
GRACE = datetime.timedelta(minutes=60)
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "docs", "releases")
VERSION_TAG = re.compile(r"^v(\d+)\.(\d+)\.(\d+)$")


def read_repositories():
    """Returns [(group, [repo, ...]), ...] from repositories.list, with amadeos itself first."""
    groups = [("amadeOS image and User's Handbook", ["amadeos"])]
    group = None
    with open(os.path.join(ROOT, "repositories.list"), encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("# ") and not line.startswith("# The ") and len(line) < 80:
                title = re.sub(r"\s*\(.*\)$", "", line[2:])
                if title[:1].isupper():
                    group = (title, [])
                    groups.append(group)
            elif line and not line.startswith("#") and group:
                group[1].append(line.split("#")[0].strip())  # "amade-x-game  # optional"
    return [g for g in groups if g[1]]


def fetch_releases(repo):
    url = f"https://api.github.com/repos/{OWNER}/{repo}/releases?per_page=100"
    request = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json"})
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        request.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            data = json.load(response)
    except (urllib.error.URLError, ValueError) as error:
        print(f"warning: no releases read for {repo}: {error}", file=sys.stderr)
        return []
    if not isinstance(data, list):
        print(f"warning: no releases read for {repo}: {data.get('message')}", file=sys.stderr)
        return []
    releases = []
    for item in data:
        if item.get("draft") or item.get("prerelease") or not VERSION_TAG.match(item["tag_name"]):
            continue
        releases.append({
            "version": item["tag_name"][1:],
            "published": datetime.datetime.fromisoformat(item["published_at"].replace("Z", "+00:00")),
            "body": (item.get("body") or "").strip(),
            "url": item["html_url"],
        })
    releases.sort(key=lambda r: r["published"])
    return releases


def version_key(version):
    return tuple(int(x) for x in version.split("."))


def demote_headings(body):
    """The repository notes use '## Features'; inside a repository section they become '####'."""
    return re.sub(r"^## ", "#### ", body, flags=re.M)


def render(version, amadeos_releases, groups, releases):
    index = [r["version"] for r in amadeos_releases].index(version)
    this = amadeos_releases[index]
    until = this["published"] + GRACE
    since = amadeos_releases[index - 1]["published"] + GRACE if index > 0 else None
    previous = amadeos_releases[index - 1]["version"] if index > 0 else None

    def state(repo, limit):
        if limit is None:
            return None
        older = [r for r in releases[repo] if r["published"] <= limit]
        return older[-1]["version"] if older else None

    lines = [f"# amadeOS {version}", ""]
    lines.append(f"Released on {this['published']:%-d %B %Y}. "
                 + (f"Changes since amadeOS {previous} in every repository of the distribution."
                    if previous else "The first release of amadeOS."))
    lines.append("")
    lines.append(f"[Release page of amadeos {version}]({this['url']}) · the newest image: "
                 "[www.amadeos.eu/download.html](https://www.amadeos.eu/download.html)")
    lines.append("")

    highlights = os.path.join(OUT, "highlights", f"{version}.md")
    if os.path.exists(highlights):
        with open(highlights, encoding="utf-8") as f:
            lines += ["## Highlights", "", f.read().strip(), ""]

    changed, table = [], []
    for title, repos in groups:
        for repo in repos:
            before = state(repo, since)
            in_window = [r for r in releases[repo]
                         if r["published"] <= until and (since is None or r["published"] > since)]
            now = in_window[-1]["version"] if in_window else before
            if now is None:
                continue
            if not in_window:
                table.append((repo, now, "unchanged"))
            elif before is None:
                table.append((repo, now, "new" if previous else ""))
            else:
                table.append((repo, now, f"from {before}"))
            if in_window:
                changed.append((title, repo, in_window))

    changed_rows = [row for row in table if row[2] != "unchanged"]
    lines += ["## Versions", "", "| Repository | Version | Before |", "|---|---|---|"]
    for repo, now, note in changed_rows:
        before = note.replace("from ", "") if note.startswith("from ") else note
        lines.append(f"| [{repo}](https://github.com/{OWNER}/{repo}) | {now} | {before} |")
    lines.append("")
    unchanged = [f"{repo} {now}" for repo, now, note in table if note == "unchanged"]
    if unchanged:
        lines += ["Unchanged: " + ", ".join(unchanged) + ".", ""]

    current_group = None
    for title, repo, in_window in changed:
        if title != current_group:
            lines += [f"## {title}", ""]
            current_group = title
        # Newest first, each repository release with its own notes.
        for release in reversed(in_window):
            lines.append(f"### {repo} [{release['version']}]({release['url']})")
            lines.append("")
            body = demote_headings(release["body"])
            lines.append(body if body else "No user-visible changes.")
            lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def main():
    groups = read_repositories()
    repos = [repo for _, members in groups for repo in members]
    releases = {repo: fetch_releases(repo) for repo in repos}
    amadeos_releases = releases["amadeos"]
    if not amadeos_releases:
        sys.exit("No releases of amadeos found")
    known = [r["version"] for r in amadeos_releases]
    wanted = sys.argv[1:] or known
    os.makedirs(OUT, exist_ok=True)
    for version in wanted:
        version = version.lstrip("v")
        if version not in known:
            sys.exit(f"amadeos has no release {version} (known: {', '.join(known)})")
        path = os.path.join(OUT, f"{version}.md")
        with open(path, "w", encoding="utf-8") as f:
            f.write(render(version, amadeos_releases, groups, releases))
        print(f"wrote {os.path.relpath(path, ROOT)}")

    present = sorted((name[:-3] for name in os.listdir(OUT)
                      if re.match(r"^\d+\.\d+\.\d+\.md$", name)), key=version_key, reverse=True)
    dates = {r["version"]: r["published"] for r in amadeos_releases}
    index = ["# amadeOS releases", "",
             "What changed in each release of amadeOS, collected from the release notes of all its",
             "repositories (desktop, applications, games, libraries and installer). Written by",
             "`scripts/aggregate-release-notes.py` (workflow Release notes, after each release); each repository's own notes",
             "are on its GitHub Releases page.",
             ""]
    for version in present:
        date = f" ({dates[version]:%-d %B %Y})" if version in dates else ""
        index.append(f"- [amadeOS {version}]({version}.md){date}")
    with open(os.path.join(OUT, "README.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(index) + "\n")


if __name__ == "__main__":
    main()
