#!/bin/bash
current=""
tokenId=$(aws ssm --region 'eu-west-1'  get-parameter --name duck-token-id --query Parameter.Value | tr -d '"')
echo "Initializing token id: $tokenId"

while true; do
        latest=`ec2-metadata --public-ipv4`
        echo "public-ipv4=$latest"
        if [ "$current" == "$latest" ]
        then
                echo "ip not changed"
        else
                echo "ip has changed - updating"
                current=$latest
                echo url="https://www.duckdns.org/update?domains=gpresazzi-iot&token=$tokenId&ip=" | curl -k -o /tmp/duck.log -K -
        fi
        sleep 5m
done