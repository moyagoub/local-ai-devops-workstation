#!/usr/bin/env bash
# Usage: source scripts/explain-log.sh
#        explain-log "$(cat failed-build.log)"

explain-log() {
  if [ -z "$1" ]; then
    echo "Usage: explain-log \"<error log text>\""
    return 1
  fi
  curl -s http://localhost:11434/api/generate \
    -d "$(jq -n --arg log "$1" '{model: "qwen2.5-coder:14b", prompt: ("Diagnose this Jenkins/DevOps error and give the exact fix:\n\n" + $log), stream: false}')" \
    | jq -r '.response'
}
