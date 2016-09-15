#!/bin/sh
cat ./policy.json | openssl sha1 -sign ./private_pk.pem | openssl base64 | tr '+=/' '-_~'
