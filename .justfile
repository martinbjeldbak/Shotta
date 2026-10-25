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
