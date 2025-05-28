#!/usr/bin/env bash
set -e
for dir in VerbiAuth VerbiDocuments VerbiLLM VerbiGateway; do
  echo "Starting $dir..."
  (cd $dir && docker-compose up -d --build)
done
