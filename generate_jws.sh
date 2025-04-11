#!/usr/bin/env bash

set -o pipefail

pem=$( cat $1 ) # file path of the private key as first argument

b64enc() { openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'; }

header_json='{"alg":"ES256","typ":"JWT","kid":"'$2'"}'
# Header encode
header=$( echo -n "${header_json}" | b64enc )

payload_json='{"iss":"'$3'","iat":'$(date +%s)',"exp":'$(date -v+180d +%s)'}'
# Payload encode
payload=$( echo -n "${payload_json}" | b64enc )

# Signature
header_payload="${header}"."${payload}"

signature=$(
    openssl dgst -sha256 -sign <(echo -n "${pem}") \
    <(echo -n "${header_payload}") | b64enc
)

# Create JWT
JWT="${header_payload}"."${signature}"
printf '%s\n' "JWT: $JWT"
