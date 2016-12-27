#!/bin/sh
cat ./policy.json | openssl base64 | tr '+=/' '-_~'
