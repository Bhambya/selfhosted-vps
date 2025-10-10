#!/bin/bash

set -euo pipefail

docker exec crowdsec cscli hub update && docker exec crowdsec cscli hub upgrade
