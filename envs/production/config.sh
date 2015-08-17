#!/usr/bin/env bash
__envdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${__envdir}/../_default.sh 2>/dev/null || source ${__envdir}/_default.sh

export DEPLOY_ENV="production"
export NODE_ENV="production"
export DEBUG=""
