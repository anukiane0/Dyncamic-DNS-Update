#!/bin/bash

auth_email=""                                        ## Cloudflare account email
auth_method=""                                       ## Recommended Authorization Method - API Token
auth_key=""                                          ## API Token key
zone_identifier=""                                   ## Each registered domain on cloudflare has its own Zone ID
record_name=""                                       ## Record name 
ttl=""                                               ## set TTL
proxy=""                                             ## Boolean for Proxy
sitename=""                                          ## website name

ip=$(curl -s https://api.ipify.org || curl -s https://ipv4.icanhazip.com)

if [[ "${auth_method}" == "global" ]]; then
  auth_header="X-Auth-Key:"
else
  auth_header="Authorization: Bearer"
fi

record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name" \
                      -H "X-Auth-Email: $auth_email" \
                      -H "$auth_header $auth_key" \
                      -H "Content-Type: application/json")

old_ip=$(echo "$record" | sed -E 's/.*"content":"(([0-9]{1,3}\.){3}[0-9]{1,3})".*/\1/')

record_identifier=$(echo "$record" | sed -E 's/.*"id":"([A-Za-z0-9_]+)".*/\1/')

update=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
                     -H "X-Auth-Email: $auth_email" \
                     -H "$auth_header $auth_key" \
                     -H "Content-Type: application/json" \
                     --data "{\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":\"$ttl\",\"proxied\":${proxy}}")
