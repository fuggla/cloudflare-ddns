#!/usr/bin/env bash

CFDDNS_API_TOKEN=<token>
CFDDNS_EMAIL=<account email>
CFDDNS_ZONE=<DNS zone>
CFDDNS_A_RECORD=<A record FQDN>

set -e

user_id=$(curl -s \
	-X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
	-H "Authorization: Bearer $CFDDNS_API_TOKEN" \
	-H "Content-Type:application/json" \
	| jq -r '{"result"}[] | .id')

zone_id=$(curl -s \
	-X GET "https://api.cloudflare.com/client/v4/zones?name=$CFDDNS_ZOME&status=active" \
	-H "Content-Type: application/json" \
	-H "X-Auth-Email: $CFDDNS_EMAIL" \
	-H "Authorization: Bearer $CFDDNS_API_TOKEN" \
	| jq -r '{"result"}[] | .[0] | .id')

record_data=$(curl -s \
	-X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A&name=$CFDDNS_A_RECORD"  \
	-H "Content-Type: application/json" \
	-H "X-Auth-Email: $CFDDNS_EMAIL" \
	-H "Authorization: Bearer $CFDDNS_API_TOKEN")

record_id=$(jq -r '{"result"}[] | .[0] | .id' <<< $record_data)
cf_ip=$(jq -r '{"result"}[] | .[0] | .content' <<< $record_data)
ext_ip=$(curl -s -X GET -4 https://ifconfig.co)

if [[ $cf_ip != $ext_ip ]]; then
	result=$(curl -s \
		-X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
		-H "Content-Type: application/json" \
		-H "X-Auth-Email: $CFDDNS_EMAIL" \
		-H "Authorization: Bearer $CFDDNS_API_TOKEN" \
		--data "{\"type\":\"A\",\"name\":\"$CFDDNS_A_RECORD\",\"content\":\"$ext_ip\",\"ttl\":1,\"proxied\":false}" \
		| jq .success)
	if [[ $result == "true" ]]; then
		echo "$CFDDNS_A_RECORD updated to: $ext_ip"
		exit 0
	else
		echo "$CFDDNS_A_RECORD update failed"
		exit 1
	fi
else
	# Uncomment to log even if record is up to date
	#echo "$CFDDNS_A_RECORD already up do date"
	exit 0
fi
