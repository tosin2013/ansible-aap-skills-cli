#!/usr/bin/env bats
# tests/install.bats — bats test suite for install.sh
# Run: bats tests/install.bats

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
INSTALL_SH="${REPO_ROOT}/install.sh"

# Temporary home directory to isolate IDE path detection
setup() {
  export TMPDIR_HOME
  TMPDIR_HOME="$(mktemp -d)"
  export HOME="${TMPDIR_HOME}"
  # Simulate Cursor IDE presence for install tests
  mkdir -p "${HOME}/.cursor"
}

teardown() {
  rm -rf "${TMPDIR_HOME}"
}

# --------------------------------------------------------------------------- #
# list
# --------------------------------------------------------------------------- #

@test "list: prints header row" {
  run "${INSTALL_SH}" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"SKILL"* ]]
  [[ "$output" == *"VERSION"* ]]
  [[ "$output" == *"STATUS"* ]]
}

@test "list: shows all 6 skills" {
  run "${INSTALL_SH}" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"aap-config-structure"* ]]
  [[ "$output" == *"aap-secrets-management"* ]]
  [[ "$output" == *"aap-infra-roles"* ]]
  [[ "$output" == *"ee-yaml-schema"* ]]
  [[ "$output" == *"ee-build-workflow"* ]]
  [[ "$output" == *"ansible-good-practices"* ]]
}

@test "list: shows version 1.0.0 for all skills" {
  run "${INSTALL_SH}" list
  [ "$status" -eq 0 ]
  # count occurrences of 1.0.0 — should be at least 6
  count=$(echo "$output" | grep -c "1.0.0")
  [ "$count" -ge 6 ]
}

# --------------------------------------------------------------------------- #
# install --dry-run
# --------------------------------------------------------------------------- #

@test "install --dry-run: exits 0" {
  run "${INSTALL_SH}" install --dry-run
  [ "$status" -eq 0 ]
}

@test "install --dry-run: prints dry-run messages" {
  run "${INSTALL_SH}" install --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"dry-run"* ]]
}

@test "install --dry-run: does not create files in IDE path" {
  run "${INSTALL_SH}" install --dry-run --ide cursor
  [ "$status" -eq 0 ]
  # cursor skills dir should not exist yet
  [ ! -d "${HOME}/.cursor/skills" ]
}

# --------------------------------------------------------------------------- #
# install
# --------------------------------------------------------------------------- #

@test "install --skill aap-config-structure --ide cursor: copies skill directory" {
  run "${INSTALL_SH}" install --skill aap-config-structure --ide cursor
  [ "$status" -eq 0 ]
  [ -d "${HOME}/.cursor/skills/aap-config-structure" ]
}

@test "install --skill aap-config-structure --ide cursor: SKILL.md is present" {
  run "${INSTALL_SH}" install --skill aap-config-structure --ide cursor
  [ "$status" -eq 0 ]
  [ -f "${HOME}/.cursor/skills/aap-config-structure/SKILL.md" ]
}

@test "install --ide cursor: installs all skills" {
  run "${INSTALL_SH}" install --ide cursor
  [ "$status" -eq 0 ]
  [ -d "${HOME}/.cursor/skills/aap-config-structure" ]
  [ -d "${HOME}/.cursor/skills/aap-secrets-management" ]
  [ -d "${HOME}/.cursor/skills/aap-infra-roles" ]
  [ -d "${HOME}/.cursor/skills/ee-yaml-schema" ]
  [ -d "${HOME}/.cursor/skills/ee-build-workflow" ]
  [ -d "${HOME}/.cursor/skills/ansible-good-practices" ]
}

@test "install: always installs ansible-good-practices baseline" {
  run "${INSTALL_SH}" install --skill aap-config-structure --ide cursor
  [ "$status" -eq 0 ]
  [ -d "${HOME}/.cursor/skills/ansible-good-practices" ]
}

@test "install: references/ directory is copied" {
  run "${INSTALL_SH}" install --skill aap-config-structure --ide cursor
  [ "$status" -eq 0 ]
  [ -d "${HOME}/.cursor/skills/aap-config-structure/references" ]
}

# --------------------------------------------------------------------------- #
# verify
# --------------------------------------------------------------------------- #

@test "verify: fails when skills not installed" {
  run "${INSTALL_SH}" verify --ide cursor
  [ "$status" -ne 0 ]
}

@test "verify: passes after install" {
  "${INSTALL_SH}" install --ide cursor
  run "${INSTALL_SH}" verify --ide cursor
  [ "$status" -eq 0 ]
}

@test "verify: fails if SKILL.md is removed after install" {
  "${INSTALL_SH}" install --skill aap-infra-roles --ide cursor
  rm "${HOME}/.cursor/skills/aap-infra-roles/SKILL.md"
  run "${INSTALL_SH}" verify --skill aap-infra-roles --ide cursor
  [ "$status" -ne 0 ]
}

# --------------------------------------------------------------------------- #
# update
# --------------------------------------------------------------------------- #

@test "update: exits 0 when skill is installed" {
  "${INSTALL_SH}" install --skill ee-yaml-schema --ide cursor
  run "${INSTALL_SH}" update --skill ee-yaml-schema --ide cursor
  [ "$status" -eq 0 ]
}

@test "update: installs skill if not yet installed" {
  run "${INSTALL_SH}" update --skill ee-build-workflow --ide cursor
  [ "$status" -eq 0 ]
  [ -d "${HOME}/.cursor/skills/ee-build-workflow" ]
}

@test "update: skill is still valid after update" {
  "${INSTALL_SH}" install --skill ansible-good-practices --ide cursor
  "${INSTALL_SH}" update --skill ansible-good-practices --ide cursor
  run "${INSTALL_SH}" verify --skill ansible-good-practices --ide cursor
  [ "$status" -eq 0 ]
}

# --------------------------------------------------------------------------- #
# help / unknown commands
# --------------------------------------------------------------------------- #

@test "no args: prints usage" {
  run "${INSTALL_SH}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "--help: prints usage" {
  run "${INSTALL_SH}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Commands"* ]]
}

@test "unknown command: exits non-zero" {
  run "${INSTALL_SH}" frobnicate
  [ "$status" -ne 0 ]
}
