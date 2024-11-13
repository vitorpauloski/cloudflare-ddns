#!/bin/bash

while true; do
    CURRENT_IP=$(curl -s https://ipv4.icanhazip.com)

    CLOUDFLARE_IP=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$CF_RECORD_ID" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" | jq -r .result.content)

    if [ "$CURRENT_IP" != "$CLOUDFLARE_IP" ]; then
        echo "IP has changed. Updating Cloudflare record."
        
        UPDATE_RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$CF_RECORD_ID" \
            -H "Authorization: Bearer $CF_API_TOKEN" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":60,\"proxied\":false}")
        
        if [[ $UPDATE_RESPONSE == *"\"success\":true"* ]]; then
            echo "Cloudflare DDNS updated successfully."
        else
            echo "Failed to update Cloudflare DDNS."
            echo "Response: $UPDATE_RESPONSE"
        fi
    else
        echo "IP has not changed. No update needed."
    fi

    sleep 60
done