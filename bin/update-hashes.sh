#!/usr/bin/env bash
set -euo pipefail

JSON_FILE="wordpress-versions.json"
TEMP_FILE=$(mktemp)

echo "Checking for entries with blank hashes in $JSON_FILE..."

# Read the JSON file
cp "$JSON_FILE" "$TEMP_FILE"

# Get all keys and check for blank hashes
jq -r 'to_entries[] | select(.value.hash == "") | .key' "$JSON_FILE" | while read -r key; do
    version=$(jq -r ".[\"$key\"].version" "$JSON_FILE")
    echo "Found blank hash for $key (version $version)"
    
    # Construct the download URL
    url="https://wordpress.org/wordpress-${version}.tar.gz"
    echo "Fetching hash for $url..."
    
    # Fetch the hash using nix-prefetch-url and convert to SRI format
    sha256_hash=$(nix-prefetch-url "$url" --type sha256 2>/dev/null)
    sri_hash=$(nix-hash --type sha256 --to-sri "$sha256_hash")
    
    echo "Hash: $sri_hash"
    
    # Update the JSON file
    jq ".[\"$key\"].hash = \"$sri_hash\"" "$TEMP_FILE" > "${TEMP_FILE}.new"
    mv "${TEMP_FILE}.new" "$TEMP_FILE"
    
    echo "Updated $key with hash $sri_hash"
    echo ""
done

jsonfmt -w "$TEMP_FILE"

# Move the updated file back
mv "$TEMP_FILE" "$JSON_FILE"

echo "Done! All blank hashes have been updated."
