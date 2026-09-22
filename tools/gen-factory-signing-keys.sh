#!/bin/bash

FACTORY_SIGNING_KEY_FILE=factory-signing.key.pem
FACTORY_VALIDATION_PUB_FILE=factory-validation.pub.pem

log() { echo "$@" >&2 ; }
fatal() { echo "$@" >&2 ; exit 1 ; }

# main

for i in FACTORY_SIGNING_KEY_FILE FACTORY_VALIDATION_PUB_FILE ; do
	[ ! -e "${!i}" ] || fatal "Existing $i=${!i} found: aborting"
done

openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 \
				-out "$FACTORY_SIGNING_KEY_FILE" ||
	fatal "Cannot generate factory signing private key"

openssl pkey -in "$FACTORY_SIGNING_KEY_FILE" \
		-pubout -out "$FACTORY_VALIDATION_PUB_FILE" ||
	fatal "Cannot generate factory signing public key"

chmod 600 "$FACTORY_SIGNING_KEY_FILE" ||
	fatal "Cannot set permissions to private key: $FACTORY_SIGNING_KEY_FILE"

log "key pair: $FACTORY_SIGNING_KEY_FILE - $FACTORY_VALIDATION_PUB_FILE"
