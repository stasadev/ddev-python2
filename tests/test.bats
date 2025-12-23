#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=ddev/ddev-python2

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p "${HOME}/tmp"
  export TESTDIR="$(mktemp -d "${HOME}/tmp/${PROJNAME}.XXXXXX")"
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success

  export USE_CUSTOM_NODE=false
}

health_checks() {
  run ddev exec python --version
  assert_success
  assert_output "Python 2.7.18"

  run ddev exec python2 --version
  assert_success
  assert_output "Python 2.7.18"

  run ddev exec python2.7 --version
  assert_success
  assert_output "Python 2.7.18"

  run ddev exec pip --version
  assert_success
  assert_output "pip 20.0.2 from /usr/local/lib/python2.7/site-packages/pip (python 2.7)"

  run ddev exec pip2 --version
  assert_success
  assert_output "pip 20.0.2 from /usr/local/lib/python2.7/site-packages/pip (python 2.7)"

  run ddev exec pip2.7 --version
  assert_success
  assert_output "pip 20.0.2 from /usr/local/lib/python2.7/site-packages/pip (python 2.7)"

  run ddev exec python -c "import hashlib; print('MD5:', hashlib.md5('test').hexdigest())"
  assert_success
  assert_output "('MD5:', '098f6bcd4621d373cade4e832627b4f6')"

  run ddev exec python -c "import ssl; print('SSL:', ssl.OPENSSL_VERSION)"
  assert_success
  assert_output "('SSL:', 'OpenSSL 1.1.1d  10 Sep 2019')"

  if [ "${USE_CUSTOM_NODE:-}" = "true" ]; then
    run ddev exec node -v
    assert_success
    assert_output --regexp "^v18\\.\\d+\\.\\d+$"
  fi
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

@test "install with node v18" {
  set -eu -o pipefail

  export USE_CUSTOM_NODE=true
  run ddev config --nodejs-version=v18
  assert_success

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
