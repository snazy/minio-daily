#!/usr/bin/env bash
#
# Copyright (C) 2023 Robert Stupp
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

# Github workflow provides these values, so only set those when running the script "locally".
[ -z "${img_basename}" ] && exit 1
[ -z "${minio_version}" ] && exit 1
[ -z "${console_version}" ] && exit 1

gh_group "Prepare buildx"
docker buildx use default
docker buildx create \
  --platform linux/amd64,linux/arm64 \
  --use \
  --name miniobuild \
  --driver-opt network=host || docker buildx use miniobuild
# Note: '--driver-opt network=host' is needed to be able to push to a local registry (e.g. localhost:5000)
gh_endgroup

gh_group "Docker buildx info"
docker buildx inspect
gh_endgroup

gh_group "buildx options"
img_name="${img_basename}"
if [[ "${PUSH_OPT}" == "true" ]]; then
  echo "Will push image to ghcr.io"
  img_name="ghcr.io/snazy/minio-daily"
  buildx_args="--output=type=registry"
fi
if [[ ${minio_version} =~ RELEASE.* ]]; then
  buildx_args="${buildx_args} --tag ${img_name}:latest"
fi

gh_endgroup

gh_group "buildx build"
lbl_name="Unofficual, unsupported daily MinIO + mc + console build"
lbl_desc="Unofficial, unsupported build. Includes minio@${minio_git_ref} and mc@${mc_git_ref} and console@${console_git_ref}."
# The (many) labels arguments also override some of the labels coming from the base image.
docker buildx \
  build \
  $buildx_args \
  --no-cache \
  --tag "${img_name}:${minio_version}" \
  --annotation "index,manifest:org.opencontainers.image.title=${lbl_name}" \
  --annotation "index,manifest:org.opencontainers.image.description=${lbl_desc}" \
  --annotation "index,manifest:org.opencontainers.image.licenses=AGPL-3.0" \
  --annotation "index,manifest:org.opencontainers.image.version=${minio_version}" \
  --annotation "index,manifest:org.opencontainers.image.created=$(date "+%Y.%m.%dT%H.%M.%SZ")" \
  --annotation "index,manifest:org.opencontainers.image.url=https://github.com/snazy/minio-daily" \
  --annotation "index,manifest:url=https://github.com/snazy/minio-daily" \
  --annotation "index,manifest:org.opencontainers.image.source=https://github.com/minio/minio" \
  --annotation "index,manifest:org.opencontainers.image.revision=${minio_git_ref}" \
  --annotation "index,manifest:minio.git-ref=${minio_git_ref}" \
  --annotation "index,manifest:mc.git-ref=${mc_git_ref}" \
  --annotation "index,manifest:console.git-ref=${console_git_ref}" \
  --annotation "index,manifest:io.k8s.display-name=${lbl_name}" \
  --annotation "index,manifest:io.k8s.description=${lbl_desc}" \
  --annotation "index,manifest:io.openshift.tags=minimal rhel9 minio" \
  --annotation "index,manifest:name=${lbl_name}" \
  --annotation "index,manifest:summary=${lbl_desc}" \
  --annotation "index,manifest:version=${minio_version}" \
  --annotation "index,manifest:maintainer=" \
  --annotation "index,manifest:vcs-ref=" \
  --annotation "index,manifest:release=${minio_release}" \
  --annotation "index,manifest:vendor=" \
  --platform=linux/arm64,linux/amd64 \
  --provenance=false \
  --sbom=false \
  --file src/Dockerfile \
  build/image
gh_endgroup

gh_group "buildx prune"
docker buildx prune -f
gh_endgroup

gh_summary "## Image tags, built for ${PLATFORMS}"
gh_summary "* \`${img_name}:latest\`"
gh_summary "* \`${img_name}${minio_version}\`"
