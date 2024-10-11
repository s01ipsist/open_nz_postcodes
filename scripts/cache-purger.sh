#!/bin/bash

# Define the cache key to look for
CACHE_KEY="Linux-nz-koordinates"

# Get the current time in epoch format
CURRENT_TIME=$(date +%s)

# List caches, filter by key, and process each result
# https://cli.github.com/manual/gh_cache_list
gh cache list --json key,createdAt,id | jq -c ".[] | select(.key == \"$CACHE_KEY\")" | while read -r cache; do
  # Extract the cache ID and creation timestamp
  CACHE_ID=$(echo "$cache" | jq -r '.id')
  CREATED_AT=$(echo "$cache" | jq -r '.createdAt')

  # Convert the creation time to epoch format
  CREATED_AT_EPOCH=$(date -d "$CREATED_AT" +%s)

  # Calculate the age of the cache in seconds
  AGE=$((CURRENT_TIME - CREATED_AT_EPOCH))

  # Check if the cache is older than 24 hours (86400 seconds)
  if [ $AGE -gt 86400 ]; then
    echo "Deleting cache with ID $CACHE_ID (created at $CREATED_AT)"
    gh cache delete "$CACHE_ID"
  else
    echo "Cache with ID $CACHE_ID is not older than 24 hours (created at $CREATED_AT)"
  fi
done
