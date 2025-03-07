#!/bin/bash

# Copyright Istio Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# shellcheck disable=SC2086
WD=$(dirname $0)
WD=$(cd "${WD}"; pwd)
cd "${WD}"

set -ex

NAMESPACE=${1:?"namespace"}
NAMEPREFIX=${2:?"prefix name for service. typically svc-"}
INJECTION_LABEL=${3:-"istio-injection=enabled"}

HTTPS=${HTTPS:-"false"}

# Additional customization option for load client, e.g. "--set qps=200"
# LOADCLIENT_EXTRA_HELM_FLAGS=${LOADCLIENT_EXTRA_HELM_FLAGS:-""}

if [[ -z "${GATEWAY_URL:-}" ]];then
  if [[ -z "${GATEWAY_SERVICE_NAME:-}" ]];then
    GATEWAY_URL=$(kubectl -n servicemesh get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || true)
  else
    GATEWAY_URL=$(kubectl -n servicemesh get service "${GATEWAY_SERVICE_NAME}" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || true)
  fi
fi

SERVICEHOST="${NAMEPREFIX}0.local"

function run_test() {
  YAML=$(mktemp).yml
  # shellcheck disable=SC2086
  helm -n ${NAMESPACE} template \
	  --set serviceHost="${SERVICEHOST}" \
    --set Namespace="${NAMESPACE}" \
    --set ingress="${GATEWAY_URL}" \
    --set domain="${DNS_DOMAIN}" \
    --set https="${HTTPS}" \
    ${LOADCLIENT_EXTRA_HELM_FLAGS} \
          "${WD}" > "${YAML}"
  echo "Wrote ${YAML}"

  if [[ -z "${DELETE}" ]];then
    kubectl create ns "${NAMESPACE}" || true
    kubectl label namespace "${NAMESPACE}" "${INJECTION_LABEL}" --overwrite
    kubectl -n "${NAMESPACE}" apply -f "${YAML}"
  else
    kubectl -n "${NAMESPACE}" delete -f "${YAML}"
  fi
}

run_test
