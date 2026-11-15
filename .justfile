#!/usr/bin/env -S just --justfile

set minimum-version := '1.55.0'

set default-list
set lazy
set quiet
set shell := ['bash', '-euo', 'pipefail', '-c']
set script-interpreter := ['bash', '-euo', 'pipefail']

mise_exec := 'mise exec --'

# Lint Recipes
[doc('Run every linter and formatting check (same as the Lua CI job)')]
[group('Lint')]
lint: doctor luacheck selene fmt-check just-check

[doc('Lint Lua sources with Luacheck')]
[group('Lint')]
luacheck:
    {{ mise_exec }} luacheck .

[doc('Lint Lua sources with Selene')]
[group('Lint')]
selene:
    {{ mise_exec }} selene .

[doc('Check Lua formatting with StyLua')]
[group('Lint')]
fmt-check:
    {{ mise_exec }} stylua --check .

[doc('Check GitHub Actions workflows with actionlint')]
[group('Lint')]
actionlint:
    {{ mise_exec }} actionlint .github/workflows/*.yml

[doc('Check that the justfile is formatted')]
[group('Lint')]
just-check:
    {{ mise_exec }} just --justfile {{ justfile() }} --fmt --check --unstable

# Format Recipes
[doc('Format Lua sources with StyLua')]
[group('Format')]
fmt:
    {{ mise_exec }} stylua .

[doc('Format the justfile')]
[group('Format')]
just-fmt:
    {{ mise_exec }} just --justfile {{ justfile() }} --fmt --unstable

# Check Recipes
[doc('Run all checks, including workflows')]
[group('Check')]
check: lint actionlint

# Release Recipes
[doc('Tag HEAD as v<version> and push the tag to start the release workflow (e.g. just release 2.9.1)')]
[group('Release')]
release version:
    #!/usr/bin/env -S bash -uo pipefail
    set -e
    input='{{ version }}'
    version="${input#v}"
    if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+([-+][0-9a-zA-Z.-]+)?$ ]]; then
        echo "Not a version: ${input}" >&2
        echo "Usage: just release 2.9.1" >&2
        exit 1
    fi
    tag="v${version}"
    if git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
        echo "Tag ${tag} already exists." >&2
        exit 1
    fi
    if [[ $(git rev-parse --abbrev-ref HEAD) != "main" ]]; then
        echo "Not on main (currently on $(git rev-parse --abbrev-ref HEAD))." >&2
        exit 1
    fi
    git fetch --quiet origin "main:refs/remotes/origin/main"
    if [[ $(git rev-parse HEAD) != $(git rev-parse refs/remotes/origin/main) ]]; then
        echo "HEAD ($(git rev-parse --short HEAD)) is not the tip of origin/main ($(git rev-parse --short refs/remotes/origin/main))." >&2
        echo "Switch to main and pull first." >&2
        exit 1
    fi
    latest=$(git tag --list 'v*.*.*' --sort=-v:refname | head -n1)
    if [[ -n $latest ]] && [[ $(printf '%s\n%s\n' "${latest#v}" "${version}" | sort -V | tail -n1) != "$version" ]]; then
        echo "${version} is not newer than the latest tag ${latest}." >&2
        exit 1
    fi
    if git ls-remote --exit-code --tags origin "refs/tags/${tag}" >/dev/null 2>&1; then
        echo "Tag ${tag} already exists on the remote." >&2
        exit 1
    fi
    echo "Tagging $(git rev-parse --short HEAD) as ${tag} (previous: ${latest:-none})"
    git tag -a "${tag}" -m "${tag}"
    git push origin "refs/tags/${tag}"

# Setup Recipes
[doc('Install the pinned tools with mise')]
[group('Setup')]
setup:
    mise install

[doc('Verify mise and the lint tools are available')]
[group('Setup')]
[script]
doctor:
    command -v mise >/dev/null || { echo "mise is not installed: https://mise.jdx.dev" >&2; exit 1; }
    for tool in luacheck selene stylua; do
        mise which "$tool" >/dev/null 2>&1 || { echo "Missing tool: $tool (run 'just setup')" >&2; exit 1; }
    done
