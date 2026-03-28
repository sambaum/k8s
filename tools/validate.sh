#!/usr/bin/env bash

# This script downloads the Flux OpenAPI schemas, then it validates the
# Flux custom resources and the kustomize overlays using kubeconform.
# This script is meant to be run locally and in CI before the changes
# are merged on the main branch that's synced by Flux.

# Copyright 2020 The Flux authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script is meant to be run locally and in CI to validate the Kubernetes
# manifests (including Flux custom resources) before changes are merged into
# the branch synced by Flux in-cluster.

# Source: https://github.com/fluxcd/flux2-monitoring-example/blob/main/scripts/validate.sh

TOOLS_DIR="${HOME}/.local/bin"
mkdir -p "${TOOLS_DIR}"
export PATH="${TOOLS_DIR}:$PATH"
YQ_VERSION="v4.52.5"
YQ_BIN="${TOOLS_DIR}/yq"
KUBECONFORM_VERSION="v0.7.0"
KUBECONFORM_BIN="${TOOLS_DIR}/kubeconform"

EXCLUDE_DIRS=("archive" "foobar")
EXCLUDE_ARGS=()
for dir in "${EXCLUDE_DIRS[@]}"; do
	EXCLUDE_ARGS+=(-path "./$dir" -prune -o)
done

if ! command -v yq >/dev/null 2>&1 || ! yq --version 2>/dev/null | grep -q 'mikefarah'; then
	echo "INFO - Installing yq (Mike Farah)"

	curl -sL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o "${YQ_BIN}"
	chmod +x "${YQ_BIN}"
fi

if ! command -v kubeconform >/dev/null 2>&1 || ! kubeconform -v 2>/dev/null | grep -q "${KUBECONFORM_VERSION}"; then
	echo "INFO - Installing kubeconform ${KUBECONFORM_VERSION}"

	TMP_DIR="$(mktemp -d)"

	curl -sL "https://github.com/yannh/kubeconform/releases/download/${KUBECONFORM_VERSION}/kubeconform-linux-amd64.tar.gz" |
		tar -xzf - -C "${TMP_DIR}"

	mv "${TMP_DIR}/kubeconform" "${KUBECONFORM_BIN}"
	chmod +x "${KUBECONFORM_BIN}"

	rm -rf "${TMP_DIR}"
fi

set -o errexit

echo "INFO - Downloading Flux OpenAPI schemas"
mkdir -p /tmp/flux-crd-schemas/master-standalone-strict
curl -sL https://github.com/fluxcd/flux2/releases/latest/download/crd-schemas.tar.gz | tar zxf - -C /tmp/flux-crd-schemas/master-standalone-strict

echo "INFO - Validating YAML syntax..."
find . "${EXCLUDE_ARGS[@]}" -type f -name '*.yaml' -print0 | while IFS= read -r -d $'\0' file; do
	# echo "INFO - Validating $file"
	yq e 'true' "$file" >/dev/null
done

kubeconform_config=("-strict" "-ignore-missing-schemas" "-schema-location" "default" "-schema-location" "/tmp/flux-crd-schemas" "-skip=Secret") # "-verbose"

echo "INFO - Validating clusters"
find ./clusters -maxdepth 2 "${EXCLUDE_ARGS[@]}" -type f -name '*.yaml' -print0 | while IFS= read -r -d $'\0' file; do
	kubeconform "${kubeconform_config[@]}" "${file}"
	if [[ ${PIPESTATUS[0]} != 0 ]]; then
		exit 1
	fi
done

# mirror kustomize-controller build options
kustomize_flags=("--load-restrictor=LoadRestrictionsNone")
kustomize_config="kustomization.yaml"

echo "INFO - Validating kustomize overlays"
find . "${EXCLUDE_ARGS[@]}" -type f -name $kustomize_config -print0 | while IFS= read -r -d $'\0' file; do
	# echo "INFO - Validating kustomization ${file/%$kustomize_config/}"
	kustomize build "${file/%$kustomize_config/}" "${kustomize_flags[@]}" |
		kubeconform "${kubeconform_config[@]}"
	if [[ ${PIPESTATUS[0]} != 0 ]]; then
		exit 1
	fi
done
