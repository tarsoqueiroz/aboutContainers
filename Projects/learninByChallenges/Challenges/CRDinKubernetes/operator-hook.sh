#!/usr/bin/env bash

if [[ $1 == "--config" ]] ; then
  cat <<EOF
configVersion: v1
kubernetes:
- apiVersion: tarsoqueiroz.io/v1
  kind: EmailNotifier
  executeHookOnEvent: ["Added", "Deleted"]
EOF
else
  notifierName=$(jq -r .[0].object.metadata.name $BINDING_CONTEXT_PATH)
  echo "Logic triggered for email notifier ${notifierName}"
fi
