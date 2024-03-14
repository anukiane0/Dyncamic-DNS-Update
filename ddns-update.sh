#!/bin/bash
auth_email=""                ## e-mail registered on Cloudflare                                       
auth_method=""               ## choose authorization method >> Token or Global               
auth_key=""                  ## Token key or Global Token key                        
zone_identifier=""           ## Zone ID found on cloudflare profile                 
record_name=""               ## DNS record name                     
ttl=""                       ## your choice     
proxy="false"                ## your choice                       
sitename=""                  ## website name                   

## Check and set the proper auth header
if [[ "${auth_method}" == "global" ]]; then
  auth_header="X-Auth-Key:"
else
  auth_header="Authorization: Bearer"
fi

## Seek for the A record

logger "DDNS Updater: Check Initiated"
record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name" \
                      -H "X-Auth-Email: $auth_email" \
                      -H "$auth_header $auth_key" \
                      -H "Content-Type: application/json")

## Check if the domain has an A record
old_ip=$(echo "$record" | sed -E 's/.*"content":"(([0-9]{1,3}\.){3}[0-9]{1,3})".*/\1/')
# Compare if they're the same
if [[ $ip == $old_ip ]]; then
  logger "DDNS Updater: IP ($ip) for ${record_name} has not changed."
  exit 0
fi

## set the record identifier from result
record_identifier=$(echo "$record" | sed -E 's/.*"id":"([A-Za-z0-9_]+)".*/\1/')

## changing IP using the cloudflare API
update=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
                     -H "X-Auth-Email: $auth_email" \
                     -H "$auth_header $auth_key" \
                     -H "Content-Type: application/json" \
                     --data "{\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":\"$ttl\",\"proxied\":${proxy}}")

