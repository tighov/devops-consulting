#!/usr/bin/env bash
set -euo pipefail

BASEDIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${1:-$BASEDIR/config.env}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found: $CONFIG_FILE"
    exit 1
fi

set -a
# shellcheck source=/dev/null
source "$CONFIG_FILE"
set +a

echo "Domain: ${DOMAIN_NAME}"
echo ""

# Get hosted zone NS
ZONE_ID=$(aws route53 list-hosted-zones-by-name \
    --dns-name "${DOMAIN_NAME}" \
    --query "HostedZones[?Name=='${DOMAIN_NAME}.'].Id" \
    --output text)

if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" = "None" ]; then
    echo "ERROR: No Route53 hosted zone found for ${DOMAIN_NAME}"
    exit 1
fi

ZONE_NS=$(aws route53 get-hosted-zone \
    --id "$ZONE_ID" \
    --query "DelegationSet.NameServers" \
    --output text)

# Get domain registration NS
REG_NS=$(aws route53domains get-domain-detail \
    --domain-name "${DOMAIN_NAME}" \
    --query "Nameservers[].Name" \
    --output text \
    --region us-east-1)

# Sort and compare
ZONE_SORTED=$(echo "$ZONE_NS" | tr '\t' '\n' | sort)
REG_SORTED=$(echo "$REG_NS" | tr '\t' '\n' | sort)

echo "Hosted zone NS:"
echo "$ZONE_SORTED" | sed 's/^/  /'
echo ""
echo "Domain registration NS:"
echo "$REG_SORTED" | sed 's/^/  /'
echo ""

if [ "$ZONE_SORTED" = "$REG_SORTED" ]; then
    echo "Nameservers already match. Nothing to do."
    exit 0
fi

echo "MISMATCH detected. Updating domain registration..."
echo ""

# Build --nameservers argument
NS_ARGS=""
for ns in $ZONE_NS; do
    NS_ARGS="${NS_ARGS} Name=${ns}"
done

aws route53domains update-domain-nameservers \
    --domain-name "${DOMAIN_NAME}" \
    --nameservers $NS_ARGS \
    --region us-east-1

echo ""
echo "Done. Nameservers updated. Propagation may take a few minutes."
echo "Check with: dig NS ${DOMAIN_NAME} +short"
