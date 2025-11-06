#!/usr/bin/env bash
#
# Copyright (C) 2025 Robert Stupp
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

cd "${0%/*}/.."

. src/_build_functions.sh

dir="$(pwd)"

function gh_group() {
  if [[ -n ${GITHUB_ENV} ]]; then
    echo "::group::$*"
  else
    echo ""
    echo "** $*"
    echo ""
  fi
}

function gh_endgroup() {
  [[ -n ${GITHUB_ENV} ]] && echo "::endgroup::" || echo ""
}

function gh_summary() {
  if [[ -n ${GITHUB_ENV} ]]; then
    echo "$*" >> "${GITHUB_STEP_SUMMARY}"
  else
    echo "$*"
  fi
}

go_arch="$(go env GOARCH)"
go_os="$(go env GOOS)"

gh_summary "GOARCH: ${go_arch}"
gh_summary "GOOS: ${go_os}"

function check_license() {
  local component
  component="$1"
  sha256sum --check "${dir}/src/${component}-LICENSE.sha256" || (
    echo "Actual:"
    sha256sum LICENSE
    echo "Expected:"
    cat "${dir}/src/${component}-LICENSE.sha256"
    echo ""
    echo "${component} LICENSE file content follows:"
    cat LICENSE
    exit 1
  )
}

gh_group "MinIO build"
cd "${dir}/minio-source/"
check_license minio
go build
gh_endgroup

gh_group "mc build"
cd "${dir}/mc-source/"
check_license mc
go build
gh_endgroup

gh_group "console build"
cd "${dir}/console-source/"
check_license console
make console
gh_endgroup

gh_group "Copy stuff together"
cd "${dir}"
rm -rf build/image
arch_dir="build/image/${go_os}/${go_arch}"
mkdir -p "${arch_dir}"
mkdir -p "${arch_dir}/usr/bin"
cp \
  minio-source/minio \
  minio-source/dockerscripts/docker-entrypoint.sh \
  src/console-minio-entrypoint.sh \
  mc-source/mc \
  console-source/console \
  "${arch_dir}/usr/bin"
cp minio-source/LICENSE "${arch_dir}"/LICENSE.minio
cp minio-source/NOTICE "${arch_dir}"/NOTICE.minio
cp mc-source/LICENSE "${arch_dir}"/LICENSE.mc
cp mc-source/NOTICE "${arch_dir}"/NOTICE.mc
cp console-source/LICENSE "${arch_dir}"/LICENSE.console
cp console-source/NOTICE "${arch_dir}"/NOTICE.console
gh_endgroup
